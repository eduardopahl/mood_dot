import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @moodVeryHappy.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get moodVeryHappy;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moodHappy;

  /// No description provided for @moodNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get moodNeutral;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get moodSad;

  /// No description provided for @moodVerySad.
  ///
  /// In en, this message translates to:
  /// **'Very Bad'**
  String get moodVerySad;

  /// No description provided for @addMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Mood'**
  String get addMoodTitle;

  /// No description provided for @editMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Mood'**
  String get editMoodTitle;

  /// No description provided for @moodSaved.
  ///
  /// In en, this message translates to:
  /// **'Mood saved successfully!'**
  String get moodSaved;

  /// No description provided for @moodUpdated.
  ///
  /// In en, this message translates to:
  /// **'Mood updated successfully!'**
  String get moodUpdated;

  /// No description provided for @selectMood.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get selectMood;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get addNote;

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

  /// No description provided for @lastDays.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String lastDays(int days);

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @averageMood.
  ///
  /// In en, this message translates to:
  /// **'Average Mood'**
  String get averageMood;

  /// No description provided for @totalEntries.
  ///
  /// In en, this message translates to:
  /// **'Total Entries'**
  String get totalEntries;

  /// No description provided for @bestDay.
  ///
  /// In en, this message translates to:
  /// **'Best Day'**
  String get bestDay;

  /// No description provided for @worstDay.
  ///
  /// In en, this message translates to:
  /// **'Worst Day'**
  String get worstDay;

  /// No description provided for @moodDistribution.
  ///
  /// In en, this message translates to:
  /// **'Mood Distribution'**
  String get moodDistribution;

  /// No description provided for @weeklyPattern.
  ///
  /// In en, this message translates to:
  /// **'Weekly Pattern'**
  String get weeklyPattern;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @dailyReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminders'**
  String get dailyReminders;

  /// No description provided for @sendTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get sendTestNotification;

  /// No description provided for @resetAI.
  ///
  /// In en, this message translates to:
  /// **'Reset AI'**
  String get resetAI;

  /// No description provided for @resetAIDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove learned patterns of schedules and notification preferences'**
  String get resetAIDescription;

  /// No description provided for @resetIntelligentSystem.
  ///
  /// In en, this message translates to:
  /// **'Reset Intelligent System?'**
  String get resetIntelligentSystem;

  /// No description provided for @resetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will clear all learned data:\n\n• Preferred times for notifications\n• Identified mood patterns\n• AI personalization settings\n\nThis action cannot be undone.'**
  String get resetConfirmation;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @reminderNotifications.
  ///
  /// In en, this message translates to:
  /// **'Reminder Notifications'**
  String get reminderNotifications;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @resetLearning.
  ///
  /// In en, this message translates to:
  /// **'Reset Learning'**
  String get resetLearning;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @premiumUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Premium Upgrade'**
  String get premiumUpgrade;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads - \$0.99'**
  String get removeAds;

  /// No description provided for @premiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'No advertisements'**
  String get noAds;

  /// No description provided for @unlimitedEntries.
  ///
  /// In en, this message translates to:
  /// **'Unlimited mood entries'**
  String get unlimitedEntries;

  /// No description provided for @advancedStatistics.
  ///
  /// In en, this message translates to:
  /// **'Advanced statistics'**
  String get advancedStatistics;

  /// No description provided for @dataExport.
  ///
  /// In en, this message translates to:
  /// **'Export your data'**
  String get dataExport;

  /// No description provided for @buyPremium.
  ///
  /// In en, this message translates to:
  /// **'Buy Premium'**
  String get buyPremium;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @alreadyPremium.
  ///
  /// In en, this message translates to:
  /// **'You already have Premium!'**
  String get alreadyPremium;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to record your mood'**
  String get notificationBody;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'This is a test notification!'**
  String get testNotificationBody;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent successfully!'**
  String get testNotificationSent;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied'**
  String get permissionDenied;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Notification permission granted'**
  String get permissionGranted;

  /// No description provided for @gentleNotificationMessage1.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today? 😊'**
  String get gentleNotificationMessage1;

  /// No description provided for @gentleNotificationMessage2.
  ///
  /// In en, this message translates to:
  /// **'How about sharing your mood? 💭'**
  String get gentleNotificationMessage2;

  /// No description provided for @gentleNotificationMessage3.
  ///
  /// In en, this message translates to:
  /// **'Just a minute to reflect on your day? 🌟'**
  String get gentleNotificationMessage3;

  /// No description provided for @activeNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'MoodDot - Daily check-in! 📊'**
  String get activeNotificationTitle;

  /// No description provided for @activeNotificationMessage1.
  ///
  /// In en, this message translates to:
  /// **'Time to record your mood! 🎯'**
  String get activeNotificationMessage1;

  /// No description provided for @activeNotificationMessage2.
  ///
  /// In en, this message translates to:
  /// **'How\'s your energy today? ⚡'**
  String get activeNotificationMessage2;

  /// No description provided for @activeNotificationMessage3.
  ///
  /// In en, this message translates to:
  /// **'Let\'s reflect on this moment! 🤔'**
  String get activeNotificationMessage3;

  /// No description provided for @activeNotificationMessage4.
  ///
  /// In en, this message translates to:
  /// **'How about sharing how you feel? 🎭'**
  String get activeNotificationMessage4;

  /// No description provided for @standardNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling? 😊'**
  String get standardNotificationTitle;

  /// No description provided for @morningNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'How about recording how you started the day?'**
  String get morningNotificationMessage;

  /// No description provided for @afternoonNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'How is your afternoon going? Record your mood!'**
  String get afternoonNotificationMessage;

  /// No description provided for @eveningNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'How was your day? Don\'t forget to record your mood!'**
  String get eveningNotificationMessage;

  /// No description provided for @nightNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Before sleeping, how about reflecting on your day?'**
  String get nightNotificationMessage;

  /// No description provided for @gentleReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'MoodDot 💙'**
  String get gentleReminderTitle;

  /// No description provided for @testNotificationFinalTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Notification 🧪'**
  String get testNotificationFinalTitle;

  /// No description provided for @testNotificationFinalBody.
  ///
  /// In en, this message translates to:
  /// **'This is a test notification to check if it\'s working!'**
  String get testNotificationFinalBody;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get lastMonth;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello! 👋'**
  String get hello;

  /// No description provided for @howAreYouToday.
  ///
  /// In en, this message translates to:
  /// **'How are you today?'**
  String get howAreYouToday;

  /// No description provided for @noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecordsYet;

  /// No description provided for @tapToAddFirstMood.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record your first mood'**
  String get tapToAddFirstMood;

  /// No description provided for @showOnlyRecent.
  ///
  /// In en, this message translates to:
  /// **'Show only recent'**
  String get showOnlyRecent;

  /// No description provided for @viewFullHistory.
  ///
  /// In en, this message translates to:
  /// **'View full history'**
  String get viewFullHistory;

  /// No description provided for @showingFullHistory.
  ///
  /// In en, this message translates to:
  /// **'Showing full history'**
  String get showingFullHistory;

  /// No description provided for @showingLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Showing last 30 days'**
  String get showingLast30Days;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Oops, something went wrong'**
  String get errorOccurred;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// No description provided for @addNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get addNoteOptional;

  /// No description provided for @howWasYourDay.
  ///
  /// In en, this message translates to:
  /// **'How was your day? What happened?'**
  String get howWasYourDay;

  /// No description provided for @editingRecord.
  ///
  /// In en, this message translates to:
  /// **'Editing record'**
  String get editingRecord;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String createdAt(String date);

  /// No description provided for @updateMood.
  ///
  /// In en, this message translates to:
  /// **'Update Mood'**
  String get updateMood;

  /// No description provided for @saveMood.
  ///
  /// In en, this message translates to:
  /// **'Save Mood'**
  String get saveMood;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @weekdaysShort.
  ///
  /// In en, this message translates to:
  /// **'Sun,Mon,Tue,Wed,Thu,Fri,Sat'**
  String get weekdaysShort;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get last90Days;

  /// No description provided for @noDataToShow.
  ///
  /// In en, this message translates to:
  /// **'No data to show'**
  String get noDataToShow;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @last7DaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7DaysLabel;

  /// No description provided for @last30DaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30DaysLabel;

  /// No description provided for @last90DaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get last90DaysLabel;

  /// No description provided for @allTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTimeLabel;

  /// No description provided for @averageMoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Mood'**
  String get averageMoodLabel;

  /// No description provided for @totalEntriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Records'**
  String get totalEntriesLabel;

  /// No description provided for @moodDistributionLabel.
  ///
  /// In en, this message translates to:
  /// **'Mood Distribution'**
  String get moodDistributionLabel;

  /// No description provided for @weeklyPatternLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Week'**
  String get weeklyPatternLabel;

  /// No description provided for @currentWeek.
  ///
  /// In en, this message translates to:
  /// **'Current Week'**
  String get currentWeek;

  /// No description provided for @timeline30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get timeline30Days;

  /// No description provided for @veryBad.
  ///
  /// In en, this message translates to:
  /// **'Very Sad'**
  String get veryBad;

  /// No description provided for @bad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get bad;

  /// No description provided for @neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutral;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get good;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Happy'**
  String get veryGood;

  /// No description provided for @noDataToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No data to display'**
  String get noDataToDisplay;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @moodLevelUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get moodLevelUnknown;

  /// No description provided for @moodDotPremium.
  ///
  /// In en, this message translates to:
  /// **'MoodDot Premium'**
  String get moodDotPremium;

  /// No description provided for @supportDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Support development'**
  String get supportDevelopment;

  /// No description provided for @buyPremiumPrice.
  ///
  /// In en, this message translates to:
  /// **'Buy Premium - \$0.99'**
  String get buyPremiumPrice;

  /// No description provided for @premiumActivated.
  ///
  /// In en, this message translates to:
  /// **'Premium Activated!'**
  String get premiumActivated;

  /// No description provided for @thanksForSupport.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting MoodDot!'**
  String get thanksForSupport;

  /// No description provided for @premiumActivatedMessage.
  ///
  /// In en, this message translates to:
  /// **'All ads have been removed and you now have full premium access.'**
  String get premiumActivatedMessage;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get excellent;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'Purchase error. Please try again.'**
  String get purchaseError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedError(Object error);

  /// No description provided for @restoringPurchases.
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases...'**
  String get restoringPurchases;

  /// No description provided for @purchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases Restored!'**
  String get purchasesRestored;

  /// No description provided for @purchasesRestoredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your purchases have been successfully restored!\n\nPremium access has been reactivated.'**
  String get purchasesRestoredMessage;

  /// No description provided for @noPurchasesFound.
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found.'**
  String get noPurchasesFound;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Error restoring: {error}'**
  String restoreError(Object error);

  /// No description provided for @youHavePremiumAccess.
  ///
  /// In en, this message translates to:
  /// **'You have active premium access!'**
  String get youHavePremiumAccess;

  /// No description provided for @resetIntelligentSystemMessage.
  ///
  /// In en, this message translates to:
  /// **'Intelligent system reset successfully!'**
  String get resetIntelligentSystemMessage;

  /// No description provided for @aiResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Intelligent system reset successfully!'**
  String get aiResetSuccess;

  /// No description provided for @moodUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Mood updated successfully!'**
  String get moodUpdatedSuccess;

  /// No description provided for @moodSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Mood saved successfully!'**
  String get moodSavedSuccess;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSaving(Object error);

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @recordSingle.
  ///
  /// In en, this message translates to:
  /// **'record'**
  String get recordSingle;

  /// No description provided for @recordPlural.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get recordPlural;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again in a few moments'**
  String get tryAgainLater;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get deleteRecord;

  /// No description provided for @confirmDeleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this mood record?'**
  String get confirmDeleteRecord;

  /// No description provided for @recordDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record deleted successfully'**
  String get recordDeletedSuccess;

  /// No description provided for @trend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// No description provided for @overallAverage.
  ///
  /// In en, this message translates to:
  /// **'Overall Average'**
  String get overallAverage;

  /// No description provided for @hardestDay.
  ///
  /// In en, this message translates to:
  /// **'Hardest Day'**
  String get hardestDay;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get records;

  /// No description provided for @last30DaysData.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30DaysData;

  /// No description provided for @noDataLast30Days.
  ///
  /// In en, this message translates to:
  /// **'No data from last 30 days'**
  String get noDataLast30Days;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @improving.
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get improving;

  /// No description provided for @declining.
  ///
  /// In en, this message translates to:
  /// **'Declining'**
  String get declining;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No description provided for @consistentMood.
  ///
  /// In en, this message translates to:
  /// **'Consistent mood in the last 30 days. Variation: '**
  String get consistentMood;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
