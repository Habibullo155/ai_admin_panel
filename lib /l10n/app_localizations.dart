import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Glass Chat'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get commonLogout;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to AI Chat'**
  String get authSignInTitle;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordHint;

  /// No description provided for @authRepeatPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get authRepeatPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authRegisterButton;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginButton;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authHaveAccount;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Sign up'**
  String get authNoAccount;

  /// No description provided for @authPasswordLengthOk.
  ///
  /// In en, this message translates to:
  /// **'Password length is fine'**
  String get authPasswordLengthOk;

  /// Подсказка о минимальной длине пароля при регистрации
  ///
  /// In en, this message translates to:
  /// **'At least {minLength} characters ({length} entered)'**
  String authPasswordLengthHint(int minLength, int length);

  /// No description provided for @authPasswordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get authPasswordsMatch;

  /// No description provided for @authPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get authPasswordsMismatch;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the email your account is registered with — we\'ll send a reset code.'**
  String get forgotPasswordEmailPrompt;

  /// No description provided for @forgotPasswordSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get forgotPasswordSendCode;

  /// No description provided for @forgotPasswordCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'If that email is registered, a reset code has been sent to it. Check your inbox (and spam folder) and enter the code below along with your new password.'**
  String get forgotPasswordCheckEmail;

  /// No description provided for @forgotPasswordHaveCode.
  ///
  /// In en, this message translates to:
  /// **'I have a code'**
  String get forgotPasswordHaveCode;

  /// No description provided for @forgotPasswordResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get forgotPasswordResend;

  /// No description provided for @forgotPasswordCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get forgotPasswordCodeTitle;

  /// No description provided for @forgotPasswordCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get forgotPasswordCodeHint;

  /// No description provided for @forgotPasswordNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get forgotPasswordNewPasswordHint;

  /// No description provided for @forgotPasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get forgotPasswordSubmit;

  /// No description provided for @forgotPasswordDone.
  ///
  /// In en, this message translates to:
  /// **'Password changed. You can now sign in with your new password.'**
  String get forgotPasswordDone;

  /// No description provided for @lockScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'App is locked'**
  String get lockScreenTitle;

  /// No description provided for @lockScreenFailedHint.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify — try again.'**
  String get lockScreenFailedHint;

  /// No description provided for @lockScreenPrompt.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to continue.'**
  String get lockScreenPrompt;

  /// No description provided for @lockScreenUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockScreenUnlockButton;

  /// No description provided for @lockScreenUsePassword.
  ///
  /// In en, this message translates to:
  /// **'Use password instead'**
  String get lockScreenUsePassword;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailPromptGeneric.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your email at sign-up.'**
  String get verifyEmailPromptGeneric;

  /// Подсказка с адресом почты, на который отправлен код
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {email}.'**
  String verifyEmailPromptWithEmail(String email);

  /// No description provided for @verifyEmailCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get verifyEmailCodeHint;

  /// No description provided for @verifyEmailResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get verifyEmailResendButton;

  /// No description provided for @verifyEmailSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyEmailSubmitButton;

  /// No description provided for @verifyEmailResentMessage.
  ///
  /// In en, this message translates to:
  /// **'Code resent — check your inbox.'**
  String get verifyEmailResentMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsBackgroundColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get settingsBackgroundColorLabel;

  /// No description provided for @settingsSectionPerformance.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE'**
  String get settingsSectionPerformance;

  /// No description provided for @settingsPerformanceModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery saver mode'**
  String get settingsPerformanceModeLabel;

  /// No description provided for @settingsPerformanceModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Turns off the animated background and glass blur throughout the app. Worth enabling if your phone is weak, laggy, or overheating — most devices don\'t need this.'**
  String get settingsPerformanceModeDescription;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsSoundOnMessage.
  ///
  /// In en, this message translates to:
  /// **'Sound on new message'**
  String get settingsSoundOnMessage;

  /// No description provided for @settingsVibrationOnMessage.
  ///
  /// In en, this message translates to:
  /// **'Vibration on new message'**
  String get settingsVibrationOnMessage;

  /// No description provided for @settingsSectionVoice.
  ///
  /// In en, this message translates to:
  /// **'VOICE'**
  String get settingsSectionVoice;

  /// No description provided for @settingsVoiceButtonsInChat.
  ///
  /// In en, this message translates to:
  /// **'Voice buttons in chat'**
  String get settingsVoiceButtonsInChat;

  /// No description provided for @settingsVoiceAndSpeechRecognition.
  ///
  /// In en, this message translates to:
  /// **'Voice selection and speech recognition'**
  String get settingsVoiceAndSpeechRecognition;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsBiometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric sign-in'**
  String get settingsBiometricLogin;

  /// No description provided for @settingsBiometricNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Biometrics (Face ID/fingerprint) isn\'t set up on this device — enable it in your device settings if you\'d like to use it here.'**
  String get settingsBiometricNotSupported;

  /// No description provided for @settingsSectionReminders.
  ///
  /// In en, this message translates to:
  /// **'REMINDERS'**
  String get settingsSectionReminders;

  /// No description provided for @settingsReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Once a day, at a time you choose (e.g. when you\'re usually home) — a gentle nudge to check in if you feel like talking.'**
  String get settingsReminderDescription;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get settingsDailyReminder;

  /// No description provided for @settingsReminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get settingsReminderTimeLabel;

  /// No description provided for @settingsReminderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications aren\'t allowed — enable them for this app in your device settings.'**
  String get settingsReminderPermissionDenied;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get settingsSectionAccount;

  /// No description provided for @settingsLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogoutButton;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get settingsSectionAbout;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get settingsAppVersion;

  /// No description provided for @settingsModelInfo.
  ///
  /// In en, this message translates to:
  /// **'Default model: gemma4:e2b via local Ollama.'**
  String get settingsModelInfo;

  /// No description provided for @settingsSectionDangerZone.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get settingsSectionDangerZone;

  /// No description provided for @settingsDeleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccountButton;

  /// No description provided for @settingsDeleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get settingsDeleteAccountDialogTitle;

  /// No description provided for @settingsDeleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This is irreversible: your account, support history, and usage stats will be permanently deleted. Chat history on this device will remain — it was never stored on the server, and you can delete it separately.'**
  String get settingsDeleteAccountWarning;

  /// No description provided for @settingsConfirmWithPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm with your password'**
  String get settingsConfirmWithPassword;

  /// No description provided for @settingsDeleteForeverButton.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get settingsDeleteForeverButton;

  /// No description provided for @chatNoSoundsUploaded.
  ///
  /// In en, this message translates to:
  /// **'No sounds uploaded yet — the admin hasn\'t added any.'**
  String get chatNoSoundsUploaded;

  /// No description provided for @chatStopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get chatStopButton;

  /// No description provided for @chatRoleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get chatRoleUser;

  /// No description provided for @chatRoleAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get chatRoleAi;

  /// No description provided for @chatMigraineLabel.
  ///
  /// In en, this message translates to:
  /// **'Migraine or heavy fatigue'**
  String get chatMigraineLabel;

  /// No description provided for @chatWhatDoYouNeedNow.
  ///
  /// In en, this message translates to:
  /// **'What do you need right now?'**
  String get chatWhatDoYouNeedNow;

  /// No description provided for @chatTakeTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a test'**
  String get chatTakeTestTitle;

  /// No description provided for @chatTakeTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A questionnaire — we\'ll discuss the result right here'**
  String get chatTakeTestSubtitle;

  /// No description provided for @chatWhichQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Which questionnaire?'**
  String get chatWhichQuestionnaire;

  /// No description provided for @chatPhq9Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Depression symptoms, 9 questions'**
  String get chatPhq9Subtitle;

  /// No description provided for @chatGad7Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Anxiety symptoms, 7 questions'**
  String get chatGad7Subtitle;

  /// No description provided for @chatAsrsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ADHD screening, 6 questions'**
  String get chatAsrsSubtitle;

  /// No description provided for @chatOtherTestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Other tests'**
  String get chatOtherTestsTitle;

  /// No description provided for @chatOtherTestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Questionnaires created by the team'**
  String get chatOtherTestsSubtitle;

  /// No description provided for @chatCallHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Call in a real person for help?'**
  String get chatCallHelpTitle;

  /// No description provided for @chatCallHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'A doctor or specialist from the team will join. This isn\'t a substitute for emergency services — if the situation needs urgent medical help, call your local emergency number.'**
  String get chatCallHelpDescription;

  /// No description provided for @chatPrepareSummaryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Prepare a short summary of your conversation with the AI for the doctor (not the whole chat), so you don\'t have to explain everything again?'**
  String get chatPrepareSummaryQuestion;

  /// No description provided for @chatYesPrepareSummary.
  ///
  /// In en, this message translates to:
  /// **'Yes, prepare a summary'**
  String get chatYesPrepareSummary;

  /// No description provided for @chatNoDontShow.
  ///
  /// In en, this message translates to:
  /// **'No, don\'t show it'**
  String get chatNoDontShow;

  /// No description provided for @chatCallButton.
  ///
  /// In en, this message translates to:
  /// **'Call for help'**
  String get chatCallButton;

  /// No description provided for @chatCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get chatCloseTooltip;

  /// No description provided for @chatNewChatTitle.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get chatNewChatTitle;

  /// No description provided for @chatDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The AI can make mistakes. Double-check important information yourself.'**
  String get chatDisclaimer;

  /// No description provided for @chatVerifyEmailBanner.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get chatVerifyEmailBanner;

  /// No description provided for @chatMuteBackgroundSound.
  ///
  /// In en, this message translates to:
  /// **'Turn off background sound'**
  String get chatMuteBackgroundSound;

  /// No description provided for @chatUnmuteBackgroundSound.
  ///
  /// In en, this message translates to:
  /// **'Turn on background sound'**
  String get chatUnmuteBackgroundSound;

  /// No description provided for @chatMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get chatMenuTooltip;

  /// No description provided for @chatMenuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get chatMenuProfile;

  /// No description provided for @chatMenuWellbeing.
  ///
  /// In en, this message translates to:
  /// **'Wellbeing'**
  String get chatMenuWellbeing;

  /// No description provided for @chatMenuSleepMusic.
  ///
  /// In en, this message translates to:
  /// **'Sleep music'**
  String get chatMenuSleepMusic;

  /// No description provided for @chatMenuSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get chatMenuSubscription;

  /// No description provided for @chatMenuMyReports.
  ///
  /// In en, this message translates to:
  /// **'My reports'**
  String get chatMenuMyReports;

  /// No description provided for @chatMenuLiveHelp.
  ///
  /// In en, this message translates to:
  /// **'Live help'**
  String get chatMenuLiveHelp;

  /// No description provided for @chatMenuOperatorCabinet.
  ///
  /// In en, this message translates to:
  /// **'Operator dashboard'**
  String get chatMenuOperatorCabinet;

  /// No description provided for @chatMenuSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get chatMenuSupport;

  /// No description provided for @chatMenuBlog.
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get chatMenuBlog;

  /// No description provided for @chatSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'Explain quantum physics in simple terms'**
  String get chatSuggestion1;

  /// No description provided for @chatSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'Write a weekly workout plan'**
  String get chatSuggestion2;

  /// No description provided for @chatSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'Help me name my project'**
  String get chatSuggestion3;

  /// No description provided for @chatSuggestion4.
  ///
  /// In en, this message translates to:
  /// **'How do I improve my Dart code?'**
  String get chatSuggestion4;

  /// No description provided for @chatWhatCanIHelpWith.
  ///
  /// In en, this message translates to:
  /// **'What can I help with today?'**
  String get chatWhatCanIHelpWith;

  /// No description provided for @aiModeSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get aiModeSupportTitle;

  /// No description provided for @aiModeSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Just be there in the conversation'**
  String get aiModeSupportSubtitle;

  /// No description provided for @aiModeSupportOpener.
  ///
  /// In en, this message translates to:
  /// **'I need some support right now — just be here with me in the conversation and cheer me up.'**
  String get aiModeSupportOpener;

  /// No description provided for @aiModeListenTitle.
  ///
  /// In en, this message translates to:
  /// **'Just listen'**
  String get aiModeListenTitle;

  /// No description provided for @aiModeListenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No need to jump to advice'**
  String get aiModeListenSubtitle;

  /// No description provided for @aiModeListenOpener.
  ///
  /// In en, this message translates to:
  /// **'I just need to talk it out — listen, no need to give advice right away.'**
  String get aiModeListenOpener;

  /// No description provided for @aiModeBreakupTitle.
  ///
  /// In en, this message translates to:
  /// **'Divorce or breakup'**
  String get aiModeBreakupTitle;

  /// No description provided for @aiModeBreakupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation about it'**
  String get aiModeBreakupSubtitle;

  /// No description provided for @aiModeBreakupOpener.
  ///
  /// In en, this message translates to:
  /// **'I\'m going through a divorce or breakup right now, and it\'s hard to cope. Can you support me while I talk about it?'**
  String get aiModeBreakupOpener;

  /// No description provided for @aiModeGriefTitle.
  ///
  /// In en, this message translates to:
  /// **'Loss and grief'**
  String get aiModeGriefTitle;

  /// No description provided for @aiModeGriefSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation about it'**
  String get aiModeGriefSubtitle;

  /// No description provided for @aiModeGriefOpener.
  ///
  /// In en, this message translates to:
  /// **'I recently lost someone close to me, and I\'d like to talk to someone about it.'**
  String get aiModeGriefOpener;

  /// No description provided for @aiModeJobLossTitle.
  ///
  /// In en, this message translates to:
  /// **'Job loss or major life change'**
  String get aiModeJobLossTitle;

  /// No description provided for @aiModeJobLossSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation about it'**
  String get aiModeJobLossSubtitle;

  /// No description provided for @aiModeJobLossOpener.
  ///
  /// In en, this message translates to:
  /// **'I\'m going through a tough time — I lost my job or a sudden change happened in my life, and it\'s hard to deal with. Can you support me while I talk about it?'**
  String get aiModeJobLossOpener;

  /// No description provided for @aiModeRationalizerTitle.
  ///
  /// In en, this message translates to:
  /// **'Thought checker'**
  String get aiModeRationalizerTitle;

  /// No description provided for @aiModeRationalizerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Break down an anxious thought using CBT'**
  String get aiModeRationalizerSubtitle;

  /// No description provided for @aiModeRationalizerOpener.
  ///
  /// In en, this message translates to:
  /// **'I have an anxious thought that won\'t leave me alone. Help me break it down using CBT — ask me guiding questions one at a time (for example, what evidence supports this thought, what\'s the worst that could happen and how likely is it) so I can see the situation more clearly.'**
  String get aiModeRationalizerOpener;

  /// No description provided for @profileBirthDateHelpText.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get profileBirthDateHelpText;

  /// Возраст в годах с правильным склонением
  ///
  /// In en, this message translates to:
  /// **'{age, plural, one {{age} year} other {{age} years}}'**
  String profileAgeYears(int age);

  /// No description provided for @profileTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profileTakePhoto;

  /// No description provided for @profileChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profileChooseFromGallery;

  /// No description provided for @profileDeletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get profileDeletePhoto;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get profileNoData;

  /// No description provided for @profileSectionPersonal.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL'**
  String get profileSectionPersonal;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullName;

  /// No description provided for @profileNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'not specified'**
  String get profileNotSpecified;

  /// No description provided for @profileBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get profileBirthDate;

  /// No description provided for @profileHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get profileHobbies;

  /// No description provided for @profileEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get profileEmergencyContact;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get profileSectionAccount;

  /// No description provided for @profileRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRole;

  /// No description provided for @profileRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get profileRoleAdmin;

  /// No description provided for @profileRoleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profileRoleUser;

  /// No description provided for @profileAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get profileAccountCreated;

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditButton;

  /// No description provided for @profileChangePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePasswordButton;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get profileEditTitle;

  /// No description provided for @profileEditHint.
  ///
  /// In en, this message translates to:
  /// **'All fields are optional — leave blank to clear.'**
  String get profileEditHint;

  /// No description provided for @profileEmergencySectionLabel.
  ///
  /// In en, this message translates to:
  /// **'IN CASE OF EMERGENCY'**
  String get profileEmergencySectionLabel;

  /// No description provided for @profileEmergencyContactHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Mom, +1 555 123-4567'**
  String get profileEmergencyContactHint;

  /// No description provided for @profileLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogoutButton;

  /// No description provided for @profilePasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'The new password must be at least 8 characters long.'**
  String get profilePasswordTooShort;

  /// No description provided for @profilePasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get profilePasswordsMismatch;

  /// No description provided for @profileChangePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePasswordTitle;

  /// No description provided for @profileCurrentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profileCurrentPasswordLabel;

  /// No description provided for @profileNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get profileNewPasswordLabel;

  /// No description provided for @profileRepeatNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get profileRepeatNewPasswordLabel;

  /// No description provided for @profileChangeEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get profileChangeEmailTitle;

  /// No description provided for @profileCurrentEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Currently: {email}'**
  String profileCurrentEmailLabel(String email);

  /// No description provided for @profileNewEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'New address'**
  String get profileNewEmailLabel;

  /// No description provided for @profileCodeSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {email}. Enter it below to complete the change.'**
  String profileCodeSentMessage(String email);

  /// No description provided for @profileCodeFromEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get profileCodeFromEmailLabel;

  /// No description provided for @profileSendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get profileSendCodeButton;

  /// No description provided for @sidebarCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get sidebarCalendarTitle;

  /// No description provided for @sidebarCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire results by day'**
  String get sidebarCalendarSubtitle;

  /// No description provided for @sidebarWellbeingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a test, situational support'**
  String get sidebarWellbeingSubtitle;

  /// No description provided for @sidebarCallHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Call for help'**
  String get sidebarCallHelpTitle;

  /// No description provided for @sidebarCallHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A doctor or specialist will join'**
  String get sidebarCallHelpSubtitle;

  /// No description provided for @sidebarHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get sidebarHistoryLabel;

  /// No description provided for @sidebarNoConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get sidebarNoConversations;

  /// No description provided for @sidebarRenameChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename chat'**
  String get sidebarRenameChatTitle;

  /// No description provided for @sidebarDeleteChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete chat?'**
  String get sidebarDeleteChatTitle;

  /// No description provided for @sidebarDeleteChatBody.
  ///
  /// In en, this message translates to:
  /// **'The conversation \"{title}\" will be deleted permanently.'**
  String sidebarDeleteChatBody(String title);

  /// No description provided for @sidebarEmptyConversation.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get sidebarEmptyConversation;

  /// No description provided for @crisisResourcesDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'If you feel like talking to someone'**
  String get crisisResourcesDefaultTitle;

  /// No description provided for @crisisResourcesBody.
  ///
  /// In en, this message translates to:
  /// **'• Emergency psychological support for adults and children in Russia, 24/7 and free: 8-800-100-49-94\n• Child and teen helpline (Russia): 8-800-2000-122 (short number: 124)\n\nIf you\'re not in Russia, search for a local crisis line for your country; in the US and Canada you can call or text 988.'**
  String get crisisResourcesBody;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get navSleep;

  /// No description provided for @navWellbeing.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get navWellbeing;

  /// No description provided for @sleepMusicTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep music'**
  String get sleepMusicTitle;

  /// No description provided for @sleepMusicNoneUploaded.
  ///
  /// In en, this message translates to:
  /// **'No music uploaded yet — the admin hasn\'t added any.'**
  String get sleepMusicNoneUploaded;

  /// No description provided for @customTestListTitle.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get customTestListTitle;

  /// No description provided for @customTestListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tests available yet.'**
  String get customTestListEmpty;

  /// No description provided for @blogTitle.
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get blogTitle;

  /// No description provided for @blogListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No posts yet — check back later.'**
  String get blogListEmpty;

  /// No description provided for @who5Q1.
  ///
  /// In en, this message translates to:
  /// **'I have felt cheerful and in good spirits'**
  String get who5Q1;

  /// No description provided for @who5Q2.
  ///
  /// In en, this message translates to:
  /// **'I have felt calm and relaxed'**
  String get who5Q2;

  /// No description provided for @who5Q3.
  ///
  /// In en, this message translates to:
  /// **'I have felt active and vigorous'**
  String get who5Q3;

  /// No description provided for @who5Q4.
  ///
  /// In en, this message translates to:
  /// **'I woke up feeling fresh and rested'**
  String get who5Q4;

  /// No description provided for @who5Q5.
  ///
  /// In en, this message translates to:
  /// **'My daily life has been filled with things that interest me'**
  String get who5Q5;

  /// No description provided for @who5ScaleAllTime.
  ///
  /// In en, this message translates to:
  /// **'All of the time'**
  String get who5ScaleAllTime;

  /// No description provided for @who5ScaleMostTime.
  ///
  /// In en, this message translates to:
  /// **'Most of the time'**
  String get who5ScaleMostTime;

  /// No description provided for @who5ScaleMoreThanHalf.
  ///
  /// In en, this message translates to:
  /// **'More than half of the time'**
  String get who5ScaleMoreThanHalf;

  /// No description provided for @who5ScaleLessThanHalf.
  ///
  /// In en, this message translates to:
  /// **'Less than half of the time'**
  String get who5ScaleLessThanHalf;

  /// No description provided for @who5ScaleSomeTime.
  ///
  /// In en, this message translates to:
  /// **'Some of the time'**
  String get who5ScaleSomeTime;

  /// No description provided for @who5ScaleNever.
  ///
  /// In en, this message translates to:
  /// **'At no time'**
  String get who5ScaleNever;

  /// No description provided for @wellbeingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the result locally. You can take it again.'**
  String get wellbeingSaveFailed;

  /// No description provided for @wellbeingToolsSection.
  ///
  /// In en, this message translates to:
  /// **'TOOLS'**
  String get wellbeingToolsSection;

  /// No description provided for @wellbeingBreathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get wellbeingBreathingTitle;

  /// No description provided for @wellbeingGroundingTitle.
  ///
  /// In en, this message translates to:
  /// **'Grounding'**
  String get wellbeingGroundingTitle;

  /// No description provided for @wellbeingGratitudeTitle.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get wellbeingGratitudeTitle;

  /// No description provided for @wellbeingGratitudeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get wellbeingGratitudeSubtitle;

  /// No description provided for @wellbeingBilateralTitle.
  ///
  /// In en, this message translates to:
  /// **'Bilateral stimulation'**
  String get wellbeingBilateralTitle;

  /// No description provided for @wellbeingBilateralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Eye tracking'**
  String get wellbeingBilateralSubtitle;

  /// No description provided for @wellbeingMuscleRelaxationTitle.
  ///
  /// In en, this message translates to:
  /// **'Muscle relaxation'**
  String get wellbeingMuscleRelaxationTitle;

  /// No description provided for @wellbeingMuscleRelaxationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tense/release'**
  String get wellbeingMuscleRelaxationSubtitle;

  /// No description provided for @wellbeingSafeTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get wellbeingSafeTitle;

  /// No description provided for @wellbeingSafeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a thought aside'**
  String get wellbeingSafeSubtitle;

  /// No description provided for @wellbeingLeavesTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaves on a stream'**
  String get wellbeingLeavesTitle;

  /// No description provided for @wellbeingLeavesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let a thought go'**
  String get wellbeingLeavesSubtitle;

  /// No description provided for @wellbeingFreewritingTitle.
  ///
  /// In en, this message translates to:
  /// **'Freewriting'**
  String get wellbeingFreewritingTitle;

  /// No description provided for @wellbeingFreewritingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unload your thoughts'**
  String get wellbeingFreewritingSubtitle;

  /// No description provided for @wellbeingQuestionnairesSection.
  ///
  /// In en, this message translates to:
  /// **'QUESTIONNAIRES'**
  String get wellbeingQuestionnairesSection;

  /// No description provided for @wellbeingQuestionnairesDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Official, freely distributed tools. Not a diagnosis — just self-screening.'**
  String get wellbeingQuestionnairesDisclaimer;

  /// No description provided for @who5CardTitle.
  ///
  /// In en, this message translates to:
  /// **'WHO-5 — general wellbeing'**
  String get who5CardTitle;

  /// No description provided for @wellbeingReleaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Let go'**
  String get wellbeingReleaseTitle;

  /// No description provided for @wellbeingReleaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write down a heavy thought and burn/smash it'**
  String get wellbeingReleaseSubtitle;

  /// No description provided for @wellbeingSleepMusicTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep music'**
  String get wellbeingSleepMusicTitle;

  /// No description provided for @wellbeingSleepMusicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calm sounds before bed'**
  String get wellbeingSleepMusicSubtitle;

  /// No description provided for @who5HistorySection.
  ///
  /// In en, this message translates to:
  /// **'WHO-5 HISTORY'**
  String get who5HistorySection;

  /// No description provided for @who5Instructions.
  ///
  /// In en, this message translates to:
  /// **'Mark what\'s closest to how you\'ve felt over the last two weeks.'**
  String get who5Instructions;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @who5ShowResult.
  ///
  /// In en, this message translates to:
  /// **'Show result'**
  String get who5ShowResult;

  /// No description provided for @who5ResultLow.
  ///
  /// In en, this message translates to:
  /// **'Below-average score'**
  String get who5ResultLow;

  /// No description provided for @who5ResultNormal.
  ///
  /// In en, this message translates to:
  /// **'Score within the normal range'**
  String get who5ResultNormal;

  /// No description provided for @who5DescriptionLow.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a diagnosis. Under the WHO method, a score below 50% is a reason to see a specialist for a more accurate assessment, especially if this has continued for more than two weeks.'**
  String get who5DescriptionLow;

  /// No description provided for @who5DescriptionNormal.
  ///
  /// In en, this message translates to:
  /// **'The official WHO method considers this result a sign of normal psychological wellbeing over the last two weeks.'**
  String get who5DescriptionNormal;

  /// No description provided for @who5DiscussPrompt.
  ///
  /// In en, this message translates to:
  /// **'I took the WHO-5 well-being questionnaire: {score}%{extra}. Can you comment on the result and support me?'**
  String who5DiscussPrompt(String score, String extra);

  /// No description provided for @who5RecommendSpecialist.
  ///
  /// In en, this message translates to:
  /// **' — the method recommends discussing this with a specialist'**
  String get who5RecommendSpecialist;

  /// No description provided for @who5DiscussButton.
  ///
  /// In en, this message translates to:
  /// **'Discuss with AI'**
  String get who5DiscussButton;

  /// No description provided for @who5BackToHistory.
  ///
  /// In en, this message translates to:
  /// **'Back to history'**
  String get who5BackToHistory;

  /// No description provided for @wellbeingAiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The AI and automatic scoring can make mistakes. This questionnaire is a self-monitoring tool, not a diagnosis. For an accurate assessment of your psychological state, see a doctor or therapist.'**
  String get wellbeingAiDisclaimer;

  /// No description provided for @wellbeingBreathingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'4 phases, 4 sec each'**
  String get wellbeingBreathingSubtitle;

  /// No description provided for @who5CardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'5 questions, one minute'**
  String get who5CardSubtitle;

  /// No description provided for @phq9TileTitle.
  ///
  /// In en, this message translates to:
  /// **'PHQ-9 — depression symptoms'**
  String get phq9TileTitle;

  /// No description provided for @phq9TileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'9 questions, 2-3 minutes'**
  String get phq9TileSubtitle;

  /// No description provided for @gad7TileTitle.
  ///
  /// In en, this message translates to:
  /// **'GAD-7 — anxiety symptoms'**
  String get gad7TileTitle;

  /// No description provided for @gad7TileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'7 questions, 1-2 minutes'**
  String get gad7TileSubtitle;

  /// No description provided for @asrsTileTitle.
  ///
  /// In en, this message translates to:
  /// **'ASRS-v1.1 — ADHD screening'**
  String get asrsTileTitle;

  /// No description provided for @asrsTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'6 questions, 1-2 minutes'**
  String get asrsTileSubtitle;

  /// No description provided for @who5LicenseAttribution.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire: World Health Organization-Five Well-Being Index (WHO-5), © World Health Organization 2024, licensed under CC BY-NC-SA 3.0 IGO. WHO endorsement of this application is not implied.'**
  String get who5LicenseAttribution;

  /// No description provided for @helpNoCheckinsSnack.
  ///
  /// In en, this message translates to:
  /// **'No completed questionnaires yet — you can take one in the Wellbeing section.'**
  String get helpNoCheckinsSnack;

  /// No description provided for @helpPickResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Which result to send?'**
  String get helpPickResultTitle;

  /// No description provided for @helpWeekSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary'**
  String get helpWeekSummaryTitle;

  /// No description provided for @helpWeekSummaryScore.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String helpWeekSummaryScore(int count);

  /// No description provided for @helpWeekSummaryHeader.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire results over the last 7 days:'**
  String get helpWeekSummaryHeader;

  /// No description provided for @helpWeekLineWho5.
  ///
  /// In en, this message translates to:
  /// **'• WHO-5 ({date}): {percent}%'**
  String helpWeekLineWho5(String date, int percent);

  /// No description provided for @helpWeekLinePhq9.
  ///
  /// In en, this message translates to:
  /// **'• PHQ-9 ({date}): {score}/27, \"{severity}\"{risk}'**
  String helpWeekLinePhq9(String date, int score, String severity, String risk);

  /// No description provided for @helpWeekLineGad7.
  ///
  /// In en, this message translates to:
  /// **'• GAD-7 ({date}): {score}/21, \"{severity}\"'**
  String helpWeekLineGad7(String date, int score, String severity);

  /// No description provided for @helpWeekLineAsrs.
  ///
  /// In en, this message translates to:
  /// **'• ASRS-v1.1 ({date}): {shaded}/6'**
  String helpWeekLineAsrs(String date, int shaded);

  /// No description provided for @helpRiskSignalPhq9Week.
  ///
  /// In en, this message translates to:
  /// **' — self-harm thoughts noted'**
  String get helpRiskSignalPhq9Week;

  /// No description provided for @helpSingleWho5Result.
  ///
  /// In en, this message translates to:
  /// **'WHO-5 questionnaire result ({date}): {percent}%{extra}.'**
  String helpSingleWho5Result(String date, int percent, String extra);

  /// No description provided for @helpSinglePhq9Result.
  ///
  /// In en, this message translates to:
  /// **'PHQ-9 questionnaire result ({date}): {score}/27, the method describes this as \"{severity}\"{risk}.'**
  String helpSinglePhq9Result(
    String date,
    int score,
    String severity,
    String risk,
  );

  /// No description provided for @helpPhq9RiskNote.
  ///
  /// In en, this message translates to:
  /// **'. Self-harm thoughts noted on item 9'**
  String get helpPhq9RiskNote;

  /// No description provided for @helpSingleGad7Result.
  ///
  /// In en, this message translates to:
  /// **'GAD-7 questionnaire result ({date}): {score}/21, the method describes this as \"{severity}\".'**
  String helpSingleGad7Result(String date, int score, String severity);

  /// No description provided for @helpSingleAsrsResult.
  ///
  /// In en, this message translates to:
  /// **'ASRS-v1.1 questionnaire result ({date}): {shaded}/6 in the significant range{extra}.'**
  String helpSingleAsrsResult(String date, int shaded, String extra);

  /// No description provided for @helpClosedStatus.
  ///
  /// In en, this message translates to:
  /// **'Request closed'**
  String get helpClosedStatus;

  /// No description provided for @helpConnectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Connected: {email}'**
  String helpConnectedStatus(String email);

  /// No description provided for @helpWaitingStatus.
  ///
  /// In en, this message translates to:
  /// **'Waiting for someone to join…'**
  String get helpWaitingStatus;

  /// No description provided for @helpSendTestResultsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send test results'**
  String get helpSendTestResultsTooltip;

  /// No description provided for @helpFinishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get helpFinishButton;

  /// No description provided for @helpRequestSentHint.
  ///
  /// In en, this message translates to:
  /// **'Request sent — a message will appear once someone joins.'**
  String get helpRequestSentHint;

  /// No description provided for @helpWriteWhatHappenedHint.
  ///
  /// In en, this message translates to:
  /// **'Write what happened.'**
  String get helpWriteWhatHappenedHint;

  /// No description provided for @helpMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message…'**
  String get helpMessageHint;

  /// No description provided for @helpChatContextHeader.
  ///
  /// In en, this message translates to:
  /// **'What happened in the AI chat before this request'**
  String get helpChatContextHeader;

  /// No description provided for @helpYourRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get helpYourRatingTitle;

  /// No description provided for @helpRatingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How did it go with the operator?'**
  String get helpRatingQuestion;

  /// No description provided for @helpCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get helpCommentHint;

  /// No description provided for @commonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commonSend;

  /// No description provided for @phq9Q1.
  ///
  /// In en, this message translates to:
  /// **'Little interest or pleasure in doing things'**
  String get phq9Q1;

  /// No description provided for @phq9Q2.
  ///
  /// In en, this message translates to:
  /// **'Feeling down, depressed, or hopeless'**
  String get phq9Q2;

  /// No description provided for @phq9Q3.
  ///
  /// In en, this message translates to:
  /// **'Trouble falling or staying asleep, or sleeping too much'**
  String get phq9Q3;

  /// No description provided for @phq9Q4.
  ///
  /// In en, this message translates to:
  /// **'Feeling tired or having little energy'**
  String get phq9Q4;

  /// No description provided for @phq9Q5.
  ///
  /// In en, this message translates to:
  /// **'Poor appetite or overeating'**
  String get phq9Q5;

  /// No description provided for @phq9Q6.
  ///
  /// In en, this message translates to:
  /// **'Feeling bad about yourself — or that you are a failure or have let yourself or your family down'**
  String get phq9Q6;

  /// No description provided for @phq9Q7.
  ///
  /// In en, this message translates to:
  /// **'Trouble concentrating on things, such as reading the newspaper or watching television'**
  String get phq9Q7;

  /// No description provided for @phq9Q8.
  ///
  /// In en, this message translates to:
  /// **'Moving or speaking so slowly that other people could have noticed. Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual'**
  String get phq9Q8;

  /// No description provided for @phq9Q9.
  ///
  /// In en, this message translates to:
  /// **'Thoughts that you would be better off dead, or of hurting yourself in some way'**
  String get phq9Q9;

  /// No description provided for @gad7Q1.
  ///
  /// In en, this message translates to:
  /// **'Feeling nervous, anxious, or on edge'**
  String get gad7Q1;

  /// No description provided for @gad7Q2.
  ///
  /// In en, this message translates to:
  /// **'Not being able to stop or control worrying'**
  String get gad7Q2;

  /// No description provided for @gad7Q3.
  ///
  /// In en, this message translates to:
  /// **'Worrying too much about different things'**
  String get gad7Q3;

  /// No description provided for @gad7Q4.
  ///
  /// In en, this message translates to:
  /// **'Trouble relaxing'**
  String get gad7Q4;

  /// No description provided for @gad7Q5.
  ///
  /// In en, this message translates to:
  /// **'Being so restless that it is hard to sit still'**
  String get gad7Q5;

  /// No description provided for @gad7Q6.
  ///
  /// In en, this message translates to:
  /// **'Becoming easily annoyed or irritable'**
  String get gad7Q6;

  /// No description provided for @gad7Q7.
  ///
  /// In en, this message translates to:
  /// **'Feeling afraid, as if something awful might happen'**
  String get gad7Q7;

  /// No description provided for @pfizerScaleNotAtAll.
  ///
  /// In en, this message translates to:
  /// **'Not at all'**
  String get pfizerScaleNotAtAll;

  /// No description provided for @pfizerScaleSeveralDays.
  ///
  /// In en, this message translates to:
  /// **'Several days'**
  String get pfizerScaleSeveralDays;

  /// No description provided for @pfizerScaleMoreThanHalf.
  ///
  /// In en, this message translates to:
  /// **'More than half the days'**
  String get pfizerScaleMoreThanHalf;

  /// No description provided for @pfizerScaleNearlyEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Nearly every day'**
  String get pfizerScaleNearlyEveryDay;

  /// No description provided for @pfizerSeverityMinimal.
  ///
  /// In en, this message translates to:
  /// **'minimal'**
  String get pfizerSeverityMinimal;

  /// No description provided for @pfizerSeverityMild.
  ///
  /// In en, this message translates to:
  /// **'mild'**
  String get pfizerSeverityMild;

  /// No description provided for @pfizerSeverityModerate.
  ///
  /// In en, this message translates to:
  /// **'moderate'**
  String get pfizerSeverityModerate;

  /// No description provided for @phq9SeverityModeratelySevere.
  ///
  /// In en, this message translates to:
  /// **'moderately severe'**
  String get phq9SeverityModeratelySevere;

  /// No description provided for @pfizerSeveritySevere.
  ///
  /// In en, this message translates to:
  /// **'severe'**
  String get pfizerSeveritySevere;

  /// No description provided for @phq9IntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Depression symptom screener'**
  String get phq9IntroTitle;

  /// No description provided for @phq9IntroBody.
  ///
  /// In en, this message translates to:
  /// **'An official, widely used primary-care screening tool (Patient Health Questionnaire-9). 9 questions, 2-3 minutes. This isn\'t a diagnosis — the result shows symptom severity over the last 2 weeks, not a medical conclusion. Only you take it and see the result — nothing is sent to the server.'**
  String get phq9IntroBody;

  /// No description provided for @gad7IntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Anxiety symptom screener'**
  String get gad7IntroTitle;

  /// No description provided for @gad7IntroBody.
  ///
  /// In en, this message translates to:
  /// **'An official, widely used primary-care screening tool (Generalized Anxiety Disorder-7). 7 questions, 1-2 minutes. This isn\'t a diagnosis — the result shows symptom severity over the last 2 weeks, not a medical conclusion. Only you take it and see the result — nothing is sent to the server.'**
  String get gad7IntroBody;

  /// No description provided for @checkinTakeTestButton.
  ///
  /// In en, this message translates to:
  /// **'Take the questionnaire'**
  String get checkinTakeTestButton;

  /// No description provided for @checkinRetakeTestButton.
  ///
  /// In en, this message translates to:
  /// **'Take it again'**
  String get checkinRetakeTestButton;

  /// No description provided for @checkinHistorySection.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get checkinHistorySection;

  /// No description provided for @pfizerInstructions.
  ///
  /// In en, this message translates to:
  /// **'Over the last 2 weeks, how often have you been bothered by the following problems?'**
  String get pfizerInstructions;

  /// No description provided for @checkinIfHardRightNow.
  ///
  /// In en, this message translates to:
  /// **'If it\'s hard right now'**
  String get checkinIfHardRightNow;

  /// No description provided for @pfizerSeverityDescription.
  ///
  /// In en, this message translates to:
  /// **'The method describes this result as: {severity}.'**
  String pfizerSeverityDescription(String severity);

  /// No description provided for @pfizerSuggestAssessment.
  ///
  /// In en, this message translates to:
  /// **'At this result, the method recommends discussing it with a specialist — this is a screening, not a diagnosis.'**
  String get pfizerSuggestAssessment;

  /// No description provided for @pfizerNoAssessmentNeeded.
  ///
  /// In en, this message translates to:
  /// **'The official method doesn\'t consider this result a reason for further assessment — but if you\'re struggling, that\'s not erased by this number.'**
  String get pfizerNoAssessmentNeeded;

  /// No description provided for @phq9RiskNoteDiscuss.
  ///
  /// In en, this message translates to:
  /// **' A positive response was noted on the item about thoughts of self-harm.'**
  String get phq9RiskNoteDiscuss;

  /// No description provided for @phq9DiscussPrompt.
  ///
  /// In en, this message translates to:
  /// **'I took the PHQ-9 questionnaire (depression symptoms): {score}/27, the method describes this as \"{severity}\".{riskNote} Can you comment on the result and support me?'**
  String phq9DiscussPrompt(int score, String severity, String riskNote);

  /// No description provided for @gad7DiscussPrompt.
  ///
  /// In en, this message translates to:
  /// **'I took the GAD-7 questionnaire (anxiety symptoms): {score}/21, the method describes this as \"{severity}\". Can you comment on the result and support me?'**
  String gad7DiscussPrompt(int score, String severity);

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @checkinMaxScoreSuffix.
  ///
  /// In en, this message translates to:
  /// **'out of {max}'**
  String checkinMaxScoreSuffix(int max);

  /// No description provided for @purchaseAdNotReadyYet.
  ///
  /// In en, this message translates to:
  /// **'Ad isn\'t available yet, try again in a bit.'**
  String get purchaseAdNotReadyYet;

  /// No description provided for @purchaseCheckoutOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the payment page.'**
  String get purchaseCheckoutOpenFailed;

  /// No description provided for @purchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get purchaseTitle;

  /// No description provided for @purchaseAvailablePlansSection.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE PLANS'**
  String get purchaseAvailablePlansSection;

  /// No description provided for @purchaseNoPlansConfigured.
  ///
  /// In en, this message translates to:
  /// **'No plans configured yet.'**
  String get purchaseNoPlansConfigured;

  /// No description provided for @purchaseFreeRequestsGone.
  ///
  /// In en, this message translates to:
  /// **'Out of free requests for today?'**
  String get purchaseFreeRequestsGone;

  /// No description provided for @purchaseTelegramPitch.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to our Telegram channel — get more requests today, every day, while you\'re subscribed.'**
  String get purchaseTelegramPitch;

  /// No description provided for @purchaseTelegramLinked.
  ///
  /// In en, this message translates to:
  /// **'Telegram linked'**
  String get purchaseTelegramLinked;

  /// No description provided for @purchaseTelegramLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Link Telegram'**
  String get purchaseTelegramLinkButton;

  /// No description provided for @purchaseWatchAdButton.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad (+3)'**
  String get purchaseWatchAdButton;

  /// No description provided for @purchaseAdBonusRemaining.
  ///
  /// In en, this message translates to:
  /// **'Bonus requests left from ads: {count}'**
  String purchaseAdBonusRemaining(int count);

  /// No description provided for @purchaseCurrentPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get purchaseCurrentPlanLabel;

  /// No description provided for @purchaseTokensUsedNoLimit.
  ///
  /// In en, this message translates to:
  /// **'{used} tokens used this month · no limit'**
  String purchaseTokensUsedNoLimit(int used);

  /// No description provided for @purchaseTokensUsedWithLimit.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit} tokens this month'**
  String purchaseTokensUsedWithLimit(int used, int limit);

  /// No description provided for @purchaseCurrentBadge.
  ///
  /// In en, this message translates to:
  /// **'current'**
  String get purchaseCurrentBadge;

  /// No description provided for @purchaseFreeDuration.
  ///
  /// In en, this message translates to:
  /// **'Free · {days} days'**
  String purchaseFreeDuration(int days);

  /// No description provided for @purchasePriceDuration.
  ///
  /// In en, this message translates to:
  /// **'{rub} / {usd} · {days} days'**
  String purchasePriceDuration(String rub, String usd, int days);

  /// No description provided for @purchaseComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get purchaseComingSoon;

  /// No description provided for @purchaseBuyButton.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get purchaseBuyButton;

  /// No description provided for @purchaseStripeOption.
  ///
  /// In en, this message translates to:
  /// **'Credit card (Stripe)'**
  String get purchaseStripeOption;

  /// No description provided for @purchaseTelegramDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Telegram'**
  String get purchaseTelegramDialogTitle;

  /// No description provided for @purchaseTelegramDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Open the bot and send it this code in a direct message:'**
  String get purchaseTelegramDialogBody;

  /// No description provided for @purchaseOpenBotButton.
  ///
  /// In en, this message translates to:
  /// **'Open bot'**
  String get purchaseOpenBotButton;

  /// No description provided for @voiceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voiceSettingsTitle;

  /// No description provided for @voiceSettingsDisabledByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Voice features are temporarily disabled by the admin.'**
  String get voiceSettingsDisabledByAdmin;

  /// No description provided for @voiceSettingsUseVoice.
  ///
  /// In en, this message translates to:
  /// **'Use voice'**
  String get voiceSettingsUseVoice;

  /// No description provided for @voiceSettingsHiddenHint.
  ///
  /// In en, this message translates to:
  /// **'The microphone and reading responses aloud are hidden. Turn on the toggle above to bring them back.'**
  String get voiceSettingsHiddenHint;

  /// No description provided for @voiceSettingsSpeechRecognitionSection.
  ///
  /// In en, this message translates to:
  /// **'SPEECH RECOGNITION'**
  String get voiceSettingsSpeechRecognitionSection;

  /// No description provided for @voiceSettingsMicAvailable.
  ///
  /// In en, this message translates to:
  /// **'Microphone available — the button will appear next to the input field'**
  String get voiceSettingsMicAvailable;

  /// No description provided for @voiceSettingsMicUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Microphone unavailable on this device (no permission or recognition engine)'**
  String get voiceSettingsMicUnavailable;

  /// No description provided for @voiceSettingsAutoReadSection.
  ///
  /// In en, this message translates to:
  /// **'READING RESPONSES ALOUD'**
  String get voiceSettingsAutoReadSection;

  /// No description provided for @voiceSettingsAutoReadToggle.
  ///
  /// In en, this message translates to:
  /// **'Read responses aloud automatically'**
  String get voiceSettingsAutoReadToggle;

  /// No description provided for @voiceSettingsVoiceSection.
  ///
  /// In en, this message translates to:
  /// **'VOICE'**
  String get voiceSettingsVoiceSection;

  /// No description provided for @voiceSettingsVoiceInstructions.
  ///
  /// In en, this message translates to:
  /// **'Listen to each one and pick whichever sounds calmer to you — by ear is more reliable than a description.'**
  String get voiceSettingsVoiceInstructions;

  /// No description provided for @voiceSettingsNoVoicesLoaded.
  ///
  /// In en, this message translates to:
  /// **'Voices haven\'t loaded yet or aren\'t available on this device.'**
  String get voiceSettingsNoVoicesLoaded;

  /// No description provided for @voiceSettingsFemaleSection.
  ///
  /// In en, this message translates to:
  /// **'FEMALE VOICE'**
  String get voiceSettingsFemaleSection;

  /// No description provided for @voiceSettingsMaleSection.
  ///
  /// In en, this message translates to:
  /// **'MALE VOICE'**
  String get voiceSettingsMaleSection;

  /// No description provided for @voiceSettingsOtherSection.
  ///
  /// In en, this message translates to:
  /// **'OTHER OPTIONS'**
  String get voiceSettingsOtherSection;

  /// No description provided for @voiceSettingsCouldNotClassify.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t tell the voice\'s gender from its name — just listen and pick.'**
  String get voiceSettingsCouldNotClassify;

  /// No description provided for @voiceSettingsPreviewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get voiceSettingsPreviewTooltip;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server.\n{details}'**
  String authNetworkError(String details);

  /// No description provided for @authUnexpectedResponse.
  ///
  /// In en, this message translates to:
  /// **'The server returned an unexpected response (code {code}).'**
  String authUnexpectedResponse(int code);

  /// No description provided for @authDeleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the account (code {code}).'**
  String authDeleteAccountFailed(int code);

  /// No description provided for @authRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the request (code {code}).'**
  String authRequestFailed(int code);

  /// No description provided for @authChangePasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t change the password (code {code}).'**
  String authChangePasswordFailed(int code);

  /// No description provided for @authResendCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t resend the code (code {code}).'**
  String authResendCodeFailed(int code);

  /// No description provided for @authGenericError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error.'**
  String get authGenericError;

  /// No description provided for @operatorIssueWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue a warning'**
  String get operatorIssueWarningTitle;

  /// No description provided for @operatorWarningReasonHint.
  ///
  /// In en, this message translates to:
  /// **'What for — this reason will stay in the history'**
  String get operatorWarningReasonHint;

  /// No description provided for @operatorIssueButton.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get operatorIssueButton;

  /// No description provided for @operatorRevokeAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke live-help access?'**
  String get operatorRevokeAccessTitle;

  /// No description provided for @operatorRevokeAccessBody.
  ///
  /// In en, this message translates to:
  /// **'{email} will no longer be able to take requests. The account and history will remain.'**
  String operatorRevokeAccessBody(String email);

  /// No description provided for @operatorRevokeAccessConfirm.
  ///
  /// In en, this message translates to:
  /// **'Revoke access'**
  String get operatorRevokeAccessConfirm;

  /// No description provided for @operatorDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the account entirely?'**
  String get operatorDeleteAccountTitle;

  /// No description provided for @operatorDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This is irreversible: {email} and their entire request history will be deleted. If you just need to remove access without deleting the account, use \"Revoke access\" instead.'**
  String operatorDeleteAccountBody(String email);

  /// No description provided for @operatorDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get operatorDeleteAccountConfirm;

  /// No description provided for @operatorWarningsSectionCount.
  ///
  /// In en, this message translates to:
  /// **'WARNINGS ({count})'**
  String operatorWarningsSectionCount(int count);

  /// No description provided for @operatorSessionsSectionCount.
  ///
  /// In en, this message translates to:
  /// **'REQUESTS ({count})'**
  String operatorSessionsSectionCount(int count);

  /// No description provided for @operatorNoSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'Hasn\'t taken any requests yet'**
  String get operatorNoSessionsYet;

  /// No description provided for @operatorWarningButtonShort.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get operatorWarningButtonShort;

  /// No description provided for @operatorRevokeAccessButtonShort.
  ///
  /// In en, this message translates to:
  /// **'Revoke access'**
  String get operatorRevokeAccessButtonShort;

  /// No description provided for @operatorDeleteAccountTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete the account entirely'**
  String get operatorDeleteAccountTooltip;

  /// No description provided for @operatorIssuedByPrefix.
  ///
  /// In en, this message translates to:
  /// **'· {email}'**
  String operatorIssuedByPrefix(String email);

  /// No description provided for @operatorUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get operatorUnknownUser;

  /// No description provided for @operatorNoRating.
  ///
  /// In en, this message translates to:
  /// **'no rating'**
  String get operatorNoRating;

  /// No description provided for @operatorQuotedComment.
  ///
  /// In en, this message translates to:
  /// **'\"{comment}\"'**
  String operatorQuotedComment(String comment);

  /// No description provided for @asrsQ1.
  ///
  /// In en, this message translates to:
  /// **'How often do you have trouble wrapping up the final details of a project, once the challenging parts have been done?'**
  String get asrsQ1;

  /// No description provided for @asrsQ2.
  ///
  /// In en, this message translates to:
  /// **'How often do you have difficulty getting things in order when you have to do a task that requires organization?'**
  String get asrsQ2;

  /// No description provided for @asrsQ3.
  ///
  /// In en, this message translates to:
  /// **'How often do you have problems remembering appointments or obligations?'**
  String get asrsQ3;

  /// No description provided for @asrsQ4.
  ///
  /// In en, this message translates to:
  /// **'When you have a task that requires a lot of thought, how often do you avoid or delay getting started?'**
  String get asrsQ4;

  /// No description provided for @asrsQ5.
  ///
  /// In en, this message translates to:
  /// **'How often do you fidget or squirm with your hands or feet when you have to sit down for a long time?'**
  String get asrsQ5;

  /// No description provided for @asrsQ6.
  ///
  /// In en, this message translates to:
  /// **'How often do you feel overly active and compelled to do things, like you were driven by a motor?'**
  String get asrsQ6;

  /// No description provided for @asrsScaleNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get asrsScaleNever;

  /// No description provided for @asrsScaleRarely.
  ///
  /// In en, this message translates to:
  /// **'Rarely'**
  String get asrsScaleRarely;

  /// No description provided for @asrsScaleSometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get asrsScaleSometimes;

  /// No description provided for @asrsScaleOften.
  ///
  /// In en, this message translates to:
  /// **'Often'**
  String get asrsScaleOften;

  /// No description provided for @asrsScaleVeryOften.
  ///
  /// In en, this message translates to:
  /// **'Very often'**
  String get asrsScaleVeryOften;

  /// No description provided for @asrsIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Adult ADHD symptom screening'**
  String get asrsIntroTitle;

  /// No description provided for @asrsIntroBody.
  ///
  /// In en, this message translates to:
  /// **'An official WHO questionnaire (Adult ADHD Self-Report Scale, short 6-question version). 1-2 minutes. This is a screening, not a diagnosis — a positive result means it\'s worth discussing with a specialist, not that a diagnosis is already there. Only you take it and see the result — nothing is sent to the server.'**
  String get asrsIntroBody;

  /// No description provided for @asrsInstructions.
  ///
  /// In en, this message translates to:
  /// **'Over the last 6 months, how often has this happened?'**
  String get asrsInstructions;

  /// No description provided for @asrsShadedCountSuffix.
  ///
  /// In en, this message translates to:
  /// **'out of 6 in the significant range'**
  String get asrsShadedCountSuffix;

  /// No description provided for @asrsSuggestAssessment.
  ///
  /// In en, this message translates to:
  /// **'The method\'s official threshold (4 out of 6) has been reached — it recommends discussing this with a specialist. This is a screening, not a diagnosis.'**
  String get asrsSuggestAssessment;

  /// No description provided for @asrsNoAssessmentNeeded.
  ///
  /// In en, this message translates to:
  /// **'The official method doesn\'t consider this result a reason for further assessment — but if any of this is bothering you, it\'s still worth discussing with a specialist.'**
  String get asrsNoAssessmentNeeded;

  /// No description provided for @asrsDiscussPrompt.
  ///
  /// In en, this message translates to:
  /// **'I took the ASRS-v1.1 screening (ADHD): {shaded}/6 in the significant range{extra}. Can you comment on the result and support me?'**
  String asrsDiscussPrompt(int shaded, String extra);

  /// No description provided for @authBiometricNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Biometrics (Face ID/fingerprint) aren\'t set up on this device — turn it on in the device\'s own settings first.'**
  String get authBiometricNotConfigured;

  /// No description provided for @authBiometricConfirmReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm to turn on biometric sign-in'**
  String get authBiometricConfirmReason;

  /// No description provided for @authBiometricConfirmFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t confirm — try again.'**
  String get authBiometricConfirmFailed;

  /// No description provided for @authUnexpectedErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String authUnexpectedErrorGeneric(String error);

  /// No description provided for @authSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found. Sign in again.'**
  String get authSessionNotFound;

  /// No description provided for @messageMenuEditRetry.
  ///
  /// In en, this message translates to:
  /// **'Edit and ask again'**
  String get messageMenuEditRetry;

  /// No description provided for @messageMenuCopyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get messageMenuCopyText;

  /// No description provided for @messageCopiedSnack.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get messageCopiedSnack;

  /// No description provided for @messageMenuReadAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get messageMenuReadAloud;

  /// No description provided for @messageMenuReport.
  ///
  /// In en, this message translates to:
  /// **'Report this response'**
  String get messageMenuReport;

  /// No description provided for @messageMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get messageMenuDelete;

  /// No description provided for @messageEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get messageEditDialogTitle;

  /// No description provided for @messageEditDialogWarning.
  ///
  /// In en, this message translates to:
  /// **'The model\'s response to this message and everything after it will be deleted — the model will answer again based on the edited text.'**
  String get messageEditDialogWarning;

  /// No description provided for @messageRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Ask again'**
  String get messageRetryButton;

  /// No description provided for @messageSourcesAdminOnly.
  ///
  /// In en, this message translates to:
  /// **'SOURCES (visible to admin only)'**
  String get messageSourcesAdminOnly;

  /// No description provided for @messageSourcePageSuffix.
  ///
  /// In en, this message translates to:
  /// **', p. {page}'**
  String messageSourcePageSuffix(int page);

  /// No description provided for @messageSourceLine.
  ///
  /// In en, this message translates to:
  /// **'{filename}{pageSuffix} · {similarity}%'**
  String messageSourceLine(String filename, String pageSuffix, int similarity);

  /// No description provided for @messageChooseWhatYouLike.
  ///
  /// In en, this message translates to:
  /// **'Pick what you like:'**
  String get messageChooseWhatYouLike;

  /// No description provided for @messageNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get messageNotNow;

  /// No description provided for @messageYesLetsTest.
  ///
  /// In en, this message translates to:
  /// **'Yes, let\'s test'**
  String get messageYesLetsTest;

  /// No description provided for @messageNoLetsContinue.
  ///
  /// In en, this message translates to:
  /// **'No, let\'s continue'**
  String get messageNoLetsContinue;

  /// No description provided for @profilePasswordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get profilePasswordsDontMatch;

  /// No description provided for @profileCodeSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'A code was sent to {email}. Enter it below to finish the change.'**
  String profileCodeSentToEmail(String email);

  /// No description provided for @profileConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get profileConfirmButton;

  /// No description provided for @freewritingTitle.
  ///
  /// In en, this message translates to:
  /// **'Freewriting'**
  String get freewritingTitle;

  /// No description provided for @freewritingIntro.
  ///
  /// In en, this message translates to:
  /// **'Write continuously, whatever comes to mind — no censoring, no fixing mistakes, don\'t stop. This isn\'t about nice-sounding text, it\'s about clearing your head.'**
  String get freewritingIntro;

  /// No description provided for @freewritingHowManyMinutes.
  ///
  /// In en, this message translates to:
  /// **'How many minutes?'**
  String get freewritingHowManyMinutes;

  /// No description provided for @freewritingMinutesOption.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String freewritingMinutesOption(int minutes);

  /// No description provided for @freewritingStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start writing'**
  String get freewritingStartButton;

  /// No description provided for @freewritingFinishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get freewritingFinishButton;

  /// No description provided for @freewritingHint.
  ///
  /// In en, this message translates to:
  /// **'Keep writing, don\'t stop…'**
  String get freewritingHint;

  /// No description provided for @freewritingTimeUpBody.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up. You can leave the text on screen and reread it, or clear it right away — whichever suits you.'**
  String get freewritingTimeUpBody;

  /// No description provided for @freewritingEmptyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get freewritingEmptyPlaceholder;

  /// No description provided for @freewritingEraseButton.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get freewritingEraseButton;

  /// No description provided for @freewritingKeepAndCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Keep and close'**
  String get freewritingKeepAndCloseButton;

  /// No description provided for @groundingSightSense.
  ///
  /// In en, this message translates to:
  /// **'Sight'**
  String get groundingSightSense;

  /// No description provided for @groundingSightPrompt.
  ///
  /// In en, this message translates to:
  /// **'Name 5 things you can see around you'**
  String get groundingSightPrompt;

  /// No description provided for @groundingTouchSense.
  ///
  /// In en, this message translates to:
  /// **'Touch'**
  String get groundingTouchSense;

  /// No description provided for @groundingTouchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Name 4 things you can touch'**
  String get groundingTouchPrompt;

  /// No description provided for @groundingHearingSense.
  ///
  /// In en, this message translates to:
  /// **'Hearing'**
  String get groundingHearingSense;

  /// No description provided for @groundingHearingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Name 3 sounds you can hear right now'**
  String get groundingHearingPrompt;

  /// No description provided for @groundingSmellSense.
  ///
  /// In en, this message translates to:
  /// **'Smell'**
  String get groundingSmellSense;

  /// No description provided for @groundingSmellPrompt.
  ///
  /// In en, this message translates to:
  /// **'Name 2 things you can smell'**
  String get groundingSmellPrompt;

  /// No description provided for @groundingTasteSense.
  ///
  /// In en, this message translates to:
  /// **'Taste'**
  String get groundingTasteSense;

  /// No description provided for @groundingTastePrompt.
  ///
  /// In en, this message translates to:
  /// **'Name 1 thing you can taste or remember tasting'**
  String get groundingTastePrompt;

  /// No description provided for @groundingTitle.
  ///
  /// In en, this message translates to:
  /// **'Grounding technique'**
  String get groundingTitle;

  /// No description provided for @groundingListeningHint.
  ///
  /// In en, this message translates to:
  /// **'Listening — I\'ll switch on my own once you\'re done talking'**
  String get groundingListeningHint;

  /// No description provided for @groundingNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get groundingNextButton;

  /// No description provided for @groundingDoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can repeat this any time.'**
  String get groundingDoneSubtitle;

  /// No description provided for @groundingIfAnxietyPersists.
  ///
  /// In en, this message translates to:
  /// **'If the anxiety doesn\'t ease up — it\'s normal for one technique not to be enough. You can talk to someone close to you or a specialist.'**
  String get groundingIfAnxietyPersists;

  /// No description provided for @groundingStartOverButton.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get groundingStartOverButton;

  /// No description provided for @muscleHandsGroup.
  ///
  /// In en, this message translates to:
  /// **'Hands'**
  String get muscleHandsGroup;

  /// No description provided for @muscleHandsTense.
  ///
  /// In en, this message translates to:
  /// **'Clench your fists tightly'**
  String get muscleHandsTense;

  /// No description provided for @muscleHandsRelease.
  ///
  /// In en, this message translates to:
  /// **'Release sharply and feel the warmth'**
  String get muscleHandsRelease;

  /// No description provided for @muscleShouldersGroup.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscleShouldersGroup;

  /// No description provided for @muscleShouldersTense.
  ///
  /// In en, this message translates to:
  /// **'Raise your shoulders as high as you can toward your ears'**
  String get muscleShouldersTense;

  /// No description provided for @muscleShouldersRelease.
  ///
  /// In en, this message translates to:
  /// **'Let go, let your shoulders drop'**
  String get muscleShouldersRelease;

  /// No description provided for @muscleFaceGroup.
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get muscleFaceGroup;

  /// No description provided for @muscleFaceTense.
  ///
  /// In en, this message translates to:
  /// **'Squeeze your eyes shut and clench your jaw'**
  String get muscleFaceTense;

  /// No description provided for @muscleFaceRelease.
  ///
  /// In en, this message translates to:
  /// **'Relax your face completely'**
  String get muscleFaceRelease;

  /// No description provided for @muscleAbsGroup.
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get muscleAbsGroup;

  /// No description provided for @muscleAbsTense.
  ///
  /// In en, this message translates to:
  /// **'Tense your stomach as if bracing for a hit'**
  String get muscleAbsTense;

  /// No description provided for @muscleAbsRelease.
  ///
  /// In en, this message translates to:
  /// **'Release the tension'**
  String get muscleAbsRelease;

  /// No description provided for @muscleLegsGroup.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get muscleLegsGroup;

  /// No description provided for @muscleLegsTense.
  ///
  /// In en, this message translates to:
  /// **'Stretch out your legs and flex your feet'**
  String get muscleLegsTense;

  /// No description provided for @muscleLegsRelease.
  ///
  /// In en, this message translates to:
  /// **'Let your legs relax'**
  String get muscleLegsRelease;

  /// No description provided for @muscleRelaxationTitle.
  ///
  /// In en, this message translates to:
  /// **'Muscle relaxation'**
  String get muscleRelaxationTitle;

  /// No description provided for @muscleRelaxationIntro.
  ///
  /// In en, this message translates to:
  /// **'We\'ll tense and relax {count} muscle groups one by one. A few seconds of tension each, then release. Get comfortable so nothing restricts moving your arms/legs.'**
  String muscleRelaxationIntro(int count);

  /// No description provided for @muscleStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get muscleStartButton;

  /// No description provided for @muscleStepProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String muscleStepProgress(int current, int total);

  /// No description provided for @muscleDoneText.
  ///
  /// In en, this message translates to:
  /// **'Done — all muscle groups completed.'**
  String get muscleDoneText;

  /// No description provided for @muscleRepeatButton.
  ///
  /// In en, this message translates to:
  /// **'Do it again'**
  String get muscleRepeatButton;

  /// No description provided for @chatServerNotResponding.
  ///
  /// In en, this message translates to:
  /// **'The server isn\'t responding. Check that the backend is running at {baseUrl}'**
  String chatServerNotResponding(String baseUrl);

  /// No description provided for @chatConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect to {baseUrl}.\n{error}'**
  String chatConnectionFailed(String baseUrl, String error);

  /// No description provided for @chatSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign out and sign in again.'**
  String get chatSessionExpired;

  /// No description provided for @chatServerErrorCode.
  ///
  /// In en, this message translates to:
  /// **'The server returned an error {code}'**
  String chatServerErrorCode(int code);

  /// No description provided for @chatConnectionDroppedMidResponse.
  ///
  /// In en, this message translates to:
  /// **'\n\n⚠️ The connection dropped mid-response (for example, the tunnel went down). Try sending the message again.\n{error}'**
  String chatConnectionDroppedMidResponse(String error);

  /// No description provided for @chatResponseTruncated.
  ///
  /// In en, this message translates to:
  /// **'\n\n⚠️ The response got cut off — the connection closed before the model finished. Try again.'**
  String get chatResponseTruncated;

  /// No description provided for @chatDoctorSummaryPrompt.
  ///
  /// In en, this message translates to:
  /// **'In 2-3 sentences, briefly describe the person\'s condition to a doctor in the third person, based on this conversation — what\'s bothering them, for how long, what\'s already been discussed. Write it for the doctor as a colleague, not for the person themselves, and don\'t use \"you\".'**
  String get chatDoctorSummaryPrompt;

  /// No description provided for @memoryReleaseIntro.
  ///
  /// In en, this message translates to:
  /// **'Write down what\'s hard to hold onto — a heavy thought, a grudge, a memory. No one will see or save it — once you let it go, the text disappears for good, with no way to get it back.'**
  String get memoryReleaseIntro;

  /// No description provided for @memoryReleaseHint.
  ///
  /// In en, this message translates to:
  /// **'Write here…'**
  String get memoryReleaseHint;

  /// No description provided for @memoryReleaseBurnMode.
  ///
  /// In en, this message translates to:
  /// **'Burn'**
  String get memoryReleaseBurnMode;

  /// No description provided for @memoryReleaseShatterMode.
  ///
  /// In en, this message translates to:
  /// **'Shatter'**
  String get memoryReleaseShatterMode;

  /// No description provided for @memoryReleaseBurnedResult.
  ///
  /// In en, this message translates to:
  /// **'Burned away — nothing\'s left of the text.'**
  String get memoryReleaseBurnedResult;

  /// No description provided for @memoryReleaseShatteredResult.
  ///
  /// In en, this message translates to:
  /// **'Shattered to pieces — the text is gone.'**
  String get memoryReleaseShatteredResult;

  /// No description provided for @memoryReleaseWriteMoreButton.
  ///
  /// In en, this message translates to:
  /// **'Write more'**
  String get memoryReleaseWriteMoreButton;

  /// No description provided for @blogLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the blog.'**
  String get blogLoadFailed;

  /// No description provided for @blogLoadPostFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the post.'**
  String get blogLoadPostFailed;

  /// No description provided for @blogLoadListFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the list of posts.'**
  String get blogLoadListFailed;

  /// No description provided for @blogCreatePostFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the post.'**
  String get blogCreatePostFailed;

  /// No description provided for @blogSavePostFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the post.'**
  String get blogSavePostFailed;

  /// No description provided for @blogDeletePostFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the post.'**
  String get blogDeletePostFailed;

  /// No description provided for @blogLikeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t like the post.'**
  String get blogLikeFailed;

  /// No description provided for @blogLoadCommentsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load comments.'**
  String get blogLoadCommentsFailed;

  /// No description provided for @blogSendCommentFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the comment.'**
  String get blogSendCommentFailed;

  /// No description provided for @blogDeleteCommentFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the comment.'**
  String get blogDeleteCommentFailed;

  /// No description provided for @myHelpCallPersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Call for human help'**
  String get myHelpCallPersonTitle;

  /// No description provided for @myHelpCallPersonDescription.
  ///
  /// In en, this message translates to:
  /// **'A doctor or specialist from the team will join. This isn\'t a substitute for emergency services — if the situation calls for urgent medical help, call your local emergency number or go straight to an emergency room.'**
  String get myHelpCallPersonDescription;

  /// No description provided for @myHelpDescribeHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly, what happened (optional)'**
  String get myHelpDescribeHint;

  /// No description provided for @myHelpCallButton.
  ///
  /// In en, this message translates to:
  /// **'Call for help'**
  String get myHelpCallButton;

  /// No description provided for @myHelpMyRequestsSection.
  ///
  /// In en, this message translates to:
  /// **'MY REQUESTS'**
  String get myHelpMyRequestsSection;

  /// No description provided for @myHelpStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting to connect'**
  String get myHelpStatusPending;

  /// No description provided for @myHelpStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get myHelpStatusActive;

  /// No description provided for @myHelpStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get myHelpStatusClosed;

  /// No description provided for @customTestDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get customTestDefaultTitle;

  /// No description provided for @customTestLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the test.'**
  String get customTestLoadFailed;

  /// No description provided for @customTestQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} question(s)'**
  String customTestQuestionCount(int count);

  /// No description provided for @customTestQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String customTestQuestionProgress(int current, int total);

  /// No description provided for @customTestPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get customTestPointsLabel;

  /// No description provided for @customTestDiscussPrompt.
  ///
  /// In en, this message translates to:
  /// **'I took the \"{title}\" test: {score} point(s){resultNote}. Can you comment on the result and support me?'**
  String customTestDiscussPrompt(String title, int score, String resultNote);

  /// No description provided for @customTestResultNote.
  ///
  /// In en, this message translates to:
  /// **' — result: \"{label}\"'**
  String customTestResultNote(String label);

  /// No description provided for @reportSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Report sent'**
  String get reportSentTitle;

  /// No description provided for @reportSentBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks — we\'ll take a look at this response. The question and answer text was sent along with the report, so it can be reviewed right away without asking you again.'**
  String get reportSentBody;

  /// No description provided for @reportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this response'**
  String get reportDialogTitle;

  /// No description provided for @reportDialogBody.
  ///
  /// In en, this message translates to:
  /// **'The question and the response you\'re reporting will be sent along with the report — otherwise it won\'t be possible to figure out what exactly went wrong.'**
  String get reportDialogBody;

  /// No description provided for @reportReasonHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s wrong with this response? (optional)'**
  String get reportReasonHint;

  /// No description provided for @helpCreateSessionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the request.'**
  String get helpCreateSessionFailed;

  /// No description provided for @helpLoadSessionsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load requests.'**
  String get helpLoadSessionsFailed;

  /// No description provided for @helpLoadMessagesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load messages.'**
  String get helpLoadMessagesFailed;

  /// No description provided for @helpSendMessageFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the message.'**
  String get helpSendMessageFailed;

  /// No description provided for @helpCloseSessionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t close the request.'**
  String get helpCloseSessionFailed;

  /// No description provided for @helpSendRatingFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the rating.'**
  String get helpSendRatingFailed;

  /// No description provided for @helpLoadRequestsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load requests.'**
  String get helpLoadRequestsFailed;

  /// No description provided for @helpLoadActiveSessionsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load active requests.'**
  String get helpLoadActiveSessionsFailed;

  /// No description provided for @helpRequestAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'This request was already taken by another operator.'**
  String get helpRequestAlreadyTaken;

  /// No description provided for @helpAcceptRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t accept the request.'**
  String get helpAcceptRequestFailed;

  /// No description provided for @breathingInhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get breathingInhale;

  /// No description provided for @breathingHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get breathingHold;

  /// No description provided for @breathingExhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get breathingExhale;

  /// No description provided for @breathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Breathing exercise'**
  String get breathingTitle;

  /// No description provided for @breathingReadyToStart.
  ///
  /// In en, this message translates to:
  /// **'Ready to start?'**
  String get breathingReadyToStart;

  /// No description provided for @breathingStopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get breathingStopButton;

  /// No description provided for @breathingDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'A simple breath self-regulation technique — it doesn\'t replace professional help. If you feel dizzy — stop the exercise and breathe at your usual pace.'**
  String get breathingDisclaimer;

  /// No description provided for @themeVariantViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get themeVariantViolet;

  /// No description provided for @themeVariantOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeVariantOcean;

  /// No description provided for @themeVariantMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get themeVariantMidnight;

  /// No description provided for @themeVariantSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get themeVariantSunset;

  /// No description provided for @themeVariantForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get themeVariantForest;

  /// No description provided for @themeVariantRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get themeVariantRose;

  /// No description provided for @themeVariantAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get themeVariantAmber;

  /// No description provided for @themeVariantSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get themeVariantSlate;

  /// No description provided for @themeVariantMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get themeVariantMint;

  /// No description provided for @customTestsLoadListFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the list of tests.'**
  String get customTestsLoadListFailed;

  /// No description provided for @customTestsLoadTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the test.'**
  String get customTestsLoadTestFailed;

  /// No description provided for @customTestsSubmitAnswersFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t submit the answers.'**
  String get customTestsSubmitAnswersFailed;

  /// No description provided for @customTestsLoadHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the test history.'**
  String get customTestsLoadHistoryFailed;

  /// No description provided for @customTestsCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the test.'**
  String get customTestsCreateFailed;

  /// No description provided for @customTestsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the test.'**
  String get customTestsSaveFailed;

  /// No description provided for @customTestsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the test.'**
  String get customTestsDeleteFailed;

  /// No description provided for @safeContainmentIntro.
  ///
  /// In en, this message translates to:
  /// **'If a thought or feeling is too intense but this isn\'t the time to deal with it — write it down and put it in the safe. It won\'t disappear forever, it\'ll just wait until you have time to come back to it.'**
  String get safeContainmentIntro;

  /// No description provided for @safeContainmentHint.
  ///
  /// In en, this message translates to:
  /// **'What needs to be set aside for later?'**
  String get safeContainmentHint;

  /// No description provided for @safeContainmentPutAwayButton.
  ///
  /// In en, this message translates to:
  /// **'Put in the safe'**
  String get safeContainmentPutAwayButton;

  /// No description provided for @safeContainmentDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Safely tucked away. It won\'t distract you right now — we\'ll come back to it when you\'re ready.'**
  String get safeContainmentDoneBody;

  /// No description provided for @voicePreviewPhrase.
  ///
  /// In en, this message translates to:
  /// **'Hi! This is what this voice sounds like.'**
  String get voicePreviewPhrase;

  /// No description provided for @appSettingsChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t change the setting (code {code}).'**
  String appSettingsChangeFailed(int code);

  /// No description provided for @appSettingsRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore settings (code {code}).'**
  String appSettingsRestoreFailed(int code);

  /// No description provided for @appSettingsLoadPersonaFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the AI persona settings (code {code}).'**
  String appSettingsLoadPersonaFailed(int code);

  /// No description provided for @appSettingsSavePersonaFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the AI persona (code {code}).'**
  String appSettingsSavePersonaFailed(int code);

  /// No description provided for @appSettingsResetPersonaFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reset the AI persona (code {code}).'**
  String appSettingsResetPersonaFailed(int code);

  /// No description provided for @appSettingsLoadModelFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load model settings (code {code}).'**
  String appSettingsLoadModelFailed(int code);

  /// No description provided for @appSettingsSaveModelFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save model settings (code {code}).'**
  String appSettingsSaveModelFailed(int code);

  /// No description provided for @appSettingsResetModelFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reset model settings (code {code}).'**
  String appSettingsResetModelFailed(int code);

  /// No description provided for @reminderPrompt1.
  ///
  /// In en, this message translates to:
  /// **'How was your day? If you feel like talking — I\'m here.'**
  String get reminderPrompt1;

  /// No description provided for @reminderPrompt2.
  ///
  /// In en, this message translates to:
  /// **'A short pause — how are you doing overall right now?'**
  String get reminderPrompt2;

  /// No description provided for @reminderPrompt3.
  ///
  /// In en, this message translates to:
  /// **'If something\'s been building up that you want to talk about — now\'s a good time.'**
  String get reminderPrompt3;

  /// No description provided for @reminderPrompt4.
  ///
  /// In en, this message translates to:
  /// **'How\'s your mood today? Stop by if you need to get something off your chest.'**
  String get reminderPrompt4;

  /// No description provided for @reminderPrompt5.
  ///
  /// In en, this message translates to:
  /// **'Just a reminder that you can stop by and share how your day went.'**
  String get reminderPrompt5;

  /// No description provided for @reminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'A reminder to check in at your chosen time'**
  String get reminderChannelDescription;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @supportMyTicketsSection.
  ///
  /// In en, this message translates to:
  /// **'YOUR TICKETS'**
  String get supportMyTicketsSection;

  /// No description provided for @supportNoTicketsYet.
  ///
  /// In en, this message translates to:
  /// **'No tickets yet'**
  String get supportNoTicketsYet;

  /// No description provided for @supportDescribeProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem — we\'ll take a look and reply'**
  String get supportDescribeProblem;

  /// No description provided for @supportHint.
  ///
  /// In en, this message translates to:
  /// **'For example: the model doesn\'t respond to long questions…'**
  String get supportHint;

  /// No description provided for @supportSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get supportSending;

  /// No description provided for @supportTicketOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get supportTicketOpen;

  /// No description provided for @myReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'My reports'**
  String get myReportsTitle;

  /// No description provided for @myReportsNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get myReportsNoneYet;

  /// No description provided for @myReportsResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get myReportsResolved;

  /// No description provided for @myReportsUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get myReportsUnderReview;

  /// No description provided for @myReportsYourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Your question'**
  String get myReportsYourQuestion;

  /// No description provided for @myReportsAiResponseLabel.
  ///
  /// In en, this message translates to:
  /// **'The AI response you reported'**
  String get myReportsAiResponseLabel;

  /// No description provided for @myReportsReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason for the report'**
  String get myReportsReasonLabel;

  /// No description provided for @myReportsTeamResponseSection.
  ///
  /// In en, this message translates to:
  /// **'RESPONSE FROM THE TEAM'**
  String get myReportsTeamResponseSection;

  /// No description provided for @leavesOnStreamTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaves on the stream'**
  String get leavesOnStreamTitle;

  /// No description provided for @leavesOnStreamIntro.
  ///
  /// In en, this message translates to:
  /// **'Write down a thought you want to let go of. It\'ll float down the stream and dissolve — nothing is saved.'**
  String get leavesOnStreamIntro;

  /// No description provided for @leavesOnStreamHint.
  ///
  /// In en, this message translates to:
  /// **'For example: I\'m afraid I won\'t manage...'**
  String get leavesOnStreamHint;

  /// No description provided for @leavesOnStreamDoneText.
  ///
  /// In en, this message translates to:
  /// **'The thought floated away.'**
  String get leavesOnStreamDoneText;

  /// No description provided for @bilateralTitle.
  ///
  /// In en, this message translates to:
  /// **'Bilateral stimulation'**
  String get bilateralTitle;

  /// No description provided for @bilateralIntro.
  ///
  /// In en, this message translates to:
  /// **'Follow the ball with your eyes only, without turning your head. This helps reduce the intensity of anxiety. It doesn\'t replace working with a specialist if the anxiety is strong or frequent.'**
  String get bilateralIntro;

  /// No description provided for @operatorDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Operator dashboard'**
  String get operatorDashboardTitle;

  /// No description provided for @operatorDashboardMyActiveSection.
  ///
  /// In en, this message translates to:
  /// **'MY ACTIVE ({count})'**
  String operatorDashboardMyActiveSection(int count);

  /// No description provided for @operatorDashboardPendingSection.
  ///
  /// In en, this message translates to:
  /// **'WAITING TO CONNECT ({count})'**
  String operatorDashboardPendingSection(int count);

  /// No description provided for @operatorDashboardNoOneWaiting.
  ///
  /// In en, this message translates to:
  /// **'No one is waiting to connect right now'**
  String get operatorDashboardNoOneWaiting;

  /// No description provided for @operatorDashboardNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get operatorDashboardNoDescription;

  /// No description provided for @operatorDashboardAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get operatorDashboardAcceptButton;

  /// No description provided for @gratitudeTitle.
  ///
  /// In en, this message translates to:
  /// **'Gratitude journal'**
  String get gratitudeTitle;

  /// No description provided for @gratitudePrompt.
  ///
  /// In en, this message translates to:
  /// **'Three things you\'re grateful for today'**
  String get gratitudePrompt;

  /// No description provided for @gratitudeHint.
  ///
  /// In en, this message translates to:
  /// **'It doesn\'t have to be something big — a small thing works too.'**
  String get gratitudeHint;

  /// No description provided for @gratitudeEntriesSection.
  ///
  /// In en, this message translates to:
  /// **'ENTRIES'**
  String get gratitudeEntriesSection;

  /// No description provided for @gratitudeBulletItem.
  ///
  /// In en, this message translates to:
  /// **'· {item}'**
  String gratitudeBulletItem(String item);

  /// No description provided for @wellbeingCalendarWho5Label.
  ///
  /// In en, this message translates to:
  /// **'WHO-5'**
  String get wellbeingCalendarWho5Label;

  /// No description provided for @wellbeingCalendarScoreSuffix.
  ///
  /// In en, this message translates to:
  /// **'{score} point(s)'**
  String wellbeingCalendarScoreSuffix(int score);

  /// No description provided for @wellbeingCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Wellbeing calendar'**
  String get wellbeingCalendarTitle;

  /// No description provided for @wellbeingCalendarTakeTestButton.
  ///
  /// In en, this message translates to:
  /// **'Take a test'**
  String get wellbeingCalendarTakeTestButton;

  /// No description provided for @wellbeingCalendarEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No completed questionnaires yet — they\'ll show up here\nonce you take one in the \"Wellbeing\" section.'**
  String get wellbeingCalendarEmptyState;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @chatQuestionNotFound.
  ///
  /// In en, this message translates to:
  /// **'(question not found)'**
  String get chatQuestionNotFound;

  /// No description provided for @chatTestDeclinedContinuation.
  ///
  /// In en, this message translates to:
  /// **'The user tapped \"No, not now\" on the test suggestion. Just continue the conversation naturally, without explicitly mentioning the decline or apologizing for the suggestion.'**
  String get chatTestDeclinedContinuation;

  /// No description provided for @cloudVoiceLabelFemale.
  ///
  /// In en, this message translates to:
  /// **'{name} (female)'**
  String cloudVoiceLabelFemale(String name);

  /// No description provided for @cloudVoiceLabelMale.
  ///
  /// In en, this message translates to:
  /// **'{name} (male)'**
  String cloudVoiceLabelMale(String name);

  /// No description provided for @modelDowngradedNotice.
  ///
  /// In en, this message translates to:
  /// **'You\'ve run out of tokens for the advanced AI version this month — this reply came from the regular model. Upgrade your subscription above to get more.'**
  String get modelDowngradedNotice;

  /// No description provided for @modelDowngradedUpgradeButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade plan'**
  String get modelDowngradedUpgradeButton;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRussian;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @sleepMusicTabCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get sleepMusicTabCatalog;

  /// No description provided for @sleepMusicTabPlaylists.
  ///
  /// In en, this message translates to:
  /// **'My playlists'**
  String get sleepMusicTabPlaylists;

  /// No description provided for @sleepMusicNoPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet — create your first one.'**
  String get sleepMusicNoPlaylists;

  /// No description provided for @sleepMusicCreatePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create playlist'**
  String get sleepMusicCreatePlaylist;

  /// No description provided for @sleepMusicNewPlaylistHint.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get sleepMusicNewPlaylistHint;

  /// No description provided for @sleepMusicEmptyPlaylist.
  ///
  /// In en, this message translates to:
  /// **'This playlist has no tracks yet.'**
  String get sleepMusicEmptyPlaylist;

  /// No description provided for @sleepMusicAddTrack.
  ///
  /// In en, this message translates to:
  /// **'Add track'**
  String get sleepMusicAddTrack;

  /// No description provided for @sleepMusicAddFromCatalog.
  ///
  /// In en, this message translates to:
  /// **'From catalog'**
  String get sleepMusicAddFromCatalog;

  /// No description provided for @sleepMusicUploadOwnFile.
  ///
  /// In en, this message translates to:
  /// **'Upload your own file'**
  String get sleepMusicUploadOwnFile;

  /// No description provided for @sleepMusicRemoveFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get sleepMusicRemoveFromPlaylist;

  /// No description provided for @sleepMusicDeletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist'**
  String get sleepMusicDeletePlaylist;

  /// No description provided for @sleepMusicDeletePlaylistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist \"{name}\"? The tracks themselves will stay in the catalog/your library.'**
  String sleepMusicDeletePlaylistConfirm(String name);

  /// No description provided for @sleepMusicOwnFileWebNotice.
  ///
  /// In en, this message translates to:
  /// **'On the web your own file will only play until the page reloads — it can\'t be saved permanently here.'**
  String get sleepMusicOwnFileWebNotice;

  /// No description provided for @sleepMusicFileReadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the file.'**
  String get sleepMusicFileReadError;

  /// No description provided for @sleepMusicNoTracksInCatalogYet.
  ///
  /// In en, this message translates to:
  /// **'No sounds in the catalog yet — an admin needs to add some first.'**
  String get sleepMusicNoTracksInCatalogYet;

  /// No description provided for @sleepMusicTimerCancel.
  ///
  /// In en, this message translates to:
  /// **'Turn off timer'**
  String get sleepMusicTimerCancel;

  /// No description provided for @sleepMusicTimerMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String sleepMusicTimerMinutes(int minutes);

  /// No description provided for @sleepMusicRenamePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Rename playlist'**
  String get sleepMusicRenamePlaylist;

  /// No description provided for @sleepMusicLikedTitle.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get sleepMusicLikedTitle;

  /// No description provided for @sleepMusicNoLikedYet.
  ///
  /// In en, this message translates to:
  /// **'No liked tracks yet — tap the heart on any track.'**
  String get sleepMusicNoLikedYet;
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
