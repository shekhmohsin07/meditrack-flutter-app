// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MediTrack';

  @override
  String get navHome => 'Home';

  @override
  String get navMedicines => 'Medicines';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navReports => 'Reports';

  @override
  String get navProfile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা';

  @override
  String get comingSoon => 'This screen is built in the next batch.';

  @override
  String get healthDisclaimer =>
      'MediTrack is a reminder and record-keeping app. It does not diagnose, prescribe or advise on dosage. Always follow your healthcare professional\'s instructions.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get fullName => 'Full name';

  @override
  String get login => 'Log in';

  @override
  String get register => 'Register';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetLinkSent => 'Password reset email sent. Check your inbox.';

  @override
  String get createAccount => 'Create account';

  @override
  String get haveAccount => 'Already have an account? Log in';

  @override
  String get noAccount => 'No account? Register';

  @override
  String get continueOffline => 'Continue offline (no cloud)';

  @override
  String get logout => 'Log out';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get addMedicine => 'Add medicine';

  @override
  String get editMedicine => 'Edit medicine';

  @override
  String get medicineName => 'Medicine name';

  @override
  String get dosageLabel => 'Dosage (as prescribed)';

  @override
  String get dosageHint =>
      'e.g. 1 tablet, 5 ml - exactly as your doctor instructed';

  @override
  String get medicineType => 'Medicine type';

  @override
  String get foodInstruction => 'Food instruction';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date (optional)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirm => 'Delete this medicine? This cannot be undone.';

  @override
  String get searchMedicines => 'Search medicines';

  @override
  String get noMedicines => 'No medicines yet. Tap + to add one.';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get completed => 'Completed';

  @override
  String get sortName => 'Sort by name';

  @override
  String get sortDate => 'Sort by start date';

  @override
  String get typeTablet => 'Tablet';

  @override
  String get typeCapsule => 'Capsule';

  @override
  String get typeSyrup => 'Syrup';

  @override
  String get typeInjection => 'Injection';

  @override
  String get typeDrops => 'Drops';

  @override
  String get typeCream => 'Cream';

  @override
  String get typeOther => 'Other';

  @override
  String get foodBefore => 'Before food';

  @override
  String get foodAfter => 'After food';

  @override
  String get foodWith => 'With food';

  @override
  String get foodEmpty => 'Empty stomach';

  @override
  String get foodDoctor => 'As instructed by doctor';

  @override
  String get endBeforeStart => 'End date cannot be before start date';

  @override
  String get loadError => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get addSchedule => 'Add schedule';

  @override
  String get editSchedule => 'Edit schedule';

  @override
  String get manageSchedules => 'Manage schedules';

  @override
  String get selectMedicine => 'Medicine';

  @override
  String get frequency => 'Repeat';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get custom => 'Custom days';

  @override
  String get repeatDays => 'Repeat on';

  @override
  String get reminderTimes => 'Reminder times';

  @override
  String get addTime => 'Add time';

  @override
  String get atLeastOneTime => 'Add at least one reminder time';

  @override
  String get selectDays => 'Select at least one day';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get paused => 'Paused';

  @override
  String get noDosesToday => 'No doses scheduled for this day.';

  @override
  String get noSchedules => 'No schedules yet. Tap + to create one.';

  @override
  String get addMedicineFirst =>
      'Add a medicine first, then create its schedule.';

  @override
  String get statusTaken => 'Taken';

  @override
  String get statusMissed => 'Missed';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusSnoozed => 'Snoozed';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get statusDue => 'Due';

  @override
  String get markTaken => 'Mark as taken';

  @override
  String get markSkipped => 'Skip';

  @override
  String get notificationHistory => 'Notification history';

  @override
  String get noNotifications => 'No notifications yet.';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get allowExactAlarms => 'Allow exact alarms';

  @override
  String get notificationsOn => 'Notifications are enabled';

  @override
  String get notificationsOff => 'Notifications are turned off';

  @override
  String notifTitle(String name) {
    return 'Time to take $name';
  }

  @override
  String get actionTaken => 'Taken';

  @override
  String get actionSnooze => 'Snooze 10 min';

  @override
  String get actionSkip => 'Skip';

  @override
  String get notifScheduled => 'Scheduled';

  @override
  String get notifShown => 'Shown';

  @override
  String get notifCancelled => 'Cancelled';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get inventory => 'Stock & expiry';

  @override
  String get setUpStock => 'Set up stock';

  @override
  String get editStock => 'Edit stock';

  @override
  String get initialQuantity => 'Quantity you have now';

  @override
  String get remainingQuantity => 'Remaining quantity';

  @override
  String get doseQuantity => 'Units used per dose';

  @override
  String get lowStockThreshold => 'Warn me when stock is at or below';

  @override
  String get expiryDate => 'Expiry date';

  @override
  String get adjustStock => 'Adjust stock';

  @override
  String get adjustAmount => 'Amount';

  @override
  String get addStock => 'Add (refill)';

  @override
  String get removeStock => 'Remove';

  @override
  String get stockHistory => 'Stock history';

  @override
  String get noStockHistory => 'No stock changes yet.';

  @override
  String get stockOk => 'In stock';

  @override
  String get stockLow => 'Low stock - consider a refill';

  @override
  String get stockOut => 'Out of stock';

  @override
  String get expiringSoon => 'Expiring soon';

  @override
  String get expired => 'Expired';

  @override
  String unitsLeft(String count) {
    return '$count left';
  }

  @override
  String get reasonInitial => 'Initial stock';

  @override
  String get reasonIntake => 'Dose taken';

  @override
  String get reasonRefill => 'Refill';

  @override
  String get reasonManual => 'Manual change';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get allMedicines => 'All medicines';

  @override
  String get adherence => 'Adherence';

  @override
  String get adherenceNote =>
      'Adherence = taken doses ÷ (taken + missed + skipped). It only reflects your reminder records and is not medical advice. Talk to your healthcare professional about your treatment.';

  @override
  String get dailyAdherence => 'Adherence by day';

  @override
  String get noHistory => 'No records for this period.';

  @override
  String get tabHistory => 'History';

  @override
  String get tabStatistics => 'Statistics';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get addAllergy => 'Add allergy';

  @override
  String get editAllergy => 'Edit allergy';

  @override
  String get allergies => 'Allergies';

  @override
  String get allergyName => 'Allergy (e.g. a food or medicine)';

  @override
  String get reactionOptional => 'Reaction (optional)';

  @override
  String get noAllergies => 'No allergies recorded.';

  @override
  String get addContact => 'Add contact';

  @override
  String get editContact => 'Edit contact';

  @override
  String get emergencyContacts => 'Emergency contacts';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get invalidPhone => 'Enter a valid phone number';

  @override
  String get relationshipOptional => 'Relationship (optional)';

  @override
  String get noContacts => 'No emergency contacts yet.';

  @override
  String get addAppointment => 'Add appointment';

  @override
  String get editAppointment => 'Edit appointment';

  @override
  String get appointments => 'Doctor appointments';

  @override
  String get doctorName => 'Doctor name';

  @override
  String get hospitalOrClinic => 'Hospital or clinic (optional)';

  @override
  String get appointmentDate => 'Date';

  @override
  String get appointmentTime => 'Time';

  @override
  String get remindMe => 'Remind me';

  @override
  String minutesBefore(String minutes) {
    return '$minutes minutes before';
  }

  @override
  String get oneDayBefore => '1 day before';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get noUpcomingAppointments => 'No upcoming appointments.';

  @override
  String get noAppointmentHistory => 'No past appointments.';

  @override
  String get appointmentCompleted => 'Completed';

  @override
  String get appointmentCancelled => 'Cancelled';

  @override
  String get markCompleted => 'Mark as completed';

  @override
  String get cancelAppointment => 'Cancel appointment';

  @override
  String get reopenAppointment => 'Mark as upcoming';

  @override
  String appointmentNotifTitle(String doctor) {
    return 'Appointment with $doctor';
  }

  @override
  String get appointmentNotifBody => 'You have a doctor appointment soon.';

  @override
  String get healthRecords => 'Health records';

  @override
  String get addHealthRecord => 'Add health record';

  @override
  String get editHealthRecord => 'Edit health record';

  @override
  String get recordType => 'Record type';

  @override
  String get typeBloodPressure => 'Blood pressure';

  @override
  String get typeBloodGlucose => 'Blood glucose';

  @override
  String get typeWeight => 'Weight';

  @override
  String get typeHealthNote => 'Health note';

  @override
  String get typeMedicalHistory => 'Medical history';

  @override
  String get systolic => 'Systolic (upper)';

  @override
  String get diastolic => 'Diastolic (lower)';

  @override
  String get glucoseLevel => 'Glucose level';

  @override
  String get notes => 'Notes';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get dateAndTime => 'Date & time';

  @override
  String get allDates => 'All dates';

  @override
  String get noHealthRecords => 'No records yet. Tap + to add one.';

  @override
  String get outOfRange =>
      'Please check this value - it looks like a typing mistake.';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get todaySummary => 'Today';

  @override
  String get totalScheduled => 'Scheduled';

  @override
  String get nextMedicine => 'Next medicine';

  @override
  String get allDoneToday => 'You\'re all caught up for now.';

  @override
  String get todaySchedule => 'Today\'s schedule';

  @override
  String get stockAlerts => 'Stock alerts';

  @override
  String get refill => 'Refill';

  @override
  String get weeklyAdherence => 'This week';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get viewReports => 'View reports';

  @override
  String get offlineAccount => 'Offline account (data stays on this phone)';

  @override
  String get pdfReports => 'PDF report';

  @override
  String get pdfReportTitle => 'MediTrack Health Report';

  @override
  String get reportPeriod => 'Report period';

  @override
  String get generatedOn => 'Generated on';

  @override
  String get includeSections => 'Include in report';

  @override
  String get previewAndPrint => 'Preview & print';

  @override
  String get shareReport => 'Share report';

  @override
  String get statusColumn => 'Status';

  @override
  String get valueColumn => 'Value';

  @override
  String get relationshipColumn => 'Relationship';

  @override
  String get reactionColumn => 'Reaction';

  @override
  String get pdfFontNote =>
      'The first PDF needs an internet connection to download fonts. Without it, Bangla text may not display correctly in the PDF.';

  @override
  String get me => 'Me';

  @override
  String get familyMembers => 'Family members';

  @override
  String get addFamilyMember => 'Add family member';

  @override
  String get editFamilyMember => 'Edit';

  @override
  String get relationship => 'Relationship';

  @override
  String get relSpouse => 'Spouse';

  @override
  String get relParent => 'Parent';

  @override
  String get relChild => 'Child';

  @override
  String get relSibling => 'Sibling';

  @override
  String get relGrandparent => 'Grandparent';

  @override
  String get relFriend => 'Friend';

  @override
  String get relOther => 'Other';

  @override
  String get birthDateOptional => 'Birth date (optional)';

  @override
  String get caregiverConsent => 'Caregiver access (consent given)';

  @override
  String get caregiverConsentHint =>
      'Lets you get a missed-dose alert on this phone for this person.';

  @override
  String get consentTitle => 'Confirm consent';

  @override
  String get consentBody =>
      'Only turn this on if this person has agreed that you may track their medicines and receive a notification on your phone when they miss a dose. You can turn it off at any time.';

  @override
  String get iConfirm => 'I confirm';

  @override
  String get consentGiven => 'Consent given';

  @override
  String get viewProfile => 'View';

  @override
  String get viewingNow => 'Viewing';

  @override
  String get noFamilyMembers =>
      'No family members yet. Add someone to manage their medicines separately.';

  @override
  String get deleteMemberConfirm =>
      'Remove this family member? Their medicines will be hidden. Their intake history is kept.';

  @override
  String missedDoseTitle(String member) {
    return '$member missed a dose';
  }

  @override
  String get cloudSync => 'Cloud sync';

  @override
  String get syncNow => 'Sync now';

  @override
  String get retryFailed => 'Retry failed';

  @override
  String get syncDisabled =>
      'Cloud sync is off (offline account or Firebase not set up).';

  @override
  String get syncUpToDate => 'All changes are saved to the cloud.';

  @override
  String syncWaiting(String count) {
    return '$count changes waiting to upload';
  }

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncOffline =>
      'No internet. Your data is safe on this phone and will sync later.';

  @override
  String get syncError => 'Sync problem. It will retry automatically.';

  @override
  String get lastSynced => 'Last synced';

  @override
  String syncFailedChanges(String count) {
    return '$count changes failed several times';
  }

  @override
  String get addPhoto => 'Add photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get changePhoto => 'Change profile photo';

  @override
  String get imageTooLarge => 'This image is larger than 5 MB.';

  @override
  String get imageUnsupported => 'Only JPG, PNG or WebP images are allowed.';

  @override
  String get prescriptions => 'Prescriptions';

  @override
  String get addPrescription => 'Add prescription photo';

  @override
  String get noPrescriptions => 'No prescription photos yet.';

  @override
  String get uploadedToCloud => 'Saved to cloud';

  @override
  String get notUploaded => 'Only on this phone';

  @override
  String get medicineDetails => 'Medicine details';

  @override
  String get scheduleSummary => 'Schedule';

  @override
  String get stockSummary => 'Stock';

  @override
  String get noStockYet => 'Stock is not tracked for this medicine yet.';

  @override
  String get status => 'Status';

  @override
  String get onboardTitle1 => 'Never miss a dose';

  @override
  String get onboardBody1 =>
      'Set reminders for your medicines and mark them taken, snoozed or skipped right from the notification.';

  @override
  String get onboardTitle2 => 'See your progress';

  @override
  String get onboardBody2 =>
      'Track your history, stock and appointments, and share a PDF report with your healthcare professional.';

  @override
  String get onboardTitle3 => 'Care for your family';

  @override
  String get onboardBody3 =>
      'Keep separate medicine lists for family members, with their consent.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get firebaseNotConfiguredTitle => 'Cloud account is not set up';

  @override
  String get firebaseNotConfiguredBody =>
      'Registration, login and password reset need Firebase, which is not configured in this build. You can use MediTrack on this phone without an account (offline), and set up Firebase later (see docs/FIREBASE_SETUP.md).';

  @override
  String get technicalDetails => 'Technical details';

  @override
  String get reminderStatus => 'Reminder status';

  @override
  String get exactAlarmsOn => 'Exact alarms: allowed';

  @override
  String get exactAlarmsOff =>
      'Exact alarms: not allowed - reminders may be late. Tap “Allow exact alarms”.';

  @override
  String remindersScheduled(String count) {
    return '$count reminders scheduled';
  }

  @override
  String get refreshReminders => 'Refresh reminders';

  @override
  String get sendTestNow => 'Send test notification';

  @override
  String get testInOneMinute => 'Test reminder in 1 minute';

  @override
  String get testNotificationTitle => 'MediTrack test';

  @override
  String get testNotificationBody =>
      'If you can see and hear this, notifications work.';

  @override
  String get testScheduledMsg =>
      'Test reminder scheduled for 1 minute from now. You can lock the screen.';

  @override
  String get reminderProblem => 'Problem while scheduling reminders:';

  @override
  String get batteryHint =>
      'If reminders are late or missing, set MediTrack’s battery usage to Unrestricted in the phone settings.';
}
