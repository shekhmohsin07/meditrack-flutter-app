import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:meditrack/features/health_records/domain/health_record.dart';
import 'package:meditrack/features/health_records/presentation/health_labels.dart' show healthValueText;
import 'package:meditrack/features/medicine_logs/domain/adherence.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'report_data.dart';

/// All text printed in the PDF, already translated (built from AppLocalizations).
class ReportStrings {
  const ReportStrings({
    required this.title, required this.name, required this.period, required this.generated, required this.disclaimer,
    required this.medicines, required this.intakeHistory, required this.healthRecords, required this.allergies,
    required this.emergencyContacts, required this.adherence, required this.taken, required this.missed, required this.skipped,
    required this.colMedicine, required this.colDosage, required this.colFood, required this.colDateTime, required this.colStatus,
    required this.colType, required this.colValue, required this.colNotes, required this.colName, required this.colPhone,
    required this.colRelationship, required this.colReaction, required this.noData,
    required this.statusLabel, required this.foodLabel, required this.healthTypeLabel,
  });
  final String title, name, period, generated, disclaimer;
  final String medicines, intakeHistory, healthRecords, allergies, emergencyContacts;
  final String adherence, taken, missed, skipped;
  final String colMedicine, colDosage, colFood, colDateTime, colStatus, colType, colValue, colNotes, colName, colPhone, colRelationship, colReaction;
  final String noData;
  final String Function(IntakeStatus) statusLabel;
  final String Function(FoodInstruction) foodLabel;
  final String Function(HealthType) healthTypeLabel;
}

/// Builds the PDF bytes. Colours mirror the app palette (AppColors).
class PdfReportBuilder {
  PdfReportBuilder._();
  static const _blue = PdfColor.fromInt(0xFF2563EB);
  static const _navy = PdfColor.fromInt(0xFF172554);
  static const _grey = PdfColor.fromInt(0xFF64748B);
  static const _line = PdfColor.fromInt(0xFFE2E8F0);

  static Future<Uint8List> build(ReportData d, ReportStrings s, {required String locale}) async {
    // Google fonts are downloaded once (needs internet). Without internet we fall back to the
    // built-in Helvetica, which cannot draw Bangla letters - see docs.
    pw.Font base, bold;
    try {
      if (locale.startsWith('bn')) {
        base = await PdfGoogleFonts.notoSansBengaliRegular();
        bold = await PdfGoogleFonts.notoSansBengaliBold();
      } else {
        base = await PdfGoogleFonts.interRegular();
        bold = await PdfGoogleFonts.interBold();
      }
    } catch (_) {
      base = pw.Font.helvetica();
      bold = pw.Font.helveticaBold();
    }

    final date = DateFormat.yMMMd(locale);
    final dateTime = DateFormat.yMMMd(locale).add_jm();
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: base, bold: bold), title: s.title);

    pw.Widget heading(String text) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16, bottom: 6),
          child: pw.Text(text, style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _navy)),
        );

    pw.Widget table(List<String> headers, List<List<String>> rows) => pw.TableHelper.fromTextArray(
          headers: headers,
          data: rows,
          headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: _blue),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
          headerAlignment: pw.Alignment.centerLeft,
          border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _line), bottom: pw.BorderSide(color: _line)),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        );

    final stats = AdherenceStats.from(d.history.map((e) => e.status));

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      footer: (c) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('${c.pageNumber} / ${c.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: _grey)),
      ),
      build: (c) => [
        pw.Text(s.title, style: const pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _blue)),
        pw.SizedBox(height: 8),
        pw.Text('${s.name}: ${d.userName}'),
        pw.Text('${s.period}: ${date.format(d.from)} – ${date.format(d.to)}'),
        pw.Text('${s.generated}: ${dateTime.format(d.generatedAt)}', style: const pw.TextStyle(color: _grey, fontSize: 9)),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEFF6FF)),
          child: pw.Text(s.disclaimer, style: const pw.TextStyle(fontSize: 8, color: _navy)),
        ),

        if (d.history.isNotEmpty || d.medicines.isNotEmpty) ...[
          if (d.history.isNotEmpty) ...[
            heading(s.adherence),
            pw.Text('${stats.percent == null ? '—' : '${stats.percent!.round()}%'}   '
                '${s.taken}: ${stats.taken}   ${s.missed}: ${stats.missed}   ${s.skipped}: ${stats.skipped}'),
          ],
        ],

        if (d.medicines.isNotEmpty) ...[
          heading(s.medicines),
          table([s.colMedicine, s.colDosage, s.colFood],
              [for (final m in d.medicines) [m.name, m.dosage, s.foodLabel(m.food)]]),
        ],

        if (d.history.isNotEmpty) ...[
          heading(s.intakeHistory),
          table([s.colDateTime, s.colMedicine, s.colDosage, s.colStatus], [
            for (final e in d.history) [dateTime.format(e.scheduledAt), e.medicineName, e.dosage, s.statusLabel(e.status)]
          ]),
        ],

        if (d.health.isNotEmpty) ...[
          heading(s.healthRecords),
          table([s.colDateTime, s.colType, s.colValue, s.colNotes], [
            for (final r in d.health)
              [
                dateTime.format(r.recordedAt),
                s.healthTypeLabel(r.type),
                r.type.isNumeric ? healthValueText(r) : '',
                r.type.isNumeric ? (r.note ?? '') : (r.note ?? ''),
              ]
          ]),
        ],

        if (d.allergies.isNotEmpty) ...[
          heading(s.allergies),
          table([s.colName, s.colReaction], [for (final a in d.allergies) [a['name'] as String, (a['reaction'] as String?) ?? '']]),
        ],

        if (d.contacts.isNotEmpty) ...[
          heading(s.emergencyContacts),
          table([s.colName, s.colPhone, s.colRelationship], [
            for (final c in d.contacts) [c['name'] as String, c['phone'] as String, (c['relationship'] as String?) ?? '']
          ]),
        ],

        if (d.medicines.isEmpty && d.history.isEmpty && d.health.isEmpty && d.allergies.isEmpty && d.contacts.isEmpty)
          pw.Padding(padding: const pw.EdgeInsets.only(top: 24), child: pw.Text(s.noData)),
      ],
    ));
    return doc.save();
  }
}
