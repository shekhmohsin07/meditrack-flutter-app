import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/features/authentication/presentation/auth_screens.dart' show tr;
import 'package:meditrack/features/medicines/domain/medicine.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import '../domain/inventory.dart';
import 'inventory_providers.dart';

/// Set up or edit stock for one medicine.
class InventoryFormScreen extends ConsumerStatefulWidget {
  const InventoryFormScreen({super.key, required this.medicine, this.existing});
  final Medicine medicine;
  final InventoryItem? existing;
  @override
  ConsumerState<InventoryFormScreen> createState() => _State();
}

class _State extends ConsumerState<InventoryFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _qty = TextEditingController(text: widget.existing == null ? '' : formatQty(widget.existing!.remaining));
  late final _threshold = TextEditingController(text: formatQty(widget.existing?.threshold ?? 5));
  late final _dose = TextEditingController(text: formatQty(widget.existing?.doseQuantity ?? 1));
  late DateTime? _expiry = widget.existing?.expiry;
  bool _saving = false;

  double _n(TextEditingController c) => double.parse(c.text.trim().replaceAll(',', '.'));

  @override
  void dispose() { _qty.dispose(); _threshold.dispose(); _dose.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = await ref.read(inventoryRepositoryProvider.future);
      await repo.save(
        existing: widget.existing,
        medicineId: widget.medicine.id,
        quantity: _n(_qty),
        threshold: _n(_threshold),
        doseQuantity: _n(_dose),
        expiry: _expiry,
      );
      ref.invalidate(stockRowsProvider);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.loadError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    const numKb = TextInputType.numberWithOptions(decimal: true);
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? t.setUpStock : t.editStock)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(widget.medicine.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qty, keyboardType: numKb,
                decoration: InputDecoration(labelText: widget.existing == null ? t.initialQuantity : t.remainingQuantity),
                validator: (v) => tr(t, Validators.number(v)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dose, keyboardType: numKb,
                decoration: InputDecoration(labelText: t.doseQuantity),
                validator: (v) => tr(t, Validators.number(v, positive: true)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _threshold, keyboardType: numKb,
                decoration: InputDecoration(labelText: t.lowStockThreshold),
                validator: (v) => tr(t, Validators.number(v)),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
                    side: BorderSide(color: Theme.of(context).dividerColor)),
                leading: const Icon(Icons.event_busy),
                title: Text(t.expiryDate),
                subtitle: Text(_expiry == null ? '-' : DateFormat.yMMMd(locale).format(_expiry!)),
                trailing: _expiry == null ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _expiry = null)),
                onTap: () async {
                  final d = await showDatePicker(
                      context: context, initialDate: _expiry ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (d != null) setState(() => _expiry = d);
                },
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _saving ? null : _save, child: Text(t.save)),
            ]),
          ),
        ),
      ),
    );
  }
}
