import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/database/database_providers.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/features/family/presentation/family_providers.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/health_records/presentation/health_labels.dart';
import 'package:meditrack/features/medicines/presentation/medicine_labels.dart';
import 'package:meditrack/features/schedules/presentation/schedule_labels.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:printing/printing.dart';
import '../data/pdf_report_builder.dart';
import '../data/report_data.dart';

/// Choose a date range and sections, then preview / print / share a PDF.
class PdfReportScreen extends ConsumerStatefulWidget {
  const PdfReportScreen({super.key});
  @override
  ConsumerState<PdfReportScreen> createState() => _State();
}

class _State extends ConsumerState<PdfReportScreen> {
  late DateTimeRange _range =
      DateTimeRange(start: DateTime.now().subtract(const Duration(days: 29)), end: DateTime.now());
  bool _medicines = true, _history = true, _health = true, _personal = true;
  bool _busy = false;

  ReportStrings _strings(AppLocalizations t) => ReportStrings(
        title: t.pdfReportTitle, name: t.fullName, period: t.reportPeriod, generated: t.generatedOn,
        disclaimer: t.healthDisclaimer, medicines: t.navMedicines, intakeHistory: t.tabHistory,
        healthRecords: t.healthRecords, allergies: t.allergies, emergencyContacts: t.emergencyContacts,
        adherence: t.adherence, taken: t.statusTaken, missed: t.statusMissed, skipped: t.statusSkipped,
        colMedicine: t.medicineName, colDosage: t.dosageLabel, colFood: t.foodInstruction, colDateTime: t.dateAndTime,
        colStatus: t.statusColumn, colType: t.recordType, colValue: t.valueColumn, colNotes: t.notes,
        colName: t.fullName, colPhone: t.phoneNumber, colRelationship: t.relationshipColumn, colReaction: t.reactionColumn,
        noData: t.noHistory,
        statusLabel: (s) => t.doseStatusLabel(s, DateTime(2000)),
        foodLabel: t.foodLabel,
        healthTypeLabel: t.healthTypeLabel,
      );

  Future<Uint8List?> _generate() async {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final s = ref.read(sessionProvider);
    if (s == null) return null;
    setState(() => _busy = true);
    try {
      final db = (await ref.read(databaseProvider.future)).db;
      final memberId = ref.read(activeMemberProvider);
      final members = await ref.read(familyMembersProvider.future);
      final memberName = members.where((m) => m.id == memberId).map((m) => m.name).firstOrNull;
      final data = await ReportData.load(
        db,
        userId: s.id,
        userName: memberName ?? s.name,
        memberId: memberId,
        from: _range.start,
        to: _range.end,
        options: ReportOptions(medicines: _medicines, history: _history, health: _health, personal: _personal),
      );
      return await PdfReportBuilder.build(data, _strings(t), locale: locale);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.loadError)));
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.yMMMd(locale);
    final stamp = DateFormat('yyyyMMdd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text(t.pdfReports)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          children: [
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
                  side: BorderSide(color: Theme.of(context).dividerColor)),
              leading: const Icon(Icons.date_range),
              title: Text(t.reportPeriod),
              subtitle: Text('${fmt.format(_range.start)} – ${fmt.format(_range.end)}'),
              onTap: () async {
                final r = await showDateRangePicker(
                    context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDateRange: _range);
                if (r != null) setState(() => _range = r);
              },
            ),
            const SizedBox(height: 12),
            Text(t.includeSections, style: Theme.of(context).textTheme.titleMedium),
            CheckboxListTile(value: _medicines, title: Text(t.navMedicines), onChanged: (v) => setState(() => _medicines = v!)),
            CheckboxListTile(value: _history, title: Text(t.tabHistory), onChanged: (v) => setState(() => _history = v!)),
            CheckboxListTile(value: _health, title: Text(t.healthRecords), onChanged: (v) => setState(() => _health = v!)),
            CheckboxListTile(
                value: _personal, title: Text('${t.allergies}, ${t.emergencyContacts}'), onChanged: (v) => setState(() => _personal = v!)),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: _busy
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.print_outlined),
              label: Text(t.previewAndPrint),
              onPressed: _busy
                  ? null
                  : () async {
                      final bytes = await _generate();
                      if (bytes != null) await Printing.layoutPdf(onLayout: (_) async => bytes, name: 'meditrack_report_$stamp.pdf');
                    },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget)),
              icon: const Icon(Icons.share_outlined),
              label: Text(t.shareReport),
              onPressed: _busy
                  ? null
                  : () async {
                      final bytes = await _generate();
                      if (bytes != null) await Printing.sharePdf(bytes: bytes, filename: 'meditrack_report_$stamp.pdf');
                    },
            ),
            const SizedBox(height: 16),
            Text(t.pdfFontNote, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
