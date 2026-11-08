import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/services/active_profile.dart';
import 'package:meditrack/core/services/image_service.dart';
import 'package:meditrack/features/authentication/presentation/profile_image.dart' show chooseImageSource, imageErrorText;
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/authentication/presentation/auth_screens.dart' show tr;
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart' show refreshReminders;
import 'package:meditrack/l10n/app_localizations.dart';
import '../domain/medicine.dart';
import 'medicine_labels.dart';
import 'medicine_providers.dart';

/// Used for both "Add" (existing == null) and "Edit".
class MedicineFormScreen extends ConsumerStatefulWidget {
  const MedicineFormScreen({super.key, this.existing});
  final Medicine? existing;
  @override
  ConsumerState<MedicineFormScreen> createState() => _State();
}

class _State extends ConsumerState<MedicineFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _dosage = TextEditingController(text: widget.existing?.dosage);
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late String? _imagePath = widget.existing?.imagePath;
  late MedicineType _type = widget.existing?.type ?? MedicineType.tablet;
  late FoodInstruction _food = widget.existing?.food ?? FoodInstruction.afterFood;
  late DateTime _start = widget.existing?.startDate ?? DateTime.now();
  late DateTime? _end = widget.existing?.endDate;
  late bool _completed = widget.existing?.completed ?? false;
  String? _dateError;
  bool _saving = false;

  @override
  void dispose() { _name.dispose(); _dosage.dispose(); _notes.dispose(); super.dispose(); }

  Future<void> _pick(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _start : _end) ?? _start,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => isStart ? _start = picked : _end = picked);
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    final err = Validators.dateRange(_start, _end);
    setState(() => _dateError = tr(t, err));
    if (!_form.currentState!.validate() || err != null) return;
    final session = ref.read(sessionProvider)!;
    setState(() => _saving = true);
    try {
      final repo = await ref.read(medicineRepositoryProvider.future);
      final m = Medicine(
        id: widget.existing?.id ?? '',
        userId: session.id,
        memberId: widget.existing?.memberId ?? ref.read(activeMemberProvider),
        name: _name.text,
        dosage: _dosage.text,
        type: _type,
        food: _food,
        startDate: _start,
        endDate: _end,
        completed: _completed,
        imagePath: _imagePath,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      widget.existing == null ? await repo.add(m) : await repo.edit(m);
      if (widget.existing?.imagePath != null && widget.existing!.imagePath != _imagePath) {
        await ImageService().deleteFile(widget.existing!.imagePath); // replaced or removed photo
      }
      ref.invalidate(medicinesProvider);
      if (mounted) await refreshReminders(context, ref);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.loadError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? t.addMedicine : t.editMedicine)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
                  child: Container(
                    width: 72, height: 72,
                    color: Theme.of(context).dividerColor,
                    child: _imagePath != null && File(_imagePath!).existsSync()
                        ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                        : const Icon(Icons.medication_outlined, size: 32),
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(spacing: 8, children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(t.addPhoto),
                    onPressed: () async {
                      final src = await chooseImageSource(context);
                      if (src == null) return;
                      try {
                        final path = await ImageService().pickAndStore(src);
                        if (path != null) {
                          final old = _imagePath;
                          setState(() => _imagePath = path);
                          if (old != null && old != widget.existing?.imagePath) await ImageService().deleteFile(old);
                        }
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(imageErrorText(t, e))));
                      }
                    },
                  ),
                  if (_imagePath != null)
                    TextButton(onPressed: () => setState(() => _imagePath = null), child: Text(t.removePhoto)),
                ]),
              ]),
              const SizedBox(height: 16),
              TextFormField(controller: _name, decoration: InputDecoration(labelText: t.medicineName),
                  validator: (v) => tr(t, Validators.required(v))),
              const SizedBox(height: 16),
              TextFormField(controller: _dosage,
                  decoration: InputDecoration(labelText: t.dosageLabel, helperText: t.dosageHint, helperMaxLines: 2),
                  validator: (v) => tr(t, Validators.required(v))),
              const SizedBox(height: 16),
              DropdownButtonFormField<MedicineType>(
                initialValue: _type,
                decoration: InputDecoration(labelText: t.medicineType),
                items: [for (final e in MedicineType.values) DropdownMenuItem(value: e, child: Text(t.typeLabel(e)))],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FoodInstruction>(
                initialValue: _food,
                isExpanded: true,
                decoration: InputDecoration(labelText: t.foodInstruction),
                items: [for (final e in FoodInstruction.values) DropdownMenuItem(value: e, child: Text(t.foodLabel(e)))],
                onChanged: (v) => setState(() => _food = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
                    side: BorderSide(color: Theme.of(context).dividerColor)),
                leading: const Icon(Icons.event),
                title: Text(t.startDate),
                subtitle: Text(fmt.format(_start)),
                onTap: () => _pick(true),
              ),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
                    side: BorderSide(color: Theme.of(context).dividerColor)),
                leading: const Icon(Icons.event_available),
                title: Text(t.endDate),
                subtitle: Text(_end == null ? '-' : fmt.format(_end!)),
                trailing: _end == null ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _end = null)),
                onTap: () => _pick(false),
              ),
              if (_dateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_dateError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 16),
              TextFormField(controller: _notes, maxLines: 3, decoration: InputDecoration(labelText: t.notesOptional)),
              if (widget.existing != null)
                SwitchListTile(title: Text(t.completed), value: _completed, onChanged: (v) => setState(() => _completed = v)),
              const SizedBox(height: 24),
              FilledButton(onPressed: _saving ? null : _save, child: Text(t.save)),
            ]),
          ),
        ),
      ),
    );
  }
}
