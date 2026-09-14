// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Glass Chat';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Error';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLogout => 'Log out';

  @override
  String get authSignInTitle => 'Sign in to AI Chat';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authRepeatPasswordHint => 'Repeat password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authRegisterButton => 'Sign up';

  @override
  String get authLoginButton => 'Sign in';

  @override
  String get authHaveAccount => 'Already have an account? Sign in';

  @override
  String get authNoAccount => 'No account? Sign up';

  @override
  String get authPasswordLengthOk => 'Password length is fine';

  @override
  String authPasswordLengthHint(int minLength, int length) {
    return 'At least $minLength characters ($length entered)';
  }

  @override
  String get authPasswordsMatch => 'Passwords match';

  @override
  String get authPasswordsMismatch => 'Passwords don\'t match';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordEmailPrompt => 'Enter the email your account is registered with — we\'ll send a reset code.';

  @override
  String get forgotPasswordSendCode => 'Send code';

  @override
  String get forgotPasswordCheckEmail => 'If that email is registered, a reset code has been sent to it. Check your inbox (and spam folder) and enter the code below along with your new password.';

  @override
  String get forgotPasswordHaveCode => 'I have a code';

  @override
  String get forgotPasswordResend => 'Resend';

  @override
  String get forgotPasswordCodeTitle => 'Code from the email';

  @override
  String get forgotPasswordCodeHint => 'Code';

  @override
  String get forgotPasswordNewPasswordHint => 'New password';

  @override
  String get forgotPasswordSubmit => 'Change password';

  @override
  String get forgotPasswordDone => 'Password changed. You can now sign in with your new password.';

  @override
  String get lockScreenTitle => 'App is locked';

  @override
  String get lockScreenFailedHint => 'Couldn\'t verify — try again.';

  @override
  String get lockScreenPrompt => 'Verify your identity to continue.';

  @override
  String get lockScreenUnlockButton => 'Unlock';

  @override
  String get lockScreenUsePassword => 'Use password instead';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String get verifyEmailPromptGeneric => 'Enter the code sent to your email at sign-up.';

  @override
  String verifyEmailPromptWithEmail(String email) {
    return 'Enter the code sent to $email.';
  }

  @override
  String get verifyEmailCodeHint => 'Code from the email';

  @override
  String get verifyEmailResendButton => 'Resend code';

  @override
  String get verifyEmailSubmitButton => 'Verify';

  @override
  String get verifyEmailResentMessage => 'Code resent — check your inbox.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'APPEARANCE';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsBackgroundColorLabel => 'Background color';

  @override
  String get settingsSectionPerformance => 'PERFORMANCE';

  @override
  String get settingsPerformanceModeLabel => 'Battery saver mode';

  @override
  String get settingsPerformanceModeDescription => 'Turns off the animated background and glass blur throughout the app. Worth enabling if your phone is weak, laggy, or overheating — most devices don\'t need this.';

  @override
  String get settingsSectionNotifications => 'NOTIFICATIONS';

  @override
  String get settingsSoundOnMessage => 'Sound on new message';

  @override
  String get settingsVibrationOnMessage => 'Vibration on new message';

  @override
  String get settingsSectionVoice => 'VOICE';

  @override
  String get settingsVoiceButtonsInChat => 'Voice buttons in chat';

  @override
  String get settingsVoiceAndSpeechRecognition => 'Voice selection and speech recognition';

  @override
  String get settingsSectionSecurity => 'SECURITY';

  @override
  String get settingsBiometricLogin => 'Biometric sign-in';

  @override
  String get settingsBiometricNotSupported => 'Biometrics (Face ID/fingerprint) isn\'t set up on this device — enable it in your device settings if you\'d like to use it here.';

  @override
  String get settingsSectionReminders => 'REMINDERS';

  @override
  String get settingsReminderDescription => 'Once a day, at a time you choose (e.g. when you\'re usually home) — a gentle nudge to check in if you feel like talking.';

  @override
  String get settingsDailyReminder => 'Daily reminder';

  @override
  String get settingsReminderTimeLabel => 'Time';

  @override
  String get settingsReminderPermissionDenied => 'Notifications aren\'t allowed — enable them for this app in your device settings.';

  @override
  String get settingsSectionAccount => 'ACCOUNT';

  @override
  String get settingsLogoutButton => 'Log out';

  @override
  String get settingsSectionAbout => 'ABOUT';

  @override
  String get settingsAppVersion => 'Version 1.0.0';

  @override
  String get settingsModelInfo => 'Default model: gemma4:e2b via local Ollama.';

  @override
  String get settingsSectionDangerZone => 'DANGER ZONE';

  @override
  String get settingsDeleteAccountButton => 'Delete account';

  @override
  String get settingsDeleteAccountDialogTitle => 'Delete account?';

  @override
  String get settingsDeleteAccountWarning => 'This is irreversible: your account, support history, and usage stats will be permanently deleted. Chat history on this device will remain — it was never stored on the server, and you can delete it separately.';

  @override
  String get settingsConfirmWithPassword => 'Confirm with your password';

  @override
  String get settingsDeleteForeverButton => 'Delete forever';

  @override
  String get chatNoSoundsUploaded => 'No sounds uploaded yet — the admin hasn\'t added any.';

  @override
  String get chatStopButton => 'Stop';

  @override
  String get chatRoleUser => 'User';

  @override
  String get chatRoleAi => 'AI';

  @override
  String get chatMigraineLabel => 'Migraine or heavy fatigue';

  @override
  String get chatWhatDoYouNeedNow => 'What do you need right now?';

  @override
  String get chatTakeTestTitle => 'Take a test';

  @override
  String get chatTakeTestSubtitle => 'A questionnaire — we\'ll discuss the result right here';

  @override
  String get chatWhichQuestionnaire => 'Which questionnaire?';

  @override
  String get chatPhq9Subtitle => 'Depression symptoms, 9 questions';

  @override
  String get chatGad7Subtitle => 'Anxiety symptoms, 7 questions';

  @override
  String get chatAsrsSubtitle => 'ADHD screening, 6 questions';

  @override
  String get chatOtherTestsTitle => 'Other tests';

  @override
  String get chatOtherTestsSubtitle => 'Questionnaires created by the team';

  @override
  String get chatCallHelpTitle => 'Call in a real person for help?';

  @override
  String get chatCallHelpDescription => 'A doctor or specialist from the team will join. This isn\'t a substitute for emergency services — if the situation needs urgent medical help, call your local emergency number.';

  @override
  String get chatPrepareSummaryQuestion => 'Prepare a short summary of your conversation with the AI for the doctor (not the whole chat), so you don\'t have to explain everything again?';

  @override
  String get chatYesPrepareSummary => 'Yes, prepare a summary';

  @override
  String get chatNoDontShow => 'No, don\'t show it';

  @override
  String get chatCallButton => 'Call for help';

  @override
  String get chatCloseTooltip => 'Close';

  @override
  String get chatNewChatTitle => 'New chat';

  @override
  String get chatDisclaimer => 'The AI can make mistakes. Double-check important information yourself.';

  @override
  String get chatVerifyEmailBanner => 'Verify your email';

  @override
  String get chatMuteBackgroundSound => 'Turn off background sound';

  @override
  String get chatUnmuteBackgroundSound => 'Turn on background sound';

  @override
  String get chatMenuTooltip => 'Menu';

  @override
  String get chatMenuProfile => 'Profile';

  @override
  String get chatMenuWellbeing => 'Wellbeing';

  @override
  String get chatMenuSleepMusic => 'Sleep music';

  @override
  String get chatMenuSubscription => 'Subscription';

  @override
  String get chatMenuMyReports => 'My reports';

  @override
  String get chatMenuLiveHelp => 'Live help';

  @override
  String get chatMenuOperatorCabinet => 'Operator dashboard';

  @override
  String get chatMenuSupport => 'Support';

  @override
  String get chatMenuBlog => 'Blog';

  @override
  String get chatSuggestion1 => 'Explain quantum physics in simple terms';

  @override
  String get chatSuggestion2 => 'Write a weekly workout plan';

  @override
  String get chatSuggestion3 => 'Help me name my project';

  @override
  String get chatSuggestion4 => 'How do I improve my Dart code?';

  @override
  String get chatWhatCanIHelpWith => 'What can I help with today?';

  @override
  String get aiModeSupportTitle => 'Support';

  @override
  String get aiModeSupportSubtitle => 'Just be there in the conversation';

  @override
  String get aiModeSupportOpener => 'I need some support right now — just be here with me in the conversation and cheer me up.';

  @override
  String get aiModeListenTitle => 'Just listen';

  @override
  String get aiModeListenSubtitle => 'No need to jump to advice';

  @override
  String get aiModeListenOpener => 'I just need to talk it out — listen, no need to give advice right away.';

  @override
  String get aiModeBreakupTitle => 'Divorce or breakup';

  @override
  String get aiModeBreakupSubtitle => 'Start a conversation about it';

  @override
  String get aiModeBreakupOpener => 'I\'m going through a divorce or breakup right now, and it\'s hard to cope. Can you support me while I talk about it?';

  @override
  String get aiModeGriefTitle => 'Loss and grief';

  @override
  String get aiModeGriefSubtitle => 'Start a conversation about it';

  @override
  String get aiModeGriefOpener => 'I recently lost someone close to me, and I\'d like to talk to someone about it.';

  @override
  String get aiModeJobLossTitle => 'Job loss or major life change';

  @override
  String get aiModeJobLossSubtitle => 'Start a conversation about it';

  @override
  String get aiModeJobLossOpener => 'I\'m going through a tough time — I lost my job or a sudden change happened in my life, and it\'s hard to deal with. Can you support me while I talk about it?';

  @override
  String get aiModeRationalizerTitle => 'Thought checker';

  @override
  String get aiModeRationalizerSubtitle => 'Break down an anxious thought using CBT';

  @override
  String get aiModeRationalizerOpener => 'I have an anxious thought that won\'t leave me alone. Help me break it down using CBT — ask me guiding questions one at a time (for example, what evidence supports this thought, what\'s the worst that could happen and how likely is it) so I can see the situation more clearly.';

  @override
  String get profileBirthDateHelpText => 'Date of birth';

  @override
  String profileAgeYears(int age) {
    String _temp0 = intl.Intl.pluralLogic(
      age,
      locale: localeName,
      other: '$age years',
      one: '$age year',
    );
    return '$_temp0';
  }

  @override
  String get profileTakePhoto => 'Take a photo';

  @override
  String get profileChooseFromGallery => 'Choose from gallery';

  @override
  String get profileDeletePhoto => 'Delete photo';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNoData => 'No data';

  @override
  String get profileSectionPersonal => 'PERSONAL';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileNotSpecified => 'not specified';

  @override
  String get profileBirthDate => 'Date of birth';

  @override
  String get profileHobbies => 'Hobbies';

  @override
  String get profileEmergencyContact => 'Emergency contact';

  @override
  String get profileSectionAccount => 'ACCOUNT';

  @override
  String get profileRole => 'Role';

  @override
  String get profileRoleAdmin => 'Administrator';

  @override
  String get profileRoleUser => 'User';

  @override
  String get profileAccountCreated => 'Account created';

  @override
  String get profileEditButton => 'Edit profile';

  @override
  String get profileChangePasswordButton => 'Change password';

  @override
  String get profileEditTitle => 'Personal details';

  @override
  String get profileEditHint => 'All fields are optional — leave blank to clear.';

  @override
  String get profileEmergencySectionLabel => 'IN CASE OF EMERGENCY';

  @override
  String get profileEmergencyContactHint => 'E.g.: Mom, +1 555 123-4567';

  @override
  String get profileLogoutButton => 'Log out';

  @override
  String get profilePasswordTooShort => 'The new password must be at least 8 characters long.';

  @override
  String get profilePasswordsMismatch => 'Passwords don\'t match.';

  @override
  String get profileChangePasswordTitle => 'Change password';

  @override
  String get profileCurrentPasswordLabel => 'Current password';

  @override
  String get profileNewPasswordLabel => 'New password';

  @override
  String get profileRepeatNewPasswordLabel => 'Repeat new password';

  @override
  String get profileChangeEmailTitle => 'Change email';

  @override
  String profileCurrentEmailLabel(String email) {
    return 'Currently: $email';
  }

  @override
  String get profileNewEmailLabel => 'New address';

  @override
  String profileCodeSentMessage(String email) {
    return 'Code sent to $email. Enter it below to complete the change.';
  }

  @override
  String get profileCodeFromEmailLabel => 'Code from the email';

  @override
  String get profileSendCodeButton => 'Send code';

  @override
  String get sidebarCalendarTitle => 'Calendar';

  @override
  String get sidebarCalendarSubtitle => 'Questionnaire results by day';

  @override
  String get sidebarWellbeingSubtitle => 'Take a test, situational support';

  @override
  String get sidebarCallHelpTitle => 'Call for help';

  @override
  String get sidebarCallHelpSubtitle => 'A doctor or specialist will join';

  @override
  String get sidebarHistoryLabel => 'HISTORY';

  @override
  String get sidebarNoConversations => 'No conversations yet';

  @override
  String get sidebarRenameChatTitle => 'Rename chat';

  @override
  String get sidebarDeleteChatTitle => 'Delete chat?';

  @override
  String sidebarDeleteChatBody(String title) {
    return 'The conversation \"$title\" will be deleted permanently.';
  }

  @override
  String get sidebarEmptyConversation => 'Empty';

  @override
  String get crisisResourcesDefaultTitle => 'If you feel like talking to someone';

  @override
  String get crisisResourcesBody => '• Emergency psychological support for adults and children in Russia, 24/7 and free: 8-800-100-49-94\n• Child and teen helpline (Russia): 8-800-2000-122 (short number: 124)\n\nIf you\'re not in Russia, search for a local crisis line for your country; in the US and Canada you can call or text 988.';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSleep => 'Sleep';

  @override
  String get navWellbeing => 'Care';

  @override
  String get sleepMusicTitle => 'Sleep music';

  @override
  String get sleepMusicNoneUploaded => 'No music uploaded yet — the admin hasn\'t added any.';

  @override
  String get customTestListTitle => 'Tests';

  @override
  String get customTestListEmpty => 'No tests available yet.';

  @override
  String get blogTitle => 'Blog';

  @override
  String get blogListEmpty => 'No posts yet — check back later.';

  @override
  String get who5Q1 => 'I have felt cheerful and in good spirits';

  @override
  String get who5Q2 => 'I have felt calm and relaxed';

  @override
  String get who5Q3 => 'I have felt active and vigorous';

  @override
  String get who5Q4 => 'I woke up feeling fresh and rested';

  @override
  String get who5Q5 => 'My daily life has been filled with things that interest me';

  @override
  String get who5ScaleAllTime => 'All of the time';

  @override
  String get who5ScaleMostTime => 'Most of the time';

  @override
  String get who5ScaleMoreThanHalf => 'More than half of the time';

  @override
  String get who5ScaleLessThanHalf => 'Less than half of the time';

  @override
  String get who5ScaleSomeTime => 'Some of the time';

  @override
  String get who5ScaleNever => 'At no time';

  @override
  String get wellbeingSaveFailed => 'Couldn\'t save the result locally. You can take it again.';

  @override
  String get wellbeingToolsSection => 'TOOLS';

  @override
  String get wellbeingBreathingTitle => 'Breathing';

  @override
  String get wellbeingGroundingTitle => 'Grounding';

  @override
  String get wellbeingGratitudeTitle => 'Gratitude';

  @override
  String get wellbeingGratitudeSubtitle => 'Journal';

  @override
  String get wellbeingBilateralTitle => 'Bilateral stimulation';

  @override
  String get wellbeingBilateralSubtitle => 'Eye tracking';

  @override
  String get wellbeingMuscleRelaxationTitle => 'Muscle relaxation';

  @override
  String get wellbeingMuscleRelaxationSubtitle => 'Tense/release';

  @override
  String get wellbeingSafeTitle => 'Safe';

  @override
  String get wellbeingSafeSubtitle => 'Set a thought aside';

  @override
  String get wellbeingLeavesTitle => 'Leaves on a stream';

  @override
  String get wellbeingLeavesSubtitle => 'Let a thought go';

  @override
  String get wellbeingFreewritingTitle => 'Freewriting';

  @override
  String get wellbeingFreewritingSubtitle => 'Unload your thoughts';

  @override
  String get wellbeingQuestionnairesSection => 'QUESTIONNAIRES';

  @override
  String get wellbeingQuestionnairesDisclaimer => 'Official, freely distributed tools. Not a diagnosis — just self-screening.';

  @override
  String get who5CardTitle => 'WHO-5 — general wellbeing';

  @override
  String get wellbeingReleaseTitle => 'Let go';

  @override
  String get wellbeingReleaseSubtitle => 'Write down a heavy thought and burn/smash it';

  @override
  String get wellbeingSleepMusicTitle => 'Sleep music';

  @override
  String get wellbeingSleepMusicSubtitle => 'Calm sounds before bed';

  @override
  String get who5HistorySection => 'WHO-5 HISTORY';

  @override
  String get who5Instructions => 'Mark what\'s closest to how you\'ve felt over the last two weeks.';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get who5ShowResult => 'Show result';

  @override
  String get who5ResultLow => 'Below-average score';

  @override
  String get who5ResultNormal => 'Score within the normal range';

  @override
  String get who5DescriptionLow => 'This isn\'t a diagnosis. Under the WHO method, a score below 50% is a reason to see a specialist for a more accurate assessment, especially if this has continued for more than two weeks.';

  @override
  String get who5DescriptionNormal => 'The official WHO method considers this result a sign of normal psychological wellbeing over the last two weeks.';

  @override
  String who5DiscussPrompt(String score, String extra) {
    return 'I took the WHO-5 well-being questionnaire: $score%$extra. Can you comment on the result and support me?';
  }

  @override
  String get who5RecommendSpecialist => ' — the method recommends discussing this with a specialist';

  @override
  String get who5DiscussButton => 'Discuss with AI';

  @override
  String get who5BackToHistory => 'Back to history';

  @override
  String get wellbeingAiDisclaimer => 'The AI and automatic scoring can make mistakes. This questionnaire is a self-monitoring tool, not a diagnosis. For an accurate assessment of your psychological state, see a doctor or therapist.';

  @override
  String get wellbeingBreathingSubtitle => '4 phases, 4 sec each';

  @override
  String get who5CardSubtitle => '5 questions, one minute';

  @override
  String get phq9TileTitle => 'PHQ-9 — depression symptoms';

  @override
  String get phq9TileSubtitle => '9 questions, 2-3 minutes';

  @override
  String get gad7TileTitle => 'GAD-7 — anxiety symptoms';

  @override
  String get gad7TileSubtitle => '7 questions, 1-2 minutes';

  @override
  String get asrsTileTitle => 'ASRS-v1.1 — ADHD screening';

  @override
  String get asrsTileSubtitle => '6 questions, 1-2 minutes';

  @override
  String get who5LicenseAttribution => 'Questionnaire: World Health Organization-Five Well-Being Index (WHO-5), © World Health Organization 2024, licensed under CC BY-NC-SA 3.0 IGO. WHO endorsement of this application is not implied.';

  @override
  String get helpNoCheckinsSnack => 'No completed questionnaires yet — you can take one in the Wellbeing section.';

  @override
  String get helpPickResultTitle => 'Which result to send?';

  @override
  String get helpWeekSummaryTitle => 'Weekly summary';

  @override
  String helpWeekSummaryScore(int count) {
    return '$count entries';
  }

  @override
  String get helpWeekSummaryHeader => 'Questionnaire results over the last 7 days:';

  @override
  String helpWeekLineWho5(String date, int percent) {
    return '• WHO-5 ($date): $percent%';
  }

  @override
  String helpWeekLinePhq9(String date, int score, String severity, String risk) {
    return '• PHQ-9 ($date): $score/27, \"$severity\"$risk';
  }

  @override
  String helpWeekLineGad7(String date, int score, String severity) {
    return '• GAD-7 ($date): $score/21, \"$severity\"';
  }

  @override
  String helpWeekLineAsrs(String date, int shaded) {
    return '• ASRS-v1.1 ($date): $shaded/6';
  }

  @override
  String get helpRiskSignalPhq9Week => ' — self-harm thoughts noted';

  @override
  String helpSingleWho5Result(String date, int percent, String extra) {
    return 'WHO-5 questionnaire result ($date): $percent%$extra.';
  }

  @override
  String helpSinglePhq9Result(String date, int score, String severity, String risk) {
    return 'PHQ-9 questionnaire result ($date): $score/27, the method describes this as \"$severity\"$risk.';
  }

  @override
  String get helpPhq9RiskNote => '. Self-harm thoughts noted on item 9';

  @override
  String helpSingleGad7Result(String date, int score, String severity) {
    return 'GAD-7 questionnaire result ($date): $score/21, the method describes this as \"$severity\".';
  }

  @override
  String helpSingleAsrsResult(String date, int shaded, String extra) {
    return 'ASRS-v1.1 questionnaire result ($date): $shaded/6 in the significant range$extra.';
  }

  @override
  String get helpClosedStatus => 'Request closed';

  @override
  String helpConnectedStatus(String email) {
    return 'Connected: $email';
  }

  @override
  String get helpWaitingStatus => 'Waiting for someone to join…';

  @override
  String get helpSendTestResultsTooltip => 'Send test results';

  @override
  String get helpFinishButton => 'Finish';

  @override
  String get helpRequestSentHint => 'Request sent — a message will appear once someone joins.';

  @override
  String get helpWriteWhatHappenedHint => 'Write what happened.';

  @override
  String get helpMessageHint => 'Write a message…';

  @override
  String get helpChatContextHeader => 'What happened in the AI chat before this request';

  @override
  String get helpYourRatingTitle => 'Your rating';

  @override
  String get helpRatingQuestion => 'How did it go with the operator?';

  @override
  String get helpCommentHint => 'Comment (optional)';

  @override
  String get commonSend => 'Send';

  @override
  String get phq9Q1 => 'Little interest or pleasure in doing things';

  @override
  String get phq9Q2 => 'Feeling down, depressed, or hopeless';

  @override
  String get phq9Q3 => 'Trouble falling or staying asleep, or sleeping too much';

  @override
  String get phq9Q4 => 'Feeling tired or having little energy';

  @override
  String get phq9Q5 => 'Poor appetite or overeating';

  @override
  String get phq9Q6 => 'Feeling bad about yourself — or that you are a failure or have let yourself or your family down';

  @override
  String get phq9Q7 => 'Trouble concentrating on things, such as reading the newspaper or watching television';

  @override
  String get phq9Q8 => 'Moving or speaking so slowly that other people could have noticed. Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual';

  @override
  String get phq9Q9 => 'Thoughts that you would be better off dead, or of hurting yourself in some way';

  @override
  String get gad7Q1 => 'Feeling nervous, anxious, or on edge';

  @override
  String get gad7Q2 => 'Not being able to stop or control worrying';

  @override
  String get gad7Q3 => 'Worrying too much about different things';

  @override
  String get gad7Q4 => 'Trouble relaxing';

  @override
  String get gad7Q5 => 'Being so restless that it is hard to sit still';

  @override
  String get gad7Q6 => 'Becoming easily annoyed or irritable';

  @override
  String get gad7Q7 => 'Feeling afraid, as if something awful might happen';

  @override
  String get pfizerScaleNotAtAll => 'Not at all';

  @override
  String get pfizerScaleSeveralDays => 'Several days';

  @override
  String get pfizerScaleMoreThanHalf => 'More than half the days';

  @override
  String get pfizerScaleNearlyEveryDay => 'Nearly every day';

  @override
  String get pfizerSeverityMinimal => 'minimal';

  @override
  String get pfizerSeverityMild => 'mild';

  @override
  String get pfizerSeverityModerate => 'moderate';

  @override
  String get phq9SeverityModeratelySevere => 'moderately severe';

  @override
  String get pfizerSeveritySevere => 'severe';

  @override
  String get phq9IntroTitle => 'Depression symptom screener';

  @override
  String get phq9IntroBody => 'An official, widely used primary-care screening tool (Patient Health Questionnaire-9). 9 questions, 2-3 minutes. This isn\'t a diagnosis — the result shows symptom severity over the last 2 weeks, not a medical conclusion. Only you take it and see the result — nothing is sent to the server.';

  @override
  String get gad7IntroTitle => 'Anxiety symptom screener';

  @override
  String get gad7IntroBody => 'An official, widely used primary-care screening tool (Generalized Anxiety Disorder-7). 7 questions, 1-2 minutes. This isn\'t a diagnosis — the result shows symptom severity over the last 2 weeks, not a medical conclusion. Only you take it and see the result — nothing is sent to the server.';

  @override
  String get checkinTakeTestButton => 'Take the questionnaire';

  @override
  String get checkinRetakeTestButton => 'Take it again';

  @override
  String get checkinHistorySection => 'HISTORY';

  @override
  String get pfizerInstructions => 'Over the last 2 weeks, how often have you been bothered by the following problems?';

  @override
  String get checkinIfHardRightNow => 'If it\'s hard right now';

  @override
  String pfizerSeverityDescription(String severity) {
    return 'The method describes this result as: $severity.';
  }

  @override
  String get pfizerSuggestAssessment => 'At this result, the method recommends discussing it with a specialist — this is a screening, not a diagnosis.';

  @override
  String get pfizerNoAssessmentNeeded => 'The official method doesn\'t consider this result a reason for further assessment — but if you\'re struggling, that\'s not erased by this number.';

  @override
  String get phq9RiskNoteDiscuss => ' A positive response was noted on the item about thoughts of self-harm.';

  @override
  String phq9DiscussPrompt(int score, String severity, String riskNote) {
    return 'I took the PHQ-9 questionnaire (depression symptoms): $score/27, the method describes this as \"$severity\".$riskNote Can you comment on the result and support me?';
  }

  @override
  String gad7DiscussPrompt(int score, String severity) {
    return 'I took the GAD-7 questionnaire (anxiety symptoms): $score/21, the method describes this as \"$severity\". Can you comment on the result and support me?';
  }

  @override
  String get commonDone => 'Done';

  @override
  String checkinMaxScoreSuffix(int max) {
    return 'out of $max';
  }

  @override
  String get purchaseAdNotReadyYet => 'Ad isn\'t available yet, try again in a bit.';

  @override
  String get purchaseCheckoutOpenFailed => 'Couldn\'t open the payment page.';

  @override
  String get purchaseTitle => 'Subscription';

  @override
  String get purchaseAvailablePlansSection => 'AVAILABLE PLANS';

  @override
  String get purchaseNoPlansConfigured => 'No plans configured yet.';

  @override
  String get purchaseFreeRequestsGone => 'Out of free requests for today?';

  @override
  String get purchaseTelegramPitch => 'Subscribe to our Telegram channel — get more requests today, every day, while you\'re subscribed.';

  @override
  String get purchaseTelegramLinked => 'Telegram linked';

  @override
  String get purchaseTelegramLinkButton => 'Link Telegram';

  @override
  String get purchaseWatchAdButton => 'Watch an ad (+3)';

  @override
  String purchaseAdBonusRemaining(int count) {
    return 'Bonus requests left from ads: $count';
  }

  @override
  String get purchaseCurrentPlanLabel => 'Current plan';

  @override
  String purchaseTokensUsedNoLimit(int used) {
    return '$used tokens used this month · no limit';
  }

  @override
  String purchaseTokensUsedWithLimit(int used, int limit) {
    return '$used of $limit tokens this month';
  }

  @override
  String get purchaseCurrentBadge => 'current';

  @override
  String purchaseFreeDuration(int days) {
    return 'Free · $days days';
  }

  @override
  String purchasePriceDuration(String rub, String usd, int days) {
    return '$rub / $usd · $days days';
  }

  @override
  String get purchaseComingSoon => 'Coming soon';

  @override
  String get purchaseBuyButton => 'Buy';

  @override
  String get purchaseStripeOption => 'Credit card (Stripe)';

  @override
  String get purchaseTelegramDialogTitle => 'Link Telegram';

  @override
  String get purchaseTelegramDialogBody => 'Open the bot and send it this code in a direct message:';

  @override
  String get purchaseOpenBotButton => 'Open bot';

  @override
  String get voiceSettingsTitle => 'Voice';

  @override
  String get voiceSettingsDisabledByAdmin => 'Voice features are temporarily disabled by the admin.';

  @override
  String get voiceSettingsUseVoice => 'Use voice';

  @override
  String get voiceSettingsHiddenHint => 'The microphone and reading responses aloud are hidden. Turn on the toggle above to bring them back.';

  @override
  String get voiceSettingsSpeechRecognitionSection => 'SPEECH RECOGNITION';

  @override
  String get voiceSettingsMicAvailable => 'Microphone available — the button will appear next to the input field';

  @override
  String get voiceSettingsMicUnavailable => 'Microphone unavailable on this device (no permission or recognition engine)';

  @override
  String get voiceSettingsAutoReadSection => 'READING RESPONSES ALOUD';

  @override
  String get voiceSettingsAutoReadToggle => 'Read responses aloud automatically';

  @override
  String get voiceSettingsVoiceSection => 'VOICE';

  @override
  String get voiceSettingsVoiceInstructions => 'Listen to each one and pick whichever sounds calmer to you — by ear is more reliable than a description.';

  @override
  String get voiceSettingsNoVoicesLoaded => 'Voices haven\'t loaded yet or aren\'t available on this device.';

  @override
  String get voiceSettingsFemaleSection => 'FEMALE VOICE';

  @override
  String get voiceSettingsMaleSection => 'MALE VOICE';

  @override
  String get voiceSettingsOtherSection => 'OTHER OPTIONS';

  @override
  String get voiceSettingsCouldNotClassify => 'Couldn\'t tell the voice\'s gender from its name — just listen and pick.';

  @override
  String get voiceSettingsPreviewTooltip => 'Preview';

  @override
  String authNetworkError(String details) {
    return 'Couldn\'t reach the server.\n$details';
  }

  @override
  String authUnexpectedResponse(int code) {
    return 'The server returned an unexpected response (code $code).';
  }

  @override
  String authDeleteAccountFailed(int code) {
    return 'Couldn\'t delete the account (code $code).';
  }

  @override
  String authRequestFailed(int code) {
    return 'Couldn\'t send the request (code $code).';
  }

  @override
  String authChangePasswordFailed(int code) {
    return 'Couldn\'t change the password (code $code).';
  }

  @override
  String authResendCodeFailed(int code) {
    return 'Couldn\'t resend the code (code $code).';
  }

  @override
  String get authGenericError => 'Authentication error.';

  @override
  String get operatorIssueWarningTitle => 'Issue a warning';

  @override
  String get operatorWarningReasonHint => 'What for — this reason will stay in the history';

  @override
  String get operatorIssueButton => 'Issue';

  @override
  String get operatorRevokeAccessTitle => 'Revoke live-help access?';

  @override
  String operatorRevokeAccessBody(String email) {
    return '$email will no longer be able to take requests. The account and history will remain.';
  }

  @override
  String get operatorRevokeAccessConfirm => 'Revoke access';

  @override
  String get operatorDeleteAccountTitle => 'Delete the account entirely?';

  @override
  String operatorDeleteAccountBody(String email) {
    return 'This is irreversible: $email and their entire request history will be deleted. If you just need to remove access without deleting the account, use \"Revoke access\" instead.';
  }

  @override
  String get operatorDeleteAccountConfirm => 'Delete';

  @override
  String operatorWarningsSectionCount(int count) {
    return 'WARNINGS ($count)';
  }

  @override
  String operatorSessionsSectionCount(int count) {
    return 'REQUESTS ($count)';
  }

  @override
  String get operatorNoSessionsYet => 'Hasn\'t taken any requests yet';

  @override
  String get operatorWarningButtonShort => 'Warning';

  @override
  String get operatorRevokeAccessButtonShort => 'Revoke access';

  @override
  String get operatorDeleteAccountTooltip => 'Delete the account entirely';

  @override
  String operatorIssuedByPrefix(String email) {
    return '· $email';
  }

  @override
  String get operatorUnknownUser => 'unknown';

  @override
  String get operatorNoRating => 'no rating';

  @override
  String operatorQuotedComment(String comment) {
    return '\"$comment\"';
  }

  @override
  String get asrsQ1 => 'How often do you have trouble wrapping up the final details of a project, once the challenging parts have been done?';

  @override
  String get asrsQ2 => 'How often do you have difficulty getting things in order when you have to do a task that requires organization?';

  @override
  String get asrsQ3 => 'How often do you have problems remembering appointments or obligations?';

  @override
  String get asrsQ4 => 'When you have a task that requires a lot of thought, how often do you avoid or delay getting started?';

  @override
  String get asrsQ5 => 'How often do you fidget or squirm with your hands or feet when you have to sit down for a long time?';

  @override
  String get asrsQ6 => 'How often do you feel overly active and compelled to do things, like you were driven by a motor?';

  @override
  String get asrsScaleNever => 'Never';

  @override
  String get asrsScaleRarely => 'Rarely';

  @override
  String get asrsScaleSometimes => 'Sometimes';

  @override
  String get asrsScaleOften => 'Often';

  @override
  String get asrsScaleVeryOften => 'Very often';

  @override
  String get asrsIntroTitle => 'Adult ADHD symptom screening';

  @override
  String get asrsIntroBody => 'An official WHO questionnaire (Adult ADHD Self-Report Scale, short 6-question version). 1-2 minutes. This is a screening, not a diagnosis — a positive result means it\'s worth discussing with a specialist, not that a diagnosis is already there. Only you take it and see the result — nothing is sent to the server.';

  @override
  String get asrsInstructions => 'Over the last 6 months, how often has this happened?';

  @override
  String get asrsShadedCountSuffix => 'out of 6 in the significant range';

  @override
  String get asrsSuggestAssessment => 'The method\'s official threshold (4 out of 6) has been reached — it recommends discussing this with a specialist. This is a screening, not a diagnosis.';

  @override
  String get asrsNoAssessmentNeeded => 'The official method doesn\'t consider this result a reason for further assessment — but if any of this is bothering you, it\'s still worth discussing with a specialist.';

  @override
  String asrsDiscussPrompt(int shaded, String extra) {
    return 'I took the ASRS-v1.1 screening (ADHD): $shaded/6 in the significant range$extra. Can you comment on the result and support me?';
  }

  @override
  String get authBiometricNotConfigured => 'Biometrics (Face ID/fingerprint) aren\'t set up on this device — turn it on in the device\'s own settings first.';

  @override
  String get authBiometricConfirmReason => 'Confirm to turn on biometric sign-in';

  @override
  String get authBiometricConfirmFailed => 'Couldn\'t confirm — try again.';

  @override
  String authUnexpectedErrorGeneric(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get authSessionNotFound => 'Session not found. Sign in again.';

  @override
  String get messageMenuEditRetry => 'Edit and ask again';

  @override
  String get messageMenuCopyText => 'Copy text';

  @override
  String get messageCopiedSnack => 'Copied';

  @override
  String get messageMenuReadAloud => 'Read aloud';

  @override
  String get messageMenuReport => 'Report this response';

  @override
  String get messageMenuDelete => 'Delete message';

  @override
  String get messageEditDialogTitle => 'Edit message';

  @override
  String get messageEditDialogWarning => 'The model\'s response to this message and everything after it will be deleted — the model will answer again based on the edited text.';

  @override
  String get messageRetryButton => 'Ask again';

  @override
  String get messageSourcesAdminOnly => 'SOURCES (visible to admin only)';

  @override
  String messageSourcePageSuffix(int page) {
    return ', p. $page';
  }

  @override
  String messageSourceLine(String filename, String pageSuffix, int similarity) {
    return '$filename$pageSuffix · $similarity%';
  }

  @override
  String get messageChooseWhatYouLike => 'Pick what you like:';

  @override
  String get messageNotNow => 'Not now';

  @override
  String get messageYesLetsTest => 'Yes, let\'s test';

  @override
  String get messageNoLetsContinue => 'No, let\'s continue';

  @override
  String get profilePasswordsDontMatch => 'Passwords don\'t match.';

  @override
  String profileCodeSentToEmail(String email) {
    return 'A code was sent to $email. Enter it below to finish the change.';
  }

  @override
  String get profileConfirmButton => 'Confirm';

  @override
  String get freewritingTitle => 'Freewriting';

  @override
  String get freewritingIntro => 'Write continuously, whatever comes to mind — no censoring, no fixing mistakes, don\'t stop. This isn\'t about nice-sounding text, it\'s about clearing your head.';

  @override
  String get freewritingHowManyMinutes => 'How many minutes?';

  @override
  String freewritingMinutesOption(int minutes) {
    return '$minutes min';
  }

  @override
  String get freewritingStartButton => 'Start writing';

  @override
  String get freewritingFinishButton => 'Finish';

  @override
  String get freewritingHint => 'Keep writing, don\'t stop…';

  @override
  String get freewritingTimeUpBody => 'Time\'s up. You can leave the text on screen and reread it, or clear it right away — whichever suits you.';

  @override
  String get freewritingEmptyPlaceholder => '(empty)';

  @override
  String get freewritingEraseButton => 'Erase';

  @override
  String get freewritingKeepAndCloseButton => 'Keep and close';

  @override
  String get groundingSightSense => 'Sight';

  @override
  String get groundingSightPrompt => 'Name 5 things you can see around you';

  @override
  String get groundingTouchSense => 'Touch';

  @override
  String get groundingTouchPrompt => 'Name 4 things you can touch';

  @override
  String get groundingHearingSense => 'Hearing';

  @override
  String get groundingHearingPrompt => 'Name 3 sounds you can hear right now';

  @override
  String get groundingSmellSense => 'Smell';

  @override
  String get groundingSmellPrompt => 'Name 2 things you can smell';

  @override
  String get groundingTasteSense => 'Taste';

  @override
  String get groundingTastePrompt => 'Name 1 thing you can taste or remember tasting';

  @override
  String get groundingTitle => 'Grounding technique';

  @override
  String get groundingListeningHint => 'Listening — I\'ll switch on my own once you\'re done talking';

  @override
  String get groundingNextButton => 'Next';

  @override
  String get groundingDoneSubtitle => 'You can repeat this any time.';

  @override
  String get groundingIfAnxietyPersists => 'If the anxiety doesn\'t ease up — it\'s normal for one technique not to be enough. You can talk to someone close to you or a specialist.';

  @override
  String get groundingStartOverButton => 'Start over';

  @override
  String get muscleHandsGroup => 'Hands';

  @override
  String get muscleHandsTense => 'Clench your fists tightly';

  @override
  String get muscleHandsRelease => 'Release sharply and feel the warmth';

  @override
  String get muscleShouldersGroup => 'Shoulders';

  @override
  String get muscleShouldersTense => 'Raise your shoulders as high as you can toward your ears';

  @override
  String get muscleShouldersRelease => 'Let go, let your shoulders drop';

  @override
  String get muscleFaceGroup => 'Face';

  @override
  String get muscleFaceTense => 'Squeeze your eyes shut and clench your jaw';

  @override
  String get muscleFaceRelease => 'Relax your face completely';

  @override
  String get muscleAbsGroup => 'Abs';

  @override
  String get muscleAbsTense => 'Tense your stomach as if bracing for a hit';

  @override
  String get muscleAbsRelease => 'Release the tension';

  @override
  String get muscleLegsGroup => 'Legs';

  @override
  String get muscleLegsTense => 'Stretch out your legs and flex your feet';

  @override
  String get muscleLegsRelease => 'Let your legs relax';

  @override
  String get muscleRelaxationTitle => 'Muscle relaxation';

  @override
  String muscleRelaxationIntro(int count) {
    return 'We\'ll tense and relax $count muscle groups one by one. A few seconds of tension each, then release. Get comfortable so nothing restricts moving your arms/legs.';
  }

  @override
  String get muscleStartButton => 'Start';

  @override
  String muscleStepProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String get muscleDoneText => 'Done — all muscle groups completed.';

  @override
  String get muscleRepeatButton => 'Do it again';

  @override
  String chatServerNotResponding(String baseUrl) {
    return 'The server isn\'t responding. Check that the backend is running at $baseUrl';
  }

  @override
  String chatConnectionFailed(String baseUrl, String error) {
    return 'Couldn\'t connect to $baseUrl.\n$error';
  }

  @override
  String get chatSessionExpired => 'Your session expired. Sign out and sign in again.';

  @override
  String chatServerErrorCode(int code) {
    return 'The server returned an error $code';
  }

  @override
  String chatConnectionDroppedMidResponse(String error) {
    return '\n\n⚠️ The connection dropped mid-response (for example, the tunnel went down). Try sending the message again.\n$error';
  }

  @override
  String get chatResponseTruncated => '\n\n⚠️ The response got cut off — the connection closed before the model finished. Try again.';

  @override
  String get chatDoctorSummaryPrompt => 'In 2-3 sentences, briefly describe the person\'s condition to a doctor in the third person, based on this conversation — what\'s bothering them, for how long, what\'s already been discussed. Write it for the doctor as a colleague, not for the person themselves, and don\'t use \"you\".';

  @override
  String get memoryReleaseIntro => 'Write down what\'s hard to hold onto — a heavy thought, a grudge, a memory. No one will see or save it — once you let it go, the text disappears for good, with no way to get it back.';

  @override
  String get memoryReleaseHint => 'Write here…';

  @override
  String get memoryReleaseBurnMode => 'Burn';

  @override
  String get memoryReleaseShatterMode => 'Shatter';

  @override
  String get memoryReleaseBurnedResult => 'Burned away — nothing\'s left of the text.';

  @override
  String get memoryReleaseShatteredResult => 'Shattered to pieces — the text is gone.';

  @override
  String get memoryReleaseWriteMoreButton => 'Write more';

  @override
  String get blogLoadFailed => 'Couldn\'t load the blog.';

  @override
  String get blogLoadPostFailed => 'Couldn\'t load the post.';

  @override
  String get blogLoadListFailed => 'Couldn\'t load the list of posts.';

  @override
  String get blogCreatePostFailed => 'Couldn\'t create the post.';

  @override
  String get blogSavePostFailed => 'Couldn\'t save the post.';

  @override
  String get blogDeletePostFailed => 'Couldn\'t delete the post.';

  @override
  String get blogLikeFailed => 'Couldn\'t like the post.';

  @override
  String get blogLoadCommentsFailed => 'Couldn\'t load comments.';

  @override
  String get blogSendCommentFailed => 'Couldn\'t send the comment.';

  @override
  String get blogDeleteCommentFailed => 'Couldn\'t delete the comment.';

  @override
  String get myHelpCallPersonTitle => 'Call for human help';

  @override
  String get myHelpCallPersonDescription => 'A doctor or specialist from the team will join. This isn\'t a substitute for emergency services — if the situation calls for urgent medical help, call your local emergency number or go straight to an emergency room.';

  @override
  String get myHelpDescribeHint => 'Briefly, what happened (optional)';

  @override
  String get myHelpCallButton => 'Call for help';

  @override
  String get myHelpMyRequestsSection => 'MY REQUESTS';

  @override
  String get myHelpStatusPending => 'Waiting to connect';

  @override
  String get myHelpStatusActive => 'Connected';

  @override
  String get myHelpStatusClosed => 'Closed';

  @override
  String get customTestDefaultTitle => 'Test';

  @override
  String get customTestLoadFailed => 'Couldn\'t load the test.';

  @override
  String customTestQuestionCount(int count) {
    return '$count question(s)';
  }

  @override
  String customTestQuestionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get customTestPointsLabel => 'points';

  @override
  String customTestDiscussPrompt(String title, int score, String resultNote) {
    return 'I took the \"$title\" test: $score point(s)$resultNote. Can you comment on the result and support me?';
  }

  @override
  String customTestResultNote(String label) {
    return ' — result: \"$label\"';
  }

  @override
  String get reportSentTitle => 'Report sent';

  @override
  String get reportSentBody => 'Thanks — we\'ll take a look at this response. The question and answer text was sent along with the report, so it can be reviewed right away without asking you again.';

  @override
  String get reportDialogTitle => 'Report this response';

  @override
  String get reportDialogBody => 'The question and the response you\'re reporting will be sent along with the report — otherwise it won\'t be possible to figure out what exactly went wrong.';

  @override
  String get reportReasonHint => 'What\'s wrong with this response? (optional)';

  @override
  String get helpCreateSessionFailed => 'Couldn\'t create the request.';

  @override
  String get helpLoadSessionsFailed => 'Couldn\'t load requests.';

  @override
  String get helpLoadMessagesFailed => 'Couldn\'t load messages.';

  @override
  String get helpSendMessageFailed => 'Couldn\'t send the message.';

  @override
  String get helpCloseSessionFailed => 'Couldn\'t close the request.';

  @override
  String get helpSendRatingFailed => 'Couldn\'t send the rating.';

  @override
  String get helpLoadRequestsFailed => 'Couldn\'t load requests.';

  @override
  String get helpLoadActiveSessionsFailed => 'Couldn\'t load active requests.';

  @override
  String get helpRequestAlreadyTaken => 'This request was already taken by another operator.';

  @override
  String get helpAcceptRequestFailed => 'Couldn\'t accept the request.';

  @override
  String get breathingInhale => 'Inhale';

  @override
  String get breathingHold => 'Hold';

  @override
  String get breathingExhale => 'Exhale';

  @override
  String get breathingTitle => 'Breathing exercise';

  @override
  String get breathingReadyToStart => 'Ready to start?';

  @override
  String get breathingStopButton => 'Stop';

  @override
  String get breathingDisclaimer => 'A simple breath self-regulation technique — it doesn\'t replace professional help. If you feel dizzy — stop the exercise and breathe at your usual pace.';

  @override
  String get themeVariantViolet => 'Violet';

  @override
  String get themeVariantOcean => 'Ocean';

  @override
  String get themeVariantMidnight => 'Midnight';

  @override
  String get themeVariantSunset => 'Sunset';

  @override
  String get themeVariantForest => 'Forest';

  @override
  String get themeVariantRose => 'Rose';

  @override
  String get themeVariantAmber => 'Amber';

  @override
  String get themeVariantSlate => 'Slate';

  @override
  String get themeVariantMint => 'Mint';

  @override
  String get customTestsLoadListFailed => 'Couldn\'t load the list of tests.';

  @override
  String get customTestsLoadTestFailed => 'Couldn\'t load the test.';

  @override
  String get customTestsSubmitAnswersFailed => 'Couldn\'t submit the answers.';

  @override
  String get customTestsLoadHistoryFailed => 'Couldn\'t load the test history.';

  @override
  String get customTestsCreateFailed => 'Couldn\'t create the test.';

  @override
  String get customTestsSaveFailed => 'Couldn\'t save the test.';

  @override
  String get customTestsDeleteFailed => 'Couldn\'t delete the test.';

  @override
  String get safeContainmentIntro => 'If a thought or feeling is too intense but this isn\'t the time to deal with it — write it down and put it in the safe. It won\'t disappear forever, it\'ll just wait until you have time to come back to it.';

  @override
  String get safeContainmentHint => 'What needs to be set aside for later?';

  @override
  String get safeContainmentPutAwayButton => 'Put in the safe';

  @override
  String get safeContainmentDoneBody => 'Safely tucked away. It won\'t distract you right now — we\'ll come back to it when you\'re ready.';

  @override
  String get voicePreviewPhrase => 'Hi! This is what this voice sounds like.';

  @override
  String appSettingsChangeFailed(int code) {
    return 'Couldn\'t change the setting (code $code).';
  }

  @override
  String appSettingsRestoreFailed(int code) {
    return 'Couldn\'t restore settings (code $code).';
  }

  @override
  String appSettingsLoadPersonaFailed(int code) {
    return 'Couldn\'t load the AI persona settings (code $code).';
  }

  @override
  String appSettingsSavePersonaFailed(int code) {
    return 'Couldn\'t save the AI persona (code $code).';
  }

  @override
  String appSettingsResetPersonaFailed(int code) {
    return 'Couldn\'t reset the AI persona (code $code).';
  }

  @override
  String appSettingsLoadModelFailed(int code) {
    return 'Couldn\'t load model settings (code $code).';
  }

  @override
  String appSettingsSaveModelFailed(int code) {
    return 'Couldn\'t save model settings (code $code).';
  }

  @override
  String appSettingsResetModelFailed(int code) {
    return 'Couldn\'t reset model settings (code $code).';
  }

  @override
  String get reminderPrompt1 => 'How was your day? If you feel like talking — I\'m here.';

  @override
  String get reminderPrompt2 => 'A short pause — how are you doing overall right now?';

  @override
  String get reminderPrompt3 => 'If something\'s been building up that you want to talk about — now\'s a good time.';

  @override
  String get reminderPrompt4 => 'How\'s your mood today? Stop by if you need to get something off your chest.';

  @override
  String get reminderPrompt5 => 'Just a reminder that you can stop by and share how your day went.';

  @override
  String get reminderChannelName => 'Daily reminders';

  @override
  String get reminderChannelDescription => 'A reminder to check in at your chosen time';

  @override
  String get supportTitle => 'Support';

  @override
  String get supportMyTicketsSection => 'YOUR TICKETS';

  @override
  String get supportNoTicketsYet => 'No tickets yet';

  @override
  String get supportDescribeProblem => 'Describe the problem — we\'ll take a look and reply';

  @override
  String get supportHint => 'For example: the model doesn\'t respond to long questions…';

  @override
  String get supportSending => 'Sending…';

  @override
  String get supportTicketOpen => 'Open';

  @override
  String get myReportsTitle => 'My reports';

  @override
  String get myReportsNoneYet => 'No reports yet';

  @override
  String get myReportsResolved => 'Resolved';

  @override
  String get myReportsUnderReview => 'Under review';

  @override
  String get myReportsYourQuestion => 'Your question';

  @override
  String get myReportsAiResponseLabel => 'The AI response you reported';

  @override
  String get myReportsReasonLabel => 'Reason for the report';

  @override
  String get myReportsTeamResponseSection => 'RESPONSE FROM THE TEAM';

  @override
  String get leavesOnStreamTitle => 'Leaves on the stream';

  @override
  String get leavesOnStreamIntro => 'Write down a thought you want to let go of. It\'ll float down the stream and dissolve — nothing is saved.';

  @override
  String get leavesOnStreamHint => 'For example: I\'m afraid I won\'t manage...';

  @override
  String get leavesOnStreamDoneText => 'The thought floated away.';

  @override
  String get bilateralTitle => 'Bilateral stimulation';

  @override
  String get bilateralIntro => 'Follow the ball with your eyes only, without turning your head. This helps reduce the intensity of anxiety. It doesn\'t replace working with a specialist if the anxiety is strong or frequent.';

  @override
  String get operatorDashboardTitle => 'Operator dashboard';

  @override
  String operatorDashboardMyActiveSection(int count) {
    return 'MY ACTIVE ($count)';
  }

  @override
  String operatorDashboardPendingSection(int count) {
    return 'WAITING TO CONNECT ($count)';
  }

  @override
  String get operatorDashboardNoOneWaiting => 'No one is waiting to connect right now';

  @override
  String get operatorDashboardNoDescription => 'No description';

  @override
  String get operatorDashboardAcceptButton => 'Accept';

  @override
  String get gratitudeTitle => 'Gratitude journal';

  @override
  String get gratitudePrompt => 'Three things you\'re grateful for today';

  @override
  String get gratitudeHint => 'It doesn\'t have to be something big — a small thing works too.';

  @override
  String get gratitudeEntriesSection => 'ENTRIES';

  @override
  String gratitudeBulletItem(String item) {
    return '· $item';
  }

  @override
  String get wellbeingCalendarWho5Label => 'WHO-5';

  @override
  String wellbeingCalendarScoreSuffix(int score) {
    return '$score point(s)';
  }

  @override
  String get wellbeingCalendarTitle => 'Wellbeing calendar';

  @override
  String get wellbeingCalendarTakeTestButton => 'Take a test';

  @override
  String get wellbeingCalendarEmptyState => 'No completed questionnaires yet — they\'ll show up here\nonce you take one in the \"Wellbeing\" section.';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get chatQuestionNotFound => '(question not found)';

  @override
  String get chatTestDeclinedContinuation => 'The user tapped \"No, not now\" on the test suggestion. Just continue the conversation naturally, without explicitly mentioning the decline or apologizing for the suggestion.';

  @override
  String cloudVoiceLabelFemale(String name) {
    return '$name (female)';
  }

  @override
  String cloudVoiceLabelMale(String name) {
    return '$name (male)';
  }

  @override
  String get modelDowngradedNotice => 'You\'ve run out of tokens for the advanced AI version this month — this reply came from the regular model. Upgrade your subscription above to get more.';

  @override
  String get modelDowngradedUpgradeButton => 'Upgrade plan';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get sleepMusicTabCatalog => 'Catalog';

  @override
  String get sleepMusicTabPlaylists => 'My playlists';

  @override
  String get sleepMusicNoPlaylists => 'No playlists yet — create your first one.';

  @override
  String get sleepMusicCreatePlaylist => 'Create playlist';

  @override
  String get sleepMusicNewPlaylistHint => 'Playlist name';

  @override
  String get sleepMusicEmptyPlaylist => 'This playlist has no tracks yet.';

  @override
  String get sleepMusicAddTrack => 'Add track';

  @override
  String get sleepMusicAddFromCatalog => 'From catalog';

  @override
  String get sleepMusicUploadOwnFile => 'Upload your own file';

  @override
  String get sleepMusicRemoveFromPlaylist => 'Remove from playlist';

  @override
  String get sleepMusicDeletePlaylist => 'Delete playlist';

  @override
  String sleepMusicDeletePlaylistConfirm(String name) {
    return 'Delete playlist \"$name\"? The tracks themselves will stay in the catalog/your library.';
  }

  @override
  String get sleepMusicOwnFileWebNotice => 'On the web your own file will only play until the page reloads — it can\'t be saved permanently here.';

  @override
  String get sleepMusicFileReadError => 'Couldn\'t read the file.';

  @override
  String get sleepMusicNoTracksInCatalogYet => 'No sounds in the catalog yet — an admin needs to add some first.';

  @override
  String get sleepMusicTimerCancel => 'Turn off timer';

  @override
  String sleepMusicTimerMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get sleepMusicRenamePlaylist => 'Rename playlist';

  @override
  String get sleepMusicLikedTitle => 'Liked';

  @override
  String get sleepMusicNoLikedYet => 'No liked tracks yet — tap the heart on any track.';
}
