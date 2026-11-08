import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/inventory/domain/inventory.dart';
import 'package:meditrack/features/inventory/presentation/inventory_labels.dart';
import 'package:meditrack/features/inventory/presentation/inventory_providers.dart';
import 'package:meditrack/features/schedules/presentation/schedule_labels.dart';
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import '../domain/medicine.dart';
import 'medicine_form_screen.dart';
import 'medicine_labels.dart';

/// Everything about one medicine: details, schedule, stock.
class MedicineDetailsScreen extends ConsumerWidget {
  const MedicineDetailsScreen({super.key, required this.medicine});
  final Medicine medicine; // snapshot from the list; editing returns to the list which reloads

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.yMMMd(locale);
    final m = medicine;
    final schedules = ref.watch(scheduleEntriesProvider).valueOrNull?.where((e) => e.medicine.id == m.id).toList() ?? const [];
    final stock = ref.watch(stockRowsProvider).valueOrNull?.where((r) => r.medicine.id == m.id).map((r) => r.item).firstOrNull;
    final hasImage = m.imagePath != null && File(m.imagePath!).existsSync();

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 120, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
            Expanded(child: Text(value)),
          ]),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(t.medicineDetails),
        actions: [
          IconButton(
            tooltip: t.editMedicine,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => MedicineFormScreen(existing: m)));
              if (context.mounted) Navigator.pop(context); // list reloads with the saved values
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              child: Image.file(File(m.imagePath!), height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          Text(m.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              child: Column(children: [
                row(t.dosageLabel, m.dosage),
                row(t.medicineType, t.typeLabel(m.type)),
                row(t.foodInstruction, t.foodLabel(m.food)),
                row(t.startDate, fmt.format(m.startDate)),
                row(t.endDate, m.endDate == null ? '-' : fmt.format(m.endDate!)),
                row(t.status, m.completed ? t.completed : t.active),
                if ((m.notes ?? '').isNotEmpty) row(t.notes, m.notes!),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text(t.scheduleSummary, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (schedules.isEmpty)
            Text(t.noSchedules, style: Theme.of(context).textTheme.bodySmall)
          else
            for (final e in schedules)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule, color: AppColors.primaryBlue),
                  title: Text('${t.frequencyLabel(e.schedule.frequency)}${e.schedule.paused ? ' • ${t.paused}' : ''}'),
                  subtitle: Text(e.schedule.times.join(', ')),
                ),
              ),
          const SizedBox(height: 16),
          Text(t.stockSummary, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (stock == null)
            Text(t.noStockYet, style: Theme.of(context).textTheme.bodySmall)
          else
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryBlue),
                title: Text(t.unitsLeft('${formatQty(stock.remaining)} / ${formatQty(stock.initial)}')),
                subtitle: Text([
                  t.stockLabel(stock.statusOn(DateTime.now())),
                  if (stock.expiry != null) '${t.expiryDate}: ${fmt.format(stock.expiry!)}',
                ].join(' • ')),
              ),
            ),
        ],
      ),
    );
  }
}
