import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/authentication/presentation/auth_screens.dart' show tr;
import 'package:meditrack/features/inventory/domain/inventory.dart' show formatQty;
import 'package:meditrack/l10n/app_localizations.dart';
import '../domain/health_record.dart';
import 'health_labels.dart';
import 'health_providers.dart';

/// Add or edit a health record (blood pressure, glucose, weight, note, history).
class HealthFormScreen extends ConsumerStatefulWidget {
  const HealthFormScreen({super.key, this.existing, this.initialType});
  final HealthRecord? existing;
  final HealthType? initialType;
  @override
  ConsumerState<HealthFormScreen> createState() => _State();
}

class _State extends ConsumerState<HealthFormScreen> {
  final _form = GlobalKey<FormState>();
  late HealthType _type = widget.existing?.type ?? widget.initialType ?? HealthType.bloodPressure;
  late final _v1 = TextEditingController(text: widget.existing?.value1 == null ? '' : formatQty(widget.existing!.value1!));
  late final _v2 = TextEditingController(text: widget.existing?.value2 == null ? '' : formatQty(widget.existing!.value2!));
  late final _note = TextEditingController(text: widget.existing?.note);
  late String _glucoseUnit = widget.existing?.type == HealthType.bloodGlucose ? (widget.existing!.unit ?? 'mg/dL') : 'mg/dL';
  late String _weightUnit = widget.existing?.type == HealthType.weight ? (widget.existing!.unit ?? 'kg') : 'kg';
  late DateTime _at = widget.existing?.recordedAt ?? DateTime.now();
  String? _error;
  bool _saving = false;

  @override
  void dispose() { _v1.dispose(); _v2.dispose(); _note.dispose(); super.dispose(); }

  double? _num(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));
  String? get _unit => switch (_type) {
        HealthType.bloodPressure => 'mmHg',
        HealthType.bloodGlucose => _glucoseUnit,
        HealthType.weight => _weightUnit,
        _ => null,
      };

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d == null || !mounted) return;
    final tm = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
    if (tm == null) return;
    setState(() => _at = DateTime(d.year, d.month, d.day, tm.hour, tm.minute));
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    if (!_form.currentState!.validate()) return;
    final err = HealthValidators.check(_type, v1: _num(_v1), v2: _num(_v2), unit: _unit, note: _note.text);
    setState(() => _error = err == null ? null : (err == 'outOfRange' ? t.outOfRange : tr(t, err)));
    if (err != null) return;
    final session = ref.read(sessionProvider)!;
    setState(() => _saving = true);
    try {
      final repo = await ref.read(healthRepositoryProvider.future);
      final r = HealthRecord(
        id: widget.existing?.id ?? '',
        type: _type,
        value1: _type.isNumeric ? _num(_v1) : null,
        value2: _type == HealthType.bloodPressure ? _num(_v2) : null,
        unit: _unit,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        recordedAt: _at,
      );
      widget.existing == null ? await repo.add(session.id, r, memberId: ref.read(activeMemberProvider)) : await repo.edit(session.id, r);
      ref.invalidate(healthRecordsProvider);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() { _saving = false; _error = t.loadError; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    const numKb = TextInputType.numberWithOptions(decimal: true);
    String? req(String? v) => tr(t, Validators.number(v, positive: true));

    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? t.addHealthRecord : t.editHealthRecord)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              DropdownButtonFormField<HealthType>(
                initialValue: _type,
                isExpanded: true,
                decoration: InputDecoration(labelText: t.recordType),
                items: [for (final e in HealthType.values) DropdownMenuItem(value: e, child: Text(t.healthTypeLabel(e)))],
                onChanged: widget.existing != null ? null : (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              if (_type == HealthType.bloodPressure) ...[
                TextFormField(controller: _v1, keyboardType: numKb,
                    decoration: InputDecoration(labelText: t.systolic, suffixText: 'mmHg'), validator: req),
                const SizedBox(height: 16),
                TextFormField(controller: _v2, keyboardType: numKb,
                    decoration: InputDecoration(labelText: t.diastolic, suffixText: 'mmHg'), validator: req),
              ],
              if (_type == HealthType.bloodGlucose) ...[
                TextFormField(controller: _v1, keyboardType: numKb,
                    decoration: InputDecoration(labelText: t.glucoseLevel), validator: req),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [ButtonSegment(value: 'mg/dL', label: Text('mg/dL')), ButtonSegment(value: 'mmol/L', label: Text('mmol/L'))],
                  selected: {_glucoseUnit},
                  onSelectionChanged: (s) => setState(() => _glucoseUnit = s.first),
                ),
              ],
              if (_type == HealthType.weight) ...[
                TextFormField(controller: _v1, keyboardType: numKb,
                    decoration: InputDecoration(labelText: t.typeWeight), validator: req),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [ButtonSegment(value: 'kg', label: Text('kg')), ButtonSegment(value: 'lb', label: Text('lb'))],
                  selected: {_weightUnit},
                  onSelectionChanged: (s) => setState(() => _weightUnit = s.first),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _note,
                maxLines: _type.isNumeric ? 2 : 5,
                decoration: InputDecoration(labelText: _type.isNumeric ? t.notesOptional : t.notes),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
                    side: BorderSide(color: Theme.of(context).dividerColor)),
                leading: const Icon(Icons.event),
                title: Text(t.dateAndTime),
                subtitle: Text(DateFormat.yMMMd(locale).add_jm().format(_at)),
                onTap: _pickDateTime,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
