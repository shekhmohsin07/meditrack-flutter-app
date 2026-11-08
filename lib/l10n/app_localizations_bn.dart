// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'মেডিট্র্যাক';

  @override
  String get navHome => 'হোম';

  @override
  String get navMedicines => 'ওষুধ';

  @override
  String get navSchedule => 'সময়সূচি';

  @override
  String get navReports => 'রিপোর্ট';

  @override
  String get navProfile => 'প্রোফাইল';

  @override
  String get settings => 'সেটিংস';

  @override
  String get darkMode => 'ডার্ক মোড';

  @override
  String get language => 'ভাষা';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা';

  @override
  String get comingSoon => 'এই স্ক্রিনটি পরবর্তী ব্যাচে তৈরি হবে।';

  @override
  String get healthDisclaimer =>
      'মেডিট্র্যাক একটি রিমাইন্ডার ও রেকর্ড রাখার অ্যাপ। এটি রোগ নির্ণয়, ওষুধ প্রেসক্রিপশন বা ডোজ পরামর্শ দেয় না। সবসময় আপনার স্বাস্থ্যসেবা পেশাদারের নির্দেশনা মেনে চলুন।';

  @override
  String get email => 'ইমেইল';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get confirmPassword => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get fullName => 'পূর্ণ নাম';

  @override
  String get login => 'লগ ইন';

  @override
  String get register => 'নিবন্ধন';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get sendResetLink => 'রিসেট লিংক পাঠান';

  @override
  String get resetLinkSent =>
      'পাসওয়ার্ড রিসেট ইমেইল পাঠানো হয়েছে। ইনবক্স দেখুন।';

  @override
  String get createAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get haveAccount => 'আগে থেকেই অ্যাকাউন্ট আছে? লগ ইন করুন';

  @override
  String get noAccount => 'অ্যাকাউন্ট নেই? নিবন্ধন করুন';

  @override
  String get continueOffline => 'অফলাইনে চালিয়ে যান (ক্লাউড ছাড়া)';

  @override
  String get logout => 'লগ আউট';

  @override
  String get requiredField => 'এই তথ্যটি আবশ্যক';

  @override
  String get invalidEmail => 'সঠিক ইমেইল ঠিকানা দিন';

  @override
  String get passwordTooShort => 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';

  @override
  String get passwordsDontMatch => 'পাসওয়ার্ড মেলেনি';

  @override
  String get addMedicine => 'ওষুধ যোগ করুন';

  @override
  String get editMedicine => 'ওষুধ সম্পাদনা';

  @override
  String get medicineName => 'ওষুধের নাম';

  @override
  String get dosageLabel => 'ডোজ (প্রেসক্রিপশন অনুযায়ী)';

  @override
  String get dosageHint =>
      'যেমন: ১টি ট্যাবলেট, ৫ মি.লি. - ডাক্তারের নির্দেশ অনুযায়ী';

  @override
  String get medicineType => 'ওষুধের ধরন';

  @override
  String get foodInstruction => 'খাবারের নির্দেশনা';

  @override
  String get startDate => 'শুরুর তারিখ';

  @override
  String get endDate => 'শেষ তারিখ (ঐচ্ছিক)';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get cancel => 'বাতিল';

  @override
  String get delete => 'মুছুন';

  @override
  String get deleteConfirm => 'এই ওষুধ মুছবেন? এটি ফেরানো যাবে না।';

  @override
  String get searchMedicines => 'ওষুধ খুঁজুন';

  @override
  String get noMedicines => 'এখনও কোনো ওষুধ নেই। যোগ করতে + চাপুন।';

  @override
  String get all => 'সব';

  @override
  String get active => 'চলমান';

  @override
  String get completed => 'সম্পন্ন';

  @override
  String get sortName => 'নাম অনুযায়ী';

  @override
  String get sortDate => 'শুরুর তারিখ অনুযায়ী';

  @override
  String get typeTablet => 'ট্যাবলেট';

  @override
  String get typeCapsule => 'ক্যাপসুল';

  @override
  String get typeSyrup => 'সিরাপ';

  @override
  String get typeInjection => 'ইনজেকশন';

  @override
  String get typeDrops => 'ড্রপ';

  @override
  String get typeCream => 'ক্রিম';

  @override
  String get typeOther => 'অন্যান্য';

  @override
  String get foodBefore => 'খাবারের আগে';

  @override
  String get foodAfter => 'খাবারের পরে';

  @override
  String get foodWith => 'খাবারের সাথে';

  @override
  String get foodEmpty => 'খালি পেটে';

  @override
  String get foodDoctor => 'ডাক্তারের নির্দেশ অনুযায়ী';

  @override
  String get endBeforeStart => 'শেষ তারিখ শুরুর তারিখের আগে হতে পারে না';

  @override
  String get loadError => 'কিছু ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get retry => 'আবার চেষ্টা';

  @override
  String get addSchedule => 'সময়সূচি যোগ করুন';

  @override
  String get editSchedule => 'সময়সূচি সম্পাদনা';

  @override
  String get manageSchedules => 'সময়সূচি পরিচালনা';

  @override
  String get selectMedicine => 'ওষুধ';

  @override
  String get frequency => 'পুনরাবৃত্তি';

  @override
  String get daily => 'প্রতিদিন';

  @override
  String get weekly => 'সাপ্তাহিক';

  @override
  String get custom => 'নির্দিষ্ট দিন';

  @override
  String get repeatDays => 'যেসব দিনে';

  @override
  String get reminderTimes => 'রিমাইন্ডারের সময়';

  @override
  String get addTime => 'সময় যোগ করুন';

  @override
  String get atLeastOneTime => 'কমপক্ষে একটি রিমাইন্ডার সময় দিন';

  @override
  String get selectDays => 'কমপক্ষে একটি দিন বেছে নিন';

  @override
  String get pause => 'বিরতি';

  @override
  String get resume => 'চালু করুন';

  @override
  String get paused => 'বিরতিতে';

  @override
  String get noDosesToday => 'এই দিনে কোনো ডোজ নির্ধারিত নেই।';

  @override
  String get noSchedules => 'এখনও কোনো সময়সূচি নেই। তৈরি করতে + চাপুন।';

  @override
  String get addMedicineFirst =>
      'আগে একটি ওষুধ যোগ করুন, তারপর সময়সূচি তৈরি করুন।';

  @override
  String get statusTaken => 'নেওয়া হয়েছে';

  @override
  String get statusMissed => 'বাদ পড়েছে';

  @override
  String get statusSkipped => 'এড়িয়ে গেছেন';

  @override
  String get statusSnoozed => 'স্থগিত';

  @override
  String get statusUpcoming => 'আসন্ন';

  @override
  String get statusDue => 'এখন সময়';

  @override
  String get markTaken => 'নেওয়া হয়েছে চিহ্নিত করুন';

  @override
  String get markSkipped => 'এড়িয়ে যান';

  @override
  String get notificationHistory => 'নোটিফিকেশন ইতিহাস';

  @override
  String get noNotifications => 'এখনও কোনো নোটিফিকেশন নেই।';

  @override
  String get enableNotifications => 'নোটিফিকেশন চালু করুন';

  @override
  String get allowExactAlarms => 'সঠিক সময়ের অ্যালার্ম অনুমতি দিন';

  @override
  String get notificationsOn => 'নোটিফিকেশন চালু আছে';

  @override
  String get notificationsOff => 'নোটিফিকেশন বন্ধ আছে';

  @override
  String notifTitle(String name) {
    return '$name খাওয়ার সময়';
  }

  @override
  String get actionTaken => 'নিয়েছি';

  @override
  String get actionSnooze => '১০ মিনিট পরে';

  @override
  String get actionSkip => 'এড়িয়ে যান';

  @override
  String get notifScheduled => 'নির্ধারিত';

  @override
  String get notifShown => 'দেখানো হয়েছে';

  @override
  String get notifCancelled => 'বাতিল';

  @override
  String get invalidNumber => 'সঠিক সংখ্যা দিন';

  @override
  String get inventory => 'স্টক ও মেয়াদ';

  @override
  String get setUpStock => 'স্টক সেট করুন';

  @override
  String get editStock => 'স্টক সম্পাদনা';

  @override
  String get initialQuantity => 'বর্তমানে আপনার কাছে যত আছে';

  @override
  String get remainingQuantity => 'অবশিষ্ট পরিমাণ';

  @override
  String get doseQuantity => 'প্রতি ডোজে ব্যবহৃত একক';

  @override
  String get lowStockThreshold => 'এই পরিমাণ বা তার কমে সতর্ক করুন';

  @override
  String get expiryDate => 'মেয়াদ শেষের তারিখ';

  @override
  String get adjustStock => 'স্টক সমন্বয়';

  @override
  String get adjustAmount => 'পরিমাণ';

  @override
  String get addStock => 'যোগ করুন (রিফিল)';

  @override
  String get removeStock => 'বাদ দিন';

  @override
  String get stockHistory => 'স্টকের ইতিহাস';

  @override
  String get noStockHistory => 'এখনও স্টকে কোনো পরিবর্তন নেই।';

  @override
  String get stockOk => 'স্টক আছে';

  @override
  String get stockLow => 'স্টক কম - রিফিলের কথা ভাবুন';

  @override
  String get stockOut => 'স্টক শেষ';

  @override
  String get expiringSoon => 'শীঘ্রই মেয়াদ শেষ';

  @override
  String get expired => 'মেয়াদ উত্তীর্ণ';

  @override
  String unitsLeft(String count) {
    return '$count বাকি';
  }

  @override
  String get reasonInitial => 'প্রাথমিক স্টক';

  @override
  String get reasonIntake => 'ডোজ নেওয়া হয়েছে';

  @override
  String get reasonRefill => 'রিফিল';

  @override
  String get reasonManual => 'হাতে পরিবর্তন';

  @override
  String get periodDay => 'দিন';

  @override
  String get periodWeek => 'সপ্তাহ';

  @override
  String get periodMonth => 'মাস';

  @override
  String get allMedicines => 'সব ওষুধ';

  @override
  String get adherence => 'নিয়ম মেনে চলা';

  @override
  String get adherenceNote =>
      'নিয়ম মেনে চলা = নেওয়া ডোজ ÷ (নেওয়া + বাদ পড়া + এড়িয়ে যাওয়া)। এটি শুধু আপনার রিমাইন্ডার রেকর্ড প্রতিফলিত করে, চিকিৎসা পরামর্শ নয়। চিকিৎসা নিয়ে আপনার স্বাস্থ্যসেবা পেশাদারের সাথে কথা বলুন।';

  @override
  String get dailyAdherence => 'দিনভিত্তিক নিয়ম মেনে চলা';

  @override
  String get noHistory => 'এই সময়ের জন্য কোনো রেকর্ড নেই।';

  @override
  String get tabHistory => 'ইতিহাস';

  @override
  String get tabStatistics => 'পরিসংখ্যান';

  @override
  String get tabCalendar => 'ক্যালেন্ডার';

  @override
  String get addAllergy => 'অ্যালার্জি যোগ করুন';

  @override
  String get editAllergy => 'অ্যালার্জি সম্পাদনা';

  @override
  String get allergies => 'অ্যালার্জি';

  @override
  String get allergyName => 'অ্যালার্জি (যেমন খাবার বা ওষুধ)';

  @override
  String get reactionOptional => 'প্রতিক্রিয়া (ঐচ্ছিক)';

  @override
  String get noAllergies => 'কোনো অ্যালার্জি নথিভুক্ত নেই।';

  @override
  String get addContact => 'যোগাযোগ যোগ করুন';

  @override
  String get editContact => 'যোগাযোগ সম্পাদনা';

  @override
  String get emergencyContacts => 'জরুরি যোগাযোগ';

  @override
  String get phoneNumber => 'ফোন নম্বর';

  @override
  String get invalidPhone => 'সঠিক ফোন নম্বর দিন';

  @override
  String get relationshipOptional => 'সম্পর্ক (ঐচ্ছিক)';

  @override
  String get noContacts => 'এখনও কোনো জরুরি যোগাযোগ নেই।';

  @override
  String get addAppointment => 'অ্যাপয়েন্টমেন্ট যোগ করুন';

  @override
  String get editAppointment => 'অ্যাপয়েন্টমেন্ট সম্পাদনা';

  @override
  String get appointments => 'ডাক্তারের অ্যাপয়েন্টমেন্ট';

  @override
  String get doctorName => 'ডাক্তারের নাম';

  @override
  String get hospitalOrClinic => 'হাসপাতাল বা ক্লিনিক (ঐচ্ছিক)';

  @override
  String get appointmentDate => 'তারিখ';

  @override
  String get appointmentTime => 'সময়';

  @override
  String get remindMe => 'মনে করিয়ে দিন';

  @override
  String minutesBefore(String minutes) {
    return '$minutes মিনিট আগে';
  }

  @override
  String get oneDayBefore => '১ দিন আগে';

  @override
  String get upcoming => 'আসন্ন';

  @override
  String get noUpcomingAppointments => 'কোনো আসন্ন অ্যাপয়েন্টমেন্ট নেই।';

  @override
  String get noAppointmentHistory => 'কোনো পুরনো অ্যাপয়েন্টমেন্ট নেই।';

  @override
  String get appointmentCompleted => 'সম্পন্ন';

  @override
  String get appointmentCancelled => 'বাতিল';

  @override
  String get markCompleted => 'সম্পন্ন চিহ্নিত করুন';

  @override
  String get cancelAppointment => 'অ্যাপয়েন্টমেন্ট বাতিল';

  @override
  String get reopenAppointment => 'আসন্ন হিসেবে চিহ্নিত করুন';

  @override
  String appointmentNotifTitle(String doctor) {
    return '$doctor-এর সাথে অ্যাপয়েন্টমেন্ট';
  }

  @override
  String get appointmentNotifBody =>
      'শীঘ্রই আপনার ডাক্তারের অ্যাপয়েন্টমেন্ট আছে।';

  @override
  String get healthRecords => 'স্বাস্থ্য রেকর্ড';

  @override
  String get addHealthRecord => 'স্বাস্থ্য রেকর্ড যোগ করুন';

  @override
  String get editHealthRecord => 'স্বাস্থ্য রেকর্ড সম্পাদনা';

  @override
  String get recordType => 'রেকর্ডের ধরন';

  @override
  String get typeBloodPressure => 'রক্তচাপ';

  @override
  String get typeBloodGlucose => 'রক্তে গ্লুকোজ';

  @override
  String get typeWeight => 'ওজন';

  @override
  String get typeHealthNote => 'স্বাস্থ্য নোট';

  @override
  String get typeMedicalHistory => 'চিকিৎসা ইতিহাস';

  @override
  String get systolic => 'সিস্টোলিক (ওপরের)';

  @override
  String get diastolic => 'ডায়াস্টোলিক (নিচের)';

  @override
  String get glucoseLevel => 'গ্লুকোজের মাত্রা';

  @override
  String get notes => 'নোট';

  @override
  String get notesOptional => 'নোট (ঐচ্ছিক)';

  @override
  String get dateAndTime => 'তারিখ ও সময়';

  @override
  String get allDates => 'সব তারিখ';

  @override
  String get noHealthRecords => 'এখনও কোনো রেকর্ড নেই। যোগ করতে + চাপুন।';

  @override
  String get outOfRange => 'মানটি যাচাই করুন - এটি টাইপের ভুল মনে হচ্ছে।';

  @override
  String get greetingMorning => 'শুভ সকাল';

  @override
  String get greetingAfternoon => 'শুভ অপরাহ্ন';

  @override
  String get greetingEvening => 'শুভ সন্ধ্যা';

  @override
  String get todaySummary => 'আজ';

  @override
  String get totalScheduled => 'নির্ধারিত';

  @override
  String get nextMedicine => 'পরবর্তী ওষুধ';

  @override
  String get allDoneToday => 'আপাতত সব ঠিক আছে।';

  @override
  String get todaySchedule => 'আজকের সময়সূচি';

  @override
  String get stockAlerts => 'স্টক সতর্কতা';

  @override
  String get refill => 'রিফিল';

  @override
  String get weeklyAdherence => 'এই সপ্তাহ';

  @override
  String get quickActions => 'দ্রুত কাজ';

  @override
  String get viewReports => 'রিপোর্ট দেখুন';

  @override
  String get offlineAccount => 'অফলাইন অ্যাকাউন্ট (তথ্য এই ফোনেই থাকে)';

  @override
  String get pdfReports => 'পিডিএফ রিপোর্ট';

  @override
  String get pdfReportTitle => 'মেডিট্র্যাক স্বাস্থ্য রিপোর্ট';

  @override
  String get reportPeriod => 'রিপোর্টের সময়কাল';

  @override
  String get generatedOn => 'তৈরির সময়';

  @override
  String get includeSections => 'রিপোর্টে যা থাকবে';

  @override
  String get previewAndPrint => 'প্রিভিউ ও প্রিন্ট';

  @override
  String get shareReport => 'রিপোর্ট শেয়ার করুন';

  @override
  String get statusColumn => 'অবস্থা';

  @override
  String get valueColumn => 'মান';

  @override
  String get relationshipColumn => 'সম্পর্ক';

  @override
  String get reactionColumn => 'প্রতিক্রিয়া';

  @override
  String get pdfFontNote =>
      'প্রথমবার পিডিএফ তৈরিতে ফন্ট ডাউনলোডের জন্য ইন্টারনেট লাগবে। ইন্টারনেট না থাকলে পিডিএফে বাংলা লেখা ঠিকভাবে নাও দেখাতে পারে।';

  @override
  String get me => 'আমি';

  @override
  String get familyMembers => 'পরিবারের সদস্য';

  @override
  String get addFamilyMember => 'পরিবারের সদস্য যোগ করুন';

  @override
  String get editFamilyMember => 'সম্পাদনা';

  @override
  String get relationship => 'সম্পর্ক';

  @override
  String get relSpouse => 'স্বামী/স্ত্রী';

  @override
  String get relParent => 'বাবা/মা';

  @override
  String get relChild => 'সন্তান';

  @override
  String get relSibling => 'ভাই/বোন';

  @override
  String get relGrandparent => 'দাদা-দাদি/নানা-নানি';

  @override
  String get relFriend => 'বন্ধু';

  @override
  String get relOther => 'অন্যান্য';

  @override
  String get birthDateOptional => 'জন্ম তারিখ (ঐচ্ছিক)';

  @override
  String get caregiverConsent =>
      'পরিচর্যাকারীর অ্যাক্সেস (সম্মতি দেওয়া হয়েছে)';

  @override
  String get caregiverConsentHint =>
      'এই ব্যক্তির ডোজ বাদ পড়লে এই ফোনে আপনি সতর্কতা পাবেন।';

  @override
  String get consentTitle => 'সম্মতি নিশ্চিত করুন';

  @override
  String get consentBody =>
      'এটি তখনই চালু করুন যখন এই ব্যক্তি রাজি হয়েছেন যে আপনি তার ওষুধ ট্র্যাক করবেন এবং ডোজ বাদ পড়লে আপনার ফোনে নোটিফিকেশন পাবেন। আপনি যেকোনো সময় এটি বন্ধ করতে পারবেন।';

  @override
  String get iConfirm => 'আমি নিশ্চিত করছি';

  @override
  String get consentGiven => 'সম্মতি দেওয়া হয়েছে';

  @override
  String get viewProfile => 'দেখুন';

  @override
  String get viewingNow => 'দেখা হচ্ছে';

  @override
  String get noFamilyMembers =>
      'এখনও কোনো সদস্য নেই। আলাদাভাবে ওষুধ পরিচালনা করতে কাউকে যোগ করুন।';

  @override
  String get deleteMemberConfirm =>
      'এই সদস্যকে সরাবেন? তার ওষুধগুলো লুকিয়ে যাবে। ওষুধ নেওয়ার ইতিহাস থাকবে।';

  @override
  String missedDoseTitle(String member) {
    return '$member-এর ডোজ বাদ পড়েছে';
  }

  @override
  String get cloudSync => 'ক্লাউড সিঙ্ক';

  @override
  String get syncNow => 'এখনই সিঙ্ক করুন';

  @override
  String get retryFailed => 'ব্যর্থগুলো আবার চেষ্টা করুন';

  @override
  String get syncDisabled =>
      'ক্লাউড সিঙ্ক বন্ধ (অফলাইন অ্যাকাউন্ট বা Firebase সেট করা হয়নি)।';

  @override
  String get syncUpToDate => 'সব পরিবর্তন ক্লাউডে সংরক্ষিত।';

  @override
  String syncWaiting(String count) {
    return '$countটি পরিবর্তন আপলোডের অপেক্ষায়';
  }

  @override
  String get syncing => 'সিঙ্ক হচ্ছে...';

  @override
  String get syncOffline =>
      'ইন্টারনেট নেই। আপনার তথ্য এই ফোনে নিরাপদ আছে, পরে সিঙ্ক হবে।';

  @override
  String get syncError => 'সিঙ্কে সমস্যা। স্বয়ংক্রিয়ভাবে আবার চেষ্টা হবে।';

  @override
  String get lastSynced => 'সর্বশেষ সিঙ্ক';

  @override
  String syncFailedChanges(String count) {
    return '$countটি পরিবর্তন কয়েকবার ব্যর্থ হয়েছে';
  }

  @override
  String get addPhoto => 'ছবি যোগ করুন';

  @override
  String get removePhoto => 'ছবি সরান';

  @override
  String get takePhoto => 'ছবি তুলুন';

  @override
  String get chooseFromGallery => 'গ্যালারি থেকে বাছুন';

  @override
  String get changePhoto => 'প্রোফাইল ছবি পরিবর্তন';

  @override
  String get imageTooLarge => 'ছবিটি ৫ এমবির বেশি বড়।';

  @override
  String get imageUnsupported => 'শুধু JPG, PNG বা WebP ছবি চলবে।';

  @override
  String get prescriptions => 'প্রেসক্রিপশন';

  @override
  String get addPrescription => 'প্রেসক্রিপশনের ছবি যোগ করুন';

  @override
  String get noPrescriptions => 'এখনও কোনো প্রেসক্রিপশনের ছবি নেই।';

  @override
  String get uploadedToCloud => 'ক্লাউডে সংরক্ষিত';

  @override
  String get notUploaded => 'শুধু এই ফোনে';

  @override
  String get medicineDetails => 'ওষুধের বিবরণ';

  @override
  String get scheduleSummary => 'সময়সূচি';

  @override
  String get stockSummary => 'স্টক';

  @override
  String get noStockYet => 'এই ওষুধের স্টক এখনও ট্র্যাক করা হচ্ছে না।';

  @override
  String get status => 'অবস্থা';

  @override
  String get onboardTitle1 => 'কখনো ডোজ মিস করবেন না';

  @override
  String get onboardBody1 =>
      'ওষুধের রিমাইন্ডার দিন এবং নোটিফিকেশন থেকেই নেওয়া, স্থগিত বা এড়িয়ে যাওয়া চিহ্নিত করুন।';

  @override
  String get onboardTitle2 => 'আপনার অগ্রগতি দেখুন';

  @override
  String get onboardBody2 =>
      'ইতিহাস, স্টক ও অ্যাপয়েন্টমেন্ট ট্র্যাক করুন এবং স্বাস্থ্যসেবা পেশাদারের সাথে পিডিএফ রিপোর্ট শেয়ার করুন।';

  @override
  String get onboardTitle3 => 'পরিবারের যত্ন নিন';

  @override
  String get onboardBody3 =>
      'সদস্যদের সম্মতি নিয়ে তাদের ওষুধের তালিকা আলাদাভাবে রাখুন।';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get next => 'পরবর্তী';

  @override
  String get getStarted => 'শুরু করুন';

  @override
  String get firebaseNotConfiguredTitle => 'ক্লাউড অ্যাকাউন্ট সেট করা নেই';

  @override
  String get firebaseNotConfiguredBody =>
      'নিবন্ধন, লগ ইন ও পাসওয়ার্ড রিসেটের জন্য Firebase দরকার, যা এই বিল্ডে কনফিগার করা নেই। আপনি অ্যাকাউন্ট ছাড়াই (অফলাইনে) এই ফোনে MediTrack ব্যবহার করতে পারেন, পরে Firebase সেট করতে পারবেন (docs/FIREBASE_SETUP.md দেখুন)।';

  @override
  String get technicalDetails => 'প্রযুক্তিগত বিবরণ';

  @override
  String get reminderStatus => 'রিমাইন্ডারের অবস্থা';

  @override
  String get exactAlarmsOn => 'সঠিক সময়ের অ্যালার্ম: অনুমোদিত';

  @override
  String get exactAlarmsOff =>
      'সঠিক সময়ের অ্যালার্ম: অনুমোদিত নয় - রিমাইন্ডার দেরিতে আসতে পারে। “সঠিক সময়ের অ্যালার্ম অনুমতি দিন” চাপুন।';

  @override
  String remindersScheduled(String count) {
    return '$countটি রিমাইন্ডার নির্ধারিত';
  }

  @override
  String get refreshReminders => 'রিমাইন্ডার রিফ্রেশ করুন';

  @override
  String get sendTestNow => 'টেস্ট নোটিফিকেশন পাঠান';

  @override
  String get testInOneMinute => '১ মিনিট পরে টেস্ট রিমাইন্ডার';

  @override
  String get testNotificationTitle => 'মেডিট্র্যাক টেস্ট';

  @override
  String get testNotificationBody =>
      'এটি দেখতে ও শুনতে পেলে নোটিফিকেশন কাজ করছে।';

  @override
  String get testScheduledMsg =>
      '১ মিনিট পরের জন্য টেস্ট রিমাইন্ডার সেট হয়েছে। স্ক্রিন লক করতে পারেন।';

  @override
  String get reminderProblem => 'রিমাইন্ডার সেট করতে সমস্যা:';

  @override
  String get batteryHint =>
      'রিমাইন্ডার দেরিতে বা না এলে ফোনের সেটিংসে মেডিট্র্যাকের ব্যাটারি ব্যবহার “Unrestricted” করুন।';
}
