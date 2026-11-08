import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/features/medicine_logs/domain/intake_log.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import '../domain/schedule.dart';

extension ScheduleLabels on AppLocalizations {
  String frequencyLabel(Frequency f) => switch (f) {
        Frequency.daily => daily,
        Frequency.weekly => weekly,
        Frequency.custom => custom,
      };

  /// status == null means "no log yet": upcoming if in the future, otherwise due.
  String doseStatusLabel(IntakeStatus? s, DateTime at) => switch (s) {
        IntakeStatus.taken => statusTaken,
        IntakeStatus.missed => statusMissed,
        IntakeStatus.skipped => statusSkipped,
        IntakeStatus.snoozed => statusSnoozed,
        _ => at.isAfter(DateTime.now()) ? statusUpcoming : statusDue,
      };
}

/// (foreground, background) colours for a dose status chip.
(Color, Color) doseStatusColors(IntakeStatus? s, DateTime at) => switch (s) {
      IntakeStatus.taken => (AppColors.success, AppColors.lightGreen),
      IntakeStatus.missed => (AppColors.danger, AppColors.lightRed),
      IntakeStatus.skipped => (AppColors.textSecondary, AppColors.divider),
      IntakeStatus.snoozed => (AppColors.warning, AppColors.lightOrange),
      _ => at.isAfter(DateTime.now())
          ? (AppColors.primaryBlue, AppColors.lightBlue)
          : (AppColors.warning, AppColors.lightOrange),
    };
