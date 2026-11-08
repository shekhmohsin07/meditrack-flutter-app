import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart' show refreshReminders, scheduleEntriesProvider;
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/features/family/presentation/profile_selector.dart';
import 'package:meditrack/features/inventory/presentation/inventory_screen.dart';
import '../data/medicine_repository.dart';
import '../domain/medicine.dart';
import 'medicine_details_screen.dart';
import 'medicine_form_screen.dart';
import 'medicine_labels.dart';
import 'medicine_providers.dart';

class MedicineListScreen extends ConsumerWidget {
  const MedicineListScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, Medicine m) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(t.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancel)),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(t.delete)),
        ],
      ),
    );
    if (ok == true) {
      await (await ref.read(medicineRepositoryProvider.future)).remove(m.id);
      ref.invalidate(medicinesProvider);
      ref.invalidate(scheduleEntriesProvider);
      if (context.mounted) await refreshReminders(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final meds = ref.watch(medicinesProvider);
    final filter = ref.watch(medicineFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navMedicines, style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          IconButton(
            tooltip: t.inventory,
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen())),
          ),
          PopupMenuButton<MedicineSort>(
            icon: const Icon(Icons.sort),
            onSelected: (s) => ref.read(medicineSortProvider.notifier).state = s,
            itemBuilder: (_) => [
              PopupMenuItem(value: MedicineSort.name, child: Text(t.sortName)),
              PopupMenuItem(value: MedicineSort.startDate, child: Text(t.sortDate)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: t.addMedicine,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicineFormScreen())),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        const ProfileSelector(),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimensions.screenPadding, 8, AppDimensions.screenPadding, 8),
          child: TextField(
            decoration: InputDecoration(hintText: t.searchMedicines, prefixIcon: const Icon(Icons.search)),
            onChanged: (v) => ref.read(medicineSearchProvider.notifier).state = v,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          child: Row(children: [
            for (final (label, value) in [(t.all, null), (t.active, false), (t.completed, true)]) ...[
              ChoiceChip(
                label: Text(label),
                selected: filter == value,
                onSelected: (_) => ref.read(medicineFilterProvider.notifier).state = value,
              ),
              const SizedBox(width: 8),
            ],
          ]),
        ),
        Expanded(
          child: meds.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(t.loadError),
                TextButton(onPressed: () => ref.invalidate(medicinesProvider), child: Text(t.retry)),
              ]),
            ),
            data: (list) => list.isEmpty
                ? Center(child: Text(t.noMedicines, style: Theme.of(context).textTheme.bodySmall))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final m = list[i];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppDimensions.cardPadding),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.lightBlue,
                            backgroundImage: m.imagePath != null && File(m.imagePath!).existsSync() ? FileImage(File(m.imagePath!)) : null,
                            child: m.imagePath != null && File(m.imagePath!).existsSync()
                                ? null
                                : const Icon(Icons.medication, color: AppColors.primaryBlue),
                          ),
                          title: Text(m.name, style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text('${m.dosage} • ${t.typeLabel(m.type)}\n${t.foodLabel(m.food)}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: t.delete,
                            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                            onPressed: () => _delete(context, ref, m),
                          ),
                          onTap: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => MedicineDetailsScreen(medicine: m))),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}
