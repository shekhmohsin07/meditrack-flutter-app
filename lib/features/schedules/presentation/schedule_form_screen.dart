import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/features/authentication/presentation/auth_screens.dart' show tr;
import 'package:meditrack/l10n/app_localizations.dart';
import '../domain/schedule.dart';
import 'schedule_labels.dart';
import 'schedule_providers.dart';

/// Create or edit a schedule (existing == null means create).
class ScheduleFormScreen extends ConsumerStatefulWidget {
  const ScheduleFormScreen({super.key, this.existing});
  final Schedule? existing;
  @override
  ConsumerState<ScheduleFormScreen> createState() => _State();
}

class _State extends ConsumerState<ScheduleFormScreen> {
  late String? _medicineId = widget.existing?.medicineId;
  late Frequency _freq = widget.existing?.frequency ?? Frequency.daily;
  late final Set<int> _days = {...(widget.existing?.days ?? {1, 2, 3, 4, 5, 6, 7})};
  late List<String> _times = [...(widget.existing?.times ?? const <String>[])];
  late DateTime _start = widget.existing?.startDate ?? DateTime.now();
  late DateTime? _end = widget.existing?.endDate;
  String? _error;
  bool _saving = false;

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _addTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;
    final v = _fmt(picked);
    if (!_times.contains(v)) setState(() => _times = [..._times, v]..sort());
  }

  Future<void> _pickDate(bool isStart) async {
    final d = await showDatePicker(
        context: context, initialDate: (isStart ? _start : _end) ?? _start, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d != null) setState(() => isStart ? _start = d : _end = d);
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    String? err;
    if (_medicineId == null) {
      err = t.addMedicineFirst;
    } else if (_times.isEmpty) {
      err = t.atLeastOneTime;
    } else if (_freq != Frequency.daily && _days.isEmpty) {
      err = t.selectDays;
    } else {
      err = tr(t, Validators.dateRange(_start, _end));
    }
    setState(() => _error = err);
    if (err != null) return;

    setState(() => _saving = true);
    try {
      final repo = await ref.read(scheduleRepositoryProvider.future);
      await repo.save(Schedule(
        id: widget.existing?.id ?? '',
        medicineId: _medicineId!,
        frequency: _freq,
        days: _freq == Frequency.daily ? {1, 2, 3, 4, 5, 6, 7} : _days,
        startDate: _start,
        endDate: _end,
        paused: widget.existing?.paused ?? false,
        times: _times,
      ));
      ref.invalidate(scheduleEntriesProvider);
      if (mounted) await refreshReminders(context, ref);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() { _saving = false; _error = t.loadError; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final meds = ref.watch(pickableMedicinesProvider);
    final dateFmt = DateFormat.yMMMd(locale);
    final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
        side: BorderSide(color: Theme.of(context).dividerColor));

    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? t.addSchedule : t.editSchedule)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            meds.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => Text(t.loadError),
              data: (list) => list.isEmpty
                  ? Text(t.addMedicineFirst)
                  : DropdownButtonFormField<String>(
                      initialValue: list.any((m) => m.id == _medicineId) ? _medicineId : null,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: t.selectMedicine),
                      items: [for (final m in list) DropdownMenuItem(value: m.id, child: Text('${m.name} (${m.dosage})', overflow: TextOverflow.ellipsis))],
                      onChanged: widget.existing != null ? null : (v) => setState(() => _medicineId = v),
                    ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Frequency>(
              initialValue: _freq,
              decoration: InputDecoration(labelText: t.frequency),
              items: [for (final f in Frequency.values) DropdownMenuItem(value: f, child: Text(t.frequencyLabel(f)))],
              onChanged: (v) => setState(() => _freq = v!),
            ),
            if (_freq != Frequency.daily) ...[
              const SizedBox(height: 16),
              Text(t.repeatDays, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (var d = 1; d <= 7; d++)
                  FilterChip(
                    // 2024-01-01 is a Monday, so day d maps to weekday d.
                    label: Text(DateFormat.E(locale).format(DateTime(2024, 1, d))),
                    selected: _days.contains(d),
                    onSelected: (on) => setState(() => on ? _days.add(d) : _days.remove(d)),
                  ),
              ]),
            ],
            const SizedBox(height: 16),
            Text(t.reminderTimes, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final time in _times)
                InputChip(label: Text(time), onDeleted: () => setState(() => _times = _times.where((x) => x != time).toList())),
              ActionChip(avatar: const Icon(Icons.add_alarm, size: 18), label: Text(t.addTime), onPressed: _addTime),
            ]),
            const SizedBox(height: 16),
            ListTile(shape: shape, leading: const Icon(Icons.event), title: Text(t.startDate),
                subtitle: Text(dateFmt.format(_start)), onTap: () => _pickDate(true)),
            const SizedBox(height: 12),
            ListTile(
              shape: shape, leading: const Icon(Icons.event_available), title: Text(t.endDate),
              subtitle: Text(_end == null ? '-' : dateFmt.format(_end!)),
              trailing: _end == null ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _end = null)),
              onTap: () => _pickDate(false),
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
    );
  }
}
