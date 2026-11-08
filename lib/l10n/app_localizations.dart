import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MediTrack'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get navMedicines;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'This screen is built in the next batch.'**
  String get comingSoon;

  /// No description provided for @healthDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'MediTrack is a reminder and record-keeping app. It does not diagnose, prescribe or advise on dosage. Always follow your healthcare professional\'s instructions.'**
  String get healthDisclaimer;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get resetLinkSent;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get haveAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccount;

  /// No description provided for @continueOffline.
  ///
  /// In en, this message translates to:
  /// **'Continue offline (no cloud)'**
  String get continueOffline;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get addMedicine;

  /// No description provided for @editMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit medicine'**
  String get editMedicine;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine name'**
  String get medicineName;

  /// No description provided for @dosageLabel.
  ///
  /// In en, this message translates to:
  /// **'Dosage (as prescribed)'**
  String get dosageLabel;

  /// No description provided for @dosageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1 tablet, 5 ml - exactly as your doctor instructed'**
  String get dosageHint;

  /// No description provided for @medicineType.
  ///
  /// In en, this message translates to:
  /// **'Medicine type'**
  String get medicineType;

  /// No description provided for @foodInstruction.
  ///
  /// In en, this message translates to:
  /// **'Food instruction'**
  String get foodInstruction;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date (optional)'**
  String get endDate;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this medicine? This cannot be undone.'**
  String get deleteConfirm;

  /// No description provided for @searchMedicines.
  ///
  /// In en, this message translates to:
  /// **'Search medicines'**
  String get searchMedicines;

  /// No description provided for @noMedicines.
  ///
  /// In en, this message translates to:
  /// **'No medicines yet. Tap + to add one.'**
  String get noMedicines;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Sort by name'**
  String get sortName;

  /// No description provided for @sortDate.
  ///
  /// In en, this message translates to:
  /// **'Sort by start date'**
  String get sortDate;

  /// No description provided for @typeTablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get typeTablet;

  /// No description provided for @typeCapsule.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get typeCapsule;

  /// No description provided for @typeSyrup.
  ///
  /// In en, this message translates to:
  /// **'Syrup'**
  String get typeSyrup;

  /// No description provided for @typeInjection.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get typeInjection;

  /// No description provided for @typeDrops.
  ///
  /// In en, this message translates to:
  /// **'Drops'**
  String get typeDrops;

  /// No description provided for @typeCream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get typeCream;

  /// No description provided for @typeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get typeOther;

  /// No description provided for @foodBefore.
  ///
  /// In en, this message translates to:
  /// **'Before food'**
  String get foodBefore;

  /// No description provided for @foodAfter.
  ///
  /// In en, this message translates to:
  /// **'After food'**
  String get foodAfter;

  /// No description provided for @foodWith.
  ///
  /// In en, this message translates to:
  /// **'With food'**
  String get foodWith;

  /// No description provided for @foodEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty stomach'**
  String get foodEmpty;

  /// No description provided for @foodDoctor.
  ///
  /// In en, this message translates to:
  /// **'As instructed by doctor'**
  String get foodDoctor;

  /// No description provided for @endBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End date cannot be before start date'**
  String get endBeforeStart;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get loadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @addSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add schedule'**
  String get addSchedule;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit schedule'**
  String get editSchedule;

  /// No description provided for @manageSchedules.
  ///
  /// In en, this message translates to:
  /// **'Manage schedules'**
  String get manageSchedules;

  /// No description provided for @selectMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get selectMedicine;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get frequency;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom days'**
  String get custom;

  /// No description provided for @repeatDays.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get repeatDays;

  /// No description provided for @reminderTimes.
  ///
  /// In en, this message translates to:
  /// **'Reminder times'**
  String get reminderTimes;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// No description provided for @atLeastOneTime.
  ///
  /// In en, this message translates to:
  /// **'Add at least one reminder time'**
  String get atLeastOneTime;

  /// No description provided for @selectDays.
  ///
  /// In en, this message translates to:
  /// **'Select at least one day'**
  String get selectDays;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @noDosesToday.
  ///
  /// In en, this message translates to:
  /// **'No doses scheduled for this day.'**
  String get noDosesToday;

  /// No description provided for @noSchedules.
  ///
  /// In en, this message translates to:
  /// **'No schedules yet. Tap + to create one.'**
  String get noSchedules;

  /// No description provided for @addMedicineFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a medicine first, then create its schedule.'**
  String get addMedicineFirst;

  /// No description provided for @statusTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get statusTaken;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statusSkipped;

  /// No description provided for @statusSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed'**
  String get statusSnoozed;

  /// No description provided for @statusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get statusUpcoming;

  /// No description provided for @statusDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get statusDue;

  /// No description provided for @markTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark as taken'**
  String get markTaken;

  /// No description provided for @markSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get markSkipped;

  /// No description provided for @notificationHistory.
  ///
  /// In en, this message translates to:
  /// **'Notification history'**
  String get notificationHistory;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @allowExactAlarms.
  ///
  /// In en, this message translates to:
  /// **'Allow exact alarms'**
  String get allowExactAlarms;

  /// No description provided for @notificationsOn.
  ///
  /// In en, this message translates to:
  /// **'Notifications are enabled'**
  String get notificationsOn;

  /// No description provided for @notificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off'**
  String get notificationsOff;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to take {name}'**
  String notifTitle(String name);

  /// No description provided for @actionTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get actionTaken;

  /// No description provided for @actionSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze 10 min'**
  String get actionSnooze;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @notifScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get notifScheduled;

  /// No description provided for @notifShown.
  ///
  /// In en, this message translates to:
  /// **'Shown'**
  String get notifShown;

  /// No description provided for @notifCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get notifCancelled;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Stock & expiry'**
  String get inventory;

  /// No description provided for @setUpStock.
  ///
  /// In en, this message translates to:
  /// **'Set up stock'**
  String get setUpStock;

  /// No description provided for @editStock.
  ///
  /// In en, this message translates to:
  /// **'Edit stock'**
  String get editStock;

  /// No description provided for @initialQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity you have now'**
  String get initialQuantity;

  /// No description provided for @remainingQuantity.
  ///
  /// In en, this message translates to:
  /// **'Remaining quantity'**
  String get remainingQuantity;

  /// No description provided for @doseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Units used per dose'**
  String get doseQuantity;

  /// No description provided for @lowStockThreshold.
  ///
  /// In en, this message translates to:
  /// **'Warn me when stock is at or below'**
  String get lowStockThreshold;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiryDate;

  /// No description provided for @adjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust stock'**
  String get adjustStock;

  /// No description provided for @adjustAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get adjustAmount;

  /// No description provided for @addStock.
  ///
  /// In en, this message translates to:
  /// **'Add (refill)'**
  String get addStock;

  /// No description provided for @removeStock.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeStock;

  /// No description provided for @stockHistory.
  ///
  /// In en, this message translates to:
  /// **'Stock history'**
  String get stockHistory;

  /// No description provided for @noStockHistory.
  ///
  /// In en, this message translates to:
  /// **'No stock changes yet.'**
  String get noStockHistory;

  /// No description provided for @stockOk.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get stockOk;

  /// No description provided for @stockLow.
  ///
  /// In en, this message translates to:
  /// **'Low stock - consider a refill'**
  String get stockLow;

  /// No description provided for @stockOut.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get stockOut;

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get expiringSoon;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @unitsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String unitsLeft(String count);

  /// No description provided for @reasonInitial.
  ///
  /// In en, this message translates to:
  /// **'Initial stock'**
  String get reasonInitial;

  /// No description provided for @reasonIntake.
  ///
  /// In en, this message translates to:
  /// **'Dose taken'**
  String get reasonIntake;

  /// No description provided for @reasonRefill.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get reasonRefill;

  /// No description provided for @reasonManual.
  ///
  /// In en, this message translates to:
  /// **'Manual change'**
  String get reasonManual;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @allMedicines.
  ///
  /// In en, this message translates to:
  /// **'All medicines'**
  String get allMedicines;

  /// No description provided for @adherence.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherence;

  /// No description provided for @adherenceNote.
  ///
  /// In en, this message translates to:
  /// **'Adherence = taken doses ÷ (taken + missed + skipped). It only reflects your reminder records and is not medical advice. Talk to your healthcare professional about your treatment.'**
  String get adherenceNote;

  /// No description provided for @dailyAdherence.
  ///
  /// In en, this message translates to:
  /// **'Adherence by day'**
  String get dailyAdherence;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No records for this period.'**
  String get noHistory;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get tabStatistics;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @addAllergy.
  ///
  /// In en, this message translates to:
  /// **'Add allergy'**
  String get addAllergy;

  /// No description provided for @editAllergy.
  ///
  /// In en, this message translates to:
  /// **'Edit allergy'**
  String get editAllergy;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @allergyName.
  ///
  /// In en, this message translates to:
  /// **'Allergy (e.g. a food or medicine)'**
  String get allergyName;

  /// No description provided for @reactionOptional.
  ///
  /// In en, this message translates to:
  /// **'Reaction (optional)'**
  String get reactionOptional;

  /// No description provided for @noAllergies.
  ///
  /// In en, this message translates to:
  /// **'No allergies recorded.'**
  String get noAllergies;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get addContact;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get editContact;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts'**
  String get emergencyContacts;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get invalidPhone;

  /// No description provided for @relationshipOptional.
  ///
  /// In en, this message translates to:
  /// **'Relationship (optional)'**
  String get relationshipOptional;

  /// No description provided for @noContacts.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts yet.'**
  String get noContacts;

  /// No description provided for @addAppointment.
  ///
  /// In en, this message translates to:
  /// **'Add appointment'**
  String get addAppointment;

  /// No description provided for @editAppointment.
  ///
  /// In en, this message translates to:
  /// **'Edit appointment'**
  String get editAppointment;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Doctor appointments'**
  String get appointments;

  /// No description provided for @doctorName.
  ///
  /// In en, this message translates to:
  /// **'Doctor name'**
  String get doctorName;

  /// No description provided for @hospitalOrClinic.
  ///
  /// In en, this message translates to:
  /// **'Hospital or clinic (optional)'**
  String get hospitalOrClinic;

  /// No description provided for @appointmentDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get appointmentDate;

  /// No description provided for @appointmentTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get appointmentTime;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// No description provided for @minutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before'**
  String minutesBefore(String minutes);

  /// No description provided for @oneDayBefore.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get oneDayBefore;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @noUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments.'**
  String get noUpcomingAppointments;

  /// No description provided for @noAppointmentHistory.
  ///
  /// In en, this message translates to:
  /// **'No past appointments.'**
  String get noAppointmentHistory;

  /// No description provided for @appointmentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get appointmentCompleted;

  /// No description provided for @appointmentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get appointmentCancelled;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get markCompleted;

  /// No description provided for @cancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'Cancel appointment'**
  String get cancelAppointment;

  /// No description provided for @reopenAppointment.
  ///
  /// In en, this message translates to:
  /// **'Mark as upcoming'**
  String get reopenAppointment;

  /// No description provided for @appointmentNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment with {doctor}'**
  String appointmentNotifTitle(String doctor);

  /// No description provided for @appointmentNotifBody.
  ///
  /// In en, this message translates to:
  /// **'You have a doctor appointment soon.'**
  String get appointmentNotifBody;

  /// No description provided for @healthRecords.
  ///
  /// In en, this message translates to:
  /// **'Health records'**
  String get healthRecords;

  /// No description provided for @addHealthRecord.
  ///
  /// In en, this message translates to:
  /// **'Add health record'**
  String get addHealthRecord;

  /// No description provided for @editHealthRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit health record'**
  String get editHealthRecord;

  /// No description provided for @recordType.
  ///
  /// In en, this message translates to:
  /// **'Record type'**
  String get recordType;

  /// No description provided for @typeBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get typeBloodPressure;

  /// No description provided for @typeBloodGlucose.
  ///
  /// In en, this message translates to:
  /// **'Blood glucose'**
  String get typeBloodGlucose;

  /// No description provided for @typeWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get typeWeight;

  /// No description provided for @typeHealthNote.
  ///
  /// In en, this message translates to:
  /// **'Health note'**
  String get typeHealthNote;

  /// No description provided for @typeMedicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical history'**
  String get typeMedicalHistory;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic (upper)'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic (lower)'**
  String get diastolic;

  /// No description provided for @glucoseLevel.
  ///
  /// In en, this message translates to:
  /// **'Glucose level'**
  String get glucoseLevel;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get dateAndTime;

  /// No description provided for @allDates.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get allDates;

  /// No description provided for @noHealthRecords.
  ///
  /// In en, this message translates to:
  /// **'No records yet. Tap + to add one.'**
  String get noHealthRecords;

  /// No description provided for @outOfRange.
  ///
  /// In en, this message translates to:
  /// **'Please check this value - it looks like a typing mistake.'**
  String get outOfRange;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @todaySummary.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todaySummary;

  /// No description provided for @totalScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get totalScheduled;

  /// No description provided for @nextMedicine.
  ///
  /// In en, this message translates to:
  /// **'Next medicine'**
  String get nextMedicine;

  /// No description provided for @allDoneToday.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up for now.'**
  String get allDoneToday;

  /// No description provided for @todaySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s schedule'**
  String get todaySchedule;

  /// No description provided for @stockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Stock alerts'**
  String get stockAlerts;

  /// No description provided for @refill.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get refill;

  /// No description provided for @weeklyAdherence.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get weeklyAdherence;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @viewReports.
  ///
  /// In en, this message translates to:
  /// **'View reports'**
  String get viewReports;

  /// No description provided for @offlineAccount.
  ///
  /// In en, this message translates to:
  /// **'Offline account (data stays on this phone)'**
  String get offlineAccount;

  /// No description provided for @pdfReports.
  ///
  /// In en, this message translates to:
  /// **'PDF report'**
  String get pdfReports;

  /// No description provided for @pdfReportTitle.
  ///
  /// In en, this message translates to:
  /// **'MediTrack Health Report'**
  String get pdfReportTitle;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Report period'**
  String get reportPeriod;

  /// No description provided for @generatedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on'**
  String get generatedOn;

  /// No description provided for @includeSections.
  ///
  /// In en, this message translates to:
  /// **'Include in report'**
  String get includeSections;

  /// No description provided for @previewAndPrint.
  ///
  /// In en, this message translates to:
  /// **'Preview & print'**
  String get previewAndPrint;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'Share report'**
  String get shareReport;

  /// No description provided for @statusColumn.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusColumn;

  /// No description provided for @valueColumn.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueColumn;

  /// No description provided for @relationshipColumn.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationshipColumn;

  /// No description provided for @reactionColumn.
  ///
  /// In en, this message translates to:
  /// **'Reaction'**
  String get reactionColumn;

  /// No description provided for @pdfFontNote.
  ///
  /// In en, this message translates to:
  /// **'The first PDF needs an internet connection to download fonts. Without it, Bangla text may not display correctly in the PDF.'**
  String get pdfFontNote;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @familyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get familyMembers;

  /// No description provided for @addFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Add family member'**
  String get addFamilyMember;

  /// No description provided for @editFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editFamilyMember;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @relSpouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get relSpouse;

  /// No description provided for @relParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get relParent;

  /// No description provided for @relChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get relChild;

  /// No description provided for @relSibling.
  ///
  /// In en, this message translates to:
  /// **'Sibling'**
  String get relSibling;

  /// No description provided for @relGrandparent.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get relGrandparent;

  /// No description provided for @relFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get relFriend;

  /// No description provided for @relOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get relOther;

  /// No description provided for @birthDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Birth date (optional)'**
  String get birthDateOptional;

  /// No description provided for @caregiverConsent.
  ///
  /// In en, this message translates to:
  /// **'Caregiver access (consent given)'**
  String get caregiverConsent;

  /// No description provided for @caregiverConsentHint.
  ///
  /// In en, this message translates to:
  /// **'Lets you get a missed-dose alert on this phone for this person.'**
  String get caregiverConsentHint;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm consent'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In en, this message translates to:
  /// **'Only turn this on if this person has agreed that you may track their medicines and receive a notification on your phone when they miss a dose. You can turn it off at any time.'**
  String get consentBody;

  /// No description provided for @iConfirm.
  ///
  /// In en, this message translates to:
  /// **'I confirm'**
  String get iConfirm;

  /// No description provided for @consentGiven.
  ///
  /// In en, this message translates to:
  /// **'Consent given'**
  String get consentGiven;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewProfile;

  /// No description provided for @viewingNow.
  ///
  /// In en, this message translates to:
  /// **'Viewing'**
  String get viewingNow;

  /// No description provided for @noFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'No family members yet. Add someone to manage their medicines separately.'**
  String get noFamilyMembers;

  /// No description provided for @deleteMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this family member? Their medicines will be hidden. Their intake history is kept.'**
  String get deleteMemberConfirm;

  /// No description provided for @missedDoseTitle.
  ///
  /// In en, this message translates to:
  /// **'{member} missed a dose'**
  String missedDoseTitle(String member);

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get cloudSync;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @retryFailed.
  ///
  /// In en, this message translates to:
  /// **'Retry failed'**
  String get retryFailed;

  /// No description provided for @syncDisabled.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is off (offline account or Firebase not set up).'**
  String get syncDisabled;

  /// No description provided for @syncUpToDate.
  ///
  /// In en, this message translates to:
  /// **'All changes are saved to the cloud.'**
  String get syncUpToDate;

  /// No description provided for @syncWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} changes waiting to upload'**
  String syncWaiting(String count);

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet. Your data is safe on this phone and will sync later.'**
  String get syncOffline;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync problem. It will retry automatically.'**
  String get syncError;

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced'**
  String get lastSynced;

  /// No description provided for @syncFailedChanges.
  ///
  /// In en, this message translates to:
  /// **'{count} changes failed several times'**
  String syncFailedChanges(String count);

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changePhoto;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This image is larger than 5 MB.'**
  String get imageTooLarge;

  /// No description provided for @imageUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Only JPG, PNG or WebP images are allowed.'**
  String get imageUnsupported;

  /// No description provided for @prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get prescriptions;

  /// No description provided for @addPrescription.
  ///
  /// In en, this message translates to:
  /// **'Add prescription photo'**
  String get addPrescription;

  /// No description provided for @noPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'No prescription photos yet.'**
  String get noPrescriptions;

  /// No description provided for @uploadedToCloud.
  ///
  /// In en, this message translates to:
  /// **'Saved to cloud'**
  String get uploadedToCloud;

  /// No description provided for @notUploaded.
  ///
  /// In en, this message translates to:
  /// **'Only on this phone'**
  String get notUploaded;

  /// No description provided for @medicineDetails.
  ///
  /// In en, this message translates to:
  /// **'Medicine details'**
  String get medicineDetails;

  /// No description provided for @scheduleSummary.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleSummary;

  /// No description provided for @stockSummary.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockSummary;

  /// No description provided for @noStockYet.
  ///
  /// In en, this message translates to:
  /// **'Stock is not tracked for this medicine yet.'**
  String get noStockYet;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Never miss a dose'**
  String get onboardTitle1;

  /// No description provided for @onboardBody1.
  ///
  /// In en, this message translates to:
  /// **'Set reminders for your medicines and mark them taken, snoozed or skipped right from the notification.'**
  String get onboardBody1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'See your progress'**
  String get onboardTitle2;

  /// No description provided for @onboardBody2.
  ///
  /// In en, this message translates to:
  /// **'Track your history, stock and appointments, and share a PDF report with your healthcare professional.'**
  String get onboardBody2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Care for your family'**
  String get onboardTitle3;

  /// No description provided for @onboardBody3.
  ///
  /// In en, this message translates to:
  /// **'Keep separate medicine lists for family members, with their consent.'**
  String get onboardBody3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @firebaseNotConfiguredTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud account is not set up'**
  String get firebaseNotConfiguredTitle;

  /// No description provided for @firebaseNotConfiguredBody.
  ///
  /// In en, this message translates to:
  /// **'Registration, login and password reset need Firebase, which is not configured in this build. You can use MediTrack on this phone without an account (offline), and set up Firebase later (see docs/FIREBASE_SETUP.md).'**
  String get firebaseNotConfiguredBody;

  /// No description provided for @technicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Technical details'**
  String get technicalDetails;

  /// No description provided for @reminderStatus.
  ///
  /// In en, this message translates to:
  /// **'Reminder status'**
  String get reminderStatus;

  /// No description provided for @exactAlarmsOn.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms: allowed'**
  String get exactAlarmsOn;

  /// No description provided for @exactAlarmsOff.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms: not allowed - reminders may be late. Tap “Allow exact alarms”.'**
  String get exactAlarmsOff;

  /// No description provided for @remindersScheduled.
  ///
  /// In en, this message translates to:
  /// **'{count} reminders scheduled'**
  String remindersScheduled(String count);

  /// No description provided for @refreshReminders.
  ///
  /// In en, this message translates to:
  /// **'Refresh reminders'**
  String get refreshReminders;

  /// No description provided for @sendTestNow.
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get sendTestNow;

  /// No description provided for @testInOneMinute.
  ///
  /// In en, this message translates to:
  /// **'Test reminder in 1 minute'**
  String get testInOneMinute;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'MediTrack test'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'If you can see and hear this, notifications work.'**
  String get testNotificationBody;

  /// No description provided for @testScheduledMsg.
  ///
  /// In en, this message translates to:
  /// **'Test reminder scheduled for 1 minute from now. You can lock the screen.'**
  String get testScheduledMsg;

  /// No description provided for @reminderProblem.
  ///
  /// In en, this message translates to:
  /// **'Problem while scheduling reminders:'**
  String get reminderProblem;

  /// No description provided for @batteryHint.
  ///
  /// In en, this message translates to:
  /// **'If reminders are late or missing, set MediTrack’s battery usage to Unrestricted in the phone settings.'**
  String get batteryHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
