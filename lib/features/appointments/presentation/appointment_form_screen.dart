import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/authentication/presentation/auth_screens.dart' show tr;
import 'package:meditrack/features/schedules/presentation/schedule_providers.dart' show refreshReminders;
import 'package:meditrack/l10n/app_localizations.dart';
import '../domain/appointment.dart';
import 'appointment_providers.dart';

const reminderChoices = [15, 30, 60, 120, 1440]; // minutes before

String reminderLabel(AppLocalizations t, int m) => m == 1440 ? t.oneDayBefore : t.minutesBefore(m.toString());

/// Add or edit a doctor appointment.
class AppointmentFormScreen extends ConsumerStatefulWidget {
  const AppointmentFormScreen({super.key, this.existing});
  final Appointment? existing;
  @override
  ConsumerState<AppointmentFormScreen> createState() => _State();
}

class _State extends ConsumerState<AppointmentFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _doctor = TextEditingController(text: widget.existing?.doctorName);
  late final _hospital = TextEditingController(text: widget.existing?.hospital);
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late DateTime _at = widget.existing?.at ?? DateTime.now().add(const Duration(days: 1));
  late int _reminder = widget.existing?.reminderMinutes ?? 60;
  bool _saving = false;

  @override
  void dispose() { _doctor.dispose(); _hospital.dispose(); _notes.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d != null) setState(() => _at = DateTime(d.year, d.month, d.day, _at.hour, _at.minute));
  }

  Future<void> _pickTime() async {
    final tm = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
    if (tm != null) setState(() => _at = DateTime(_at.year, _at.month, _at.day, tm.hour, tm.minute));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final session = ref.read(sessionProvider)!;
    setState(() => _saving = true);
    try {
      final repo = await ref.read(appointmentRepositoryProvider.future);
      await repo.save(
        session.id,
        Appointment(
          id: widget.existing?.id ?? '',
          doctorName: _doctor.text,
          hospital: _hospital.text.trim().isEmpty ? null : _hospital.text.trim(),
          at: _at,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          reminderMinutes: _reminder,
          status: widget.existing?.status ?? 'upcoming',
        ),
      );
      ref.invalidate(appointmentsProvider);
      if (mounted) await refreshReminders(context, ref);
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
    final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
        side: BorderSide(color: Theme.of(context).dividerColor));
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? t.addAppointment : t.editAppointment)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextFormField(controller: _doctor, decoration: InputDecoration(labelText: t.doctorName),
                  validator: (v) => tr(t, Validators.required(v))),
              const SizedBox(height: 16),
              TextFormField(controller: _hospital, decoration: InputDecoration(labelText: t.hospitalOrClinic)),
              const SizedBox(height: 16),
              ListTile(shape: shape, leading: const Icon(Icons.event), title: Text(t.appointmentDate),
                  subtitle: Text(DateFormat.yMMMEd(locale).format(_at)), onTap: _pickDate),
              const SizedBox(height: 12),
              ListTile(shape: shape, leading: const Icon(Icons.access_time), title: Text(t.appointmentTime),
                  subtitle: Text(DateFormat.jm(locale).format(_at)), onTap: _pickTime),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _reminder,
                decoration: InputDecoration(labelText: t.remindMe),
                items: [for (final m in reminderChoices) DropdownMenuItem(value: m, child: Text(reminderLabel(t, m)))],
                onChanged: (v) => setState(() => _reminder = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _notes, maxLines: 4, decoration: InputDecoration(labelText: t.notesOptional)),
              const SizedBox(height: 24),
              FilledButton(onPressed: _saving ? null : _save, child: Text(t.save)),
            ]),
          ),
        ),
      ),
    );
  }
}
