import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import '../domain/inventory.dart';
import 'inventory_form_screen.dart';
import 'inventory_labels.dart';
import 'inventory_providers.dart';

/// Stock & expiry overview for all active medicines.
class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  Future<void> _adjust(BuildContext context, WidgetRef ref, InventoryItem item) async {
    final t = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    String? error;
    final delta = await showDialog<double>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: Text(t.adjustStock),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.adjustAmount, errorText: error),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: Text(t.cancel)),
            for (final sign in const [-1, 1])
              TextButton(
                onPressed: () {
                  if (Validators.number(ctrl.text, positive: true) != null) {
                    setState(() => error = t.invalidNumber);
                    return;
                  }
                  Navigator.pop(c, sign * double.parse(ctrl.text.trim().replaceAll(',', '.')));
                },
                child: Text(sign > 0 ? t.addStock : t.removeStock),
              ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (delta == null) return;
    await (await ref.read(inventoryRepositoryProvider.future)).adjust(item.id, delta);
    ref.invalidate(stockRowsProvider);
  }

  Future<void> _showHistory(BuildContext context, WidgetRef ref, InventoryItem item) async {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final moves = await (await ref.read(inventoryRepositoryProvider.future)).history(item.id);
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: moves.isEmpty
            ? Padding(padding: const EdgeInsets.all(24), child: Text(t.noStockHistory))
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final m in moves)
                    ListTile(
                      title: Text(t.reasonLabel(m.reason)),
                      subtitle: Text(DateFormat.yMMMd(locale).add_jm().format(m.at)),
                      trailing: Text('${m.change > 0 ? '+' : ''}${formatQty(m.change)}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final rows = ref.watch(stockRowsProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(t.inventory)),
      body: rows.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(t.loadError),
            TextButton(onPressed: () => ref.invalidate(stockRowsProvider), child: Text(t.retry)),
          ]),
        ),
        data: (list) => list.isEmpty
            ? Center(child: Text(t.noMedicines, style: Theme.of(context).textTheme.bodySmall))
            : ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final r = list[i];
                  final item = r.item;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.cardPadding),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(r.medicine.name, style: Theme.of(context).textTheme.titleMedium)),
                          if (item != null)
                            Builder(builder: (_) {
                              final st = item.statusOn(now);
                              final (fg, bg) = stockColors(st);
                              return Chip(
                                label: Text(t.stockLabel(st), style: TextStyle(color: fg, fontSize: 12)),
                                backgroundColor: bg,
                                side: BorderSide.none,
                                visualDensity: VisualDensity.compact,
                              );
                            }),
                        ]),
                        const SizedBox(height: 8),
                        if (item == null) ...[
                          FilledButton.tonal(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => InventoryFormScreen(medicine: r.medicine))),
                            child: Text(t.setUpStock),
                          ),
                        ] else ...[
                          LinearProgressIndicator(
                            value: item.initial <= 0 ? 0 : (item.remaining / item.initial).clamp(0.0, 1.0),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text(t.unitsLeft('${formatQty(item.remaining)} / ${formatQty(item.initial)}')),
                          if (item.expiry != null)
                            Text('${t.expiryDate}: ${DateFormat.yMMMd(locale).format(item.expiry!)}',
                                style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Wrap(spacing: 8, children: [
                            OutlinedButton(onPressed: () => _adjust(context, ref, item), child: Text(t.adjustStock)),
                            OutlinedButton(
                              onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => InventoryFormScreen(medicine: r.medicine, existing: item))),
                              child: Text(t.editStock),
                            ),
                            TextButton(onPressed: () => _showHistory(context, ref, item), child: Text(t.stockHistory)),
                          ]),
                        ],
                      ]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
