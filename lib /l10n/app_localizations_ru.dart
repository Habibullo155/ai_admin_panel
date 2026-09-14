// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'AI Glass Chat';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonLoading => 'Загрузка...';

  @override
  String get commonError => 'Ошибка';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonLogout => 'Выйти';

  @override
  String get authSignInTitle => 'Вход в AI Chat';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authPasswordHint => 'Пароль';

  @override
  String get authRepeatPasswordHint => 'Повтори пароль';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authRegisterButton => 'Зарегистрироваться';

  @override
  String get authLoginButton => 'Войти';

  @override
  String get authHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get authNoAccount => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get authPasswordLengthOk => 'Длина пароля подходит';

  @override
  String authPasswordLengthHint(int minLength, int length) {
    return 'Минимум $minLength символов (введено: $length)';
  }

  @override
  String get authPasswordsMatch => 'Пароли совпадают';

  @override
  String get authPasswordsMismatch => 'Пароли не совпадают';

  @override
  String get forgotPasswordTitle => 'Восстановление пароля';

  @override
  String get forgotPasswordEmailPrompt => 'Укажи email, на который зарегистрирован аккаунт — пришлём код для сброса пароля.';

  @override
  String get forgotPasswordSendCode => 'Отправить код';

  @override
  String get forgotPasswordCheckEmail => 'Если такой email зарегистрирован — на него отправлен код для восстановления пароля. Проверь почту (и папку \"Спам\") и введи код ниже вместе с новым паролем.';

  @override
  String get forgotPasswordHaveCode => 'У меня есть код';

  @override
  String get forgotPasswordResend => 'Отправить ещё раз';

  @override
  String get forgotPasswordCodeTitle => 'Код из письма';

  @override
  String get forgotPasswordCodeHint => 'Код';

  @override
  String get forgotPasswordNewPasswordHint => 'Новый пароль';

  @override
  String get forgotPasswordSubmit => 'Сменить пароль';

  @override
  String get forgotPasswordDone => 'Пароль изменён. Теперь можно войти с новым паролем.';

  @override
  String get lockScreenTitle => 'Приложение заблокировано';

  @override
  String get lockScreenFailedHint => 'Не удалось подтвердить — попробуй ещё раз.';

  @override
  String get lockScreenPrompt => 'Подтверди личность, чтобы продолжить.';

  @override
  String get lockScreenUnlockButton => 'Разблокировать';

  @override
  String get lockScreenUsePassword => 'Войти паролем';

  @override
  String get verifyEmailTitle => 'Подтверждение почты';

  @override
  String get verifyEmailPromptGeneric => 'Введи код, который пришёл на почту при регистрации.';

  @override
  String verifyEmailPromptWithEmail(String email) {
    return 'Введи код, который пришёл на $email.';
  }

  @override
  String get verifyEmailCodeHint => 'Код из письма';

  @override
  String get verifyEmailResendButton => 'Отправить код ещё раз';

  @override
  String get verifyEmailSubmitButton => 'Подтвердить';

  @override
  String get verifyEmailResentMessage => 'Код отправлен повторно — проверь почту.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSectionAppearance => 'ОФОРМЛЕНИЕ';

  @override
  String get settingsThemeLabel => 'Тема';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsBackgroundColorLabel => 'Цвет фона';

  @override
  String get settingsSectionPerformance => 'ПРОИЗВОДИТЕЛЬНОСТЬ';

  @override
  String get settingsPerformanceModeLabel => 'Экономный режим';

  @override
  String get settingsPerformanceModeDescription => 'Отключает анимированный фон и размытие \"стекла\" по всему приложению. Стоит включить, если телефон слабый, тормозит или перегревается — на большинстве устройств в этом нет необходимости.';

  @override
  String get settingsSectionNotifications => 'УВЕДОМЛЕНИЯ';

  @override
  String get settingsSoundOnMessage => 'Звук на новое сообщение';

  @override
  String get settingsVibrationOnMessage => 'Вибрация на новое сообщение';

  @override
  String get settingsSectionVoice => 'ГОЛОС';

  @override
  String get settingsVoiceButtonsInChat => 'Голосовые кнопки в чате';

  @override
  String get settingsVoiceAndSpeechRecognition => 'Выбор голоса и распознавание речи';

  @override
  String get settingsSectionSecurity => 'БЕЗОПАСНОСТЬ';

  @override
  String get settingsBiometricLogin => 'Вход по биометрии';

  @override
  String get settingsBiometricNotSupported => 'На этом устройстве не настроена биометрия (Face ID/отпечаток) — включи её в настройках самого устройства, если хочешь использовать здесь.';

  @override
  String get settingsSectionReminders => 'НАПОМИНАНИЯ';

  @override
  String get settingsReminderDescription => 'Раз в день, в выбранное время (например, когда ты обычно уже дома) — просто предложит заглянуть, если захочется поговорить.';

  @override
  String get settingsDailyReminder => 'Ежедневное напоминание';

  @override
  String get settingsReminderTimeLabel => 'Время';

  @override
  String get settingsReminderPermissionDenied => 'Нет разрешения на уведомления — включи их в настройках устройства для этого приложения.';

  @override
  String get settingsSectionAccount => 'АККАУНТ';

  @override
  String get settingsLogoutButton => 'Выйти из аккаунта';

  @override
  String get settingsSectionAbout => 'О ПРИЛОЖЕНИИ';

  @override
  String get settingsAppVersion => 'Версия 1.0.0';

  @override
  String get settingsModelInfo => 'Модель по умолчанию: gemma4:e2b через локальный Ollama.';

  @override
  String get settingsSectionDangerZone => 'ОПАСНАЯ ЗОНА';

  @override
  String get settingsDeleteAccountButton => 'Удалить аккаунт';

  @override
  String get settingsDeleteAccountDialogTitle => 'Удалить аккаунт?';

  @override
  String get settingsDeleteAccountWarning => 'Это необратимо: аккаунт, история обращений в поддержку и статистика использования будут удалены полностью. История переписки на этом устройстве останется — она никогда не хранилась на сервере, и её можно удалить отдельно.';

  @override
  String get settingsConfirmWithPassword => 'Подтверди паролем';

  @override
  String get settingsDeleteForeverButton => 'Удалить навсегда';

  @override
  String get chatNoSoundsUploaded => 'Пока нет загруженных звуков — админ ещё не добавил их.';

  @override
  String get chatStopButton => 'Остановить';

  @override
  String get chatRoleUser => 'Пользователь';

  @override
  String get chatRoleAi => 'ИИ';

  @override
  String get chatMigraineLabel => 'Мигрень или сильная усталость';

  @override
  String get chatWhatDoYouNeedNow => 'Что нужно сейчас?';

  @override
  String get chatTakeTestTitle => 'Пройти тест';

  @override
  String get chatTakeTestSubtitle => 'Опросник — результат сразу обсудим здесь';

  @override
  String get chatWhichQuestionnaire => 'Какой опросник?';

  @override
  String get chatPhq9Subtitle => 'Депрессивные симптомы, 9 вопросов';

  @override
  String get chatGad7Subtitle => 'Тревожные симптомы, 7 вопросов';

  @override
  String get chatAsrsSubtitle => 'Скрининг СДВГ, 6 вопросов';

  @override
  String get chatOtherTestsTitle => 'Другие тесты';

  @override
  String get chatOtherTestsSubtitle => 'Опросники, созданные командой';

  @override
  String get chatCallHelpTitle => 'Позвать человека на помощь?';

  @override
  String get chatCallHelpDescription => 'Подключится врач или специалист из команды. Это не замена экстренной службе — если ситуация требует срочной медицинской помощи, звони в местную службу экстренной помощи.';

  @override
  String get chatPrepareSummaryQuestion => 'Подготовить врачу краткую сводку о разговоре с ИИ (не переписку целиком), чтобы не объяснять всё заново?';

  @override
  String get chatYesPrepareSummary => 'Да, подготовить сводку';

  @override
  String get chatNoDontShow => 'Нет, не показывать';

  @override
  String get chatCallButton => 'Позвать';

  @override
  String get chatCloseTooltip => 'Закрыть';

  @override
  String get chatNewChatTitle => 'Новый чат';

  @override
  String get chatDisclaimer => 'ИИ может ошибаться. Проверяй важную информацию самостоятельно.';

  @override
  String get chatVerifyEmailBanner => 'Подтверди почту';

  @override
  String get chatMuteBackgroundSound => 'Выключить фоновый звук';

  @override
  String get chatUnmuteBackgroundSound => 'Включить фоновый звук';

  @override
  String get chatMenuTooltip => 'Меню';

  @override
  String get chatMenuProfile => 'Личный кабинет';

  @override
  String get chatMenuWellbeing => 'Самочувствие';

  @override
  String get chatMenuSleepMusic => 'Музыка для сна';

  @override
  String get chatMenuSubscription => 'Подписка';

  @override
  String get chatMenuMyReports => 'Мои жалобы';

  @override
  String get chatMenuLiveHelp => 'Живая помощь';

  @override
  String get chatMenuOperatorCabinet => 'Кабинет оператора';

  @override
  String get chatMenuSupport => 'Поддержка';

  @override
  String get chatMenuBlog => 'Блог';

  @override
  String get chatSuggestion1 => 'Объясни квантовую физику простыми словами';

  @override
  String get chatSuggestion2 => 'Напиши план тренировок на неделю';

  @override
  String get chatSuggestion3 => 'Помоги придумать название для проекта';

  @override
  String get chatSuggestion4 => 'Как улучшить свой код на Dart?';

  @override
  String get chatWhatCanIHelpWith => 'Чем помочь сегодня?';

  @override
  String get aiModeSupportTitle => 'Поддержать';

  @override
  String get aiModeSupportSubtitle => 'Просто побыть рядом в разговоре';

  @override
  String get aiModeSupportOpener => 'Мне сейчас нужна поддержка — просто побудь рядом в разговоре, подбодри меня.';

  @override
  String get aiModeListenTitle => 'Просто выслушать';

  @override
  String get aiModeListenSubtitle => 'Не обязательно сразу советовать';

  @override
  String get aiModeListenOpener => 'Мне просто нужно выговориться — послушай, не обязательно сразу давать советы.';

  @override
  String get aiModeBreakupTitle => 'Развод или разрыв отношений';

  @override
  String get aiModeBreakupSubtitle => 'Начать разговор об этом';

  @override
  String get aiModeBreakupOpener => 'У меня сейчас развод или расставание, и мне тяжело с этим справляться. Можешь поддержать меня в разговоре об этом?';

  @override
  String get aiModeGriefTitle => 'Тяжёлая утрата';

  @override
  String get aiModeGriefSubtitle => 'Начать разговор об этом';

  @override
  String get aiModeGriefOpener => 'У меня недавно случилась тяжёлая утрата близкого человека, и мне хочется с кем-то об этом поговорить.';

  @override
  String get aiModeJobLossTitle => 'Потеря работы или крупные перемены';

  @override
  String get aiModeJobLossSubtitle => 'Начать разговор об этом';

  @override
  String get aiModeJobLossOpener => 'У меня сейчас сложный период — потеряна работа или произошла резкая перемена в жизни, и это тяжело переживать. Можешь поддержать меня в разговоре об этом?';

  @override
  String get aiModeRationalizerTitle => 'Рационализатор';

  @override
  String get aiModeRationalizerSubtitle => 'Разобрать тревожную мысль по методике КПТ';

  @override
  String get aiModeRationalizerOpener => 'У меня есть тревожная мысль, которая не даёт покоя. Помоги мне разобрать её по методике КПТ — задавай мне наводящие вопросы по одному за раз (например, какие есть доказательства этой мысли, что самое худшее может случиться и насколько это вероятно), чтобы посмотреть на ситуацию яснее.';

  @override
  String get profileBirthDateHelpText => 'Дата рождения';

  @override
  String profileAgeYears(int age) {
    String _temp0 = intl.Intl.pluralLogic(
      age,
      locale: localeName,
      other: '$age лет',
      many: '$age лет',
      few: '$age года',
      one: '$age год',
    );
    return '$_temp0';
  }

  @override
  String get profileTakePhoto => 'Сделать фото';

  @override
  String get profileChooseFromGallery => 'Выбрать из галереи';

  @override
  String get profileDeletePhoto => 'Удалить фото';

  @override
  String get profileTitle => 'Личный кабинет';

  @override
  String get profileNoData => 'Нет данных';

  @override
  String get profileSectionPersonal => 'ЛИЧНОЕ';

  @override
  String get profileFullName => 'ФИО';

  @override
  String get profileNotSpecified => 'не указано';

  @override
  String get profileBirthDate => 'Дата рождения';

  @override
  String get profileHobbies => 'Хобби';

  @override
  String get profileEmergencyContact => 'Экстренный контакт';

  @override
  String get profileSectionAccount => 'АККАУНТ';

  @override
  String get profileRole => 'Роль';

  @override
  String get profileRoleAdmin => 'Администратор';

  @override
  String get profileRoleUser => 'Пользователь';

  @override
  String get profileAccountCreated => 'Аккаунт создан';

  @override
  String get profileEditButton => 'Редактировать профиль';

  @override
  String get profileChangePasswordButton => 'Изменить пароль';

  @override
  String get profileEditTitle => 'Личные данные';

  @override
  String get profileEditHint => 'Все поля необязательны — оставь пустым, чтобы очистить.';

  @override
  String get profileEmergencySectionLabel => 'НА ВСЯКИЙ СЛУЧАЙ';

  @override
  String get profileEmergencyContactHint => 'Например: Мама, +7 900 123-45-67';

  @override
  String get profileLogoutButton => 'Выйти';

  @override
  String get profilePasswordTooShort => 'Новый пароль должен быть не короче 8 символов.';

  @override
  String get profilePasswordsMismatch => 'Пароли не совпадают.';

  @override
  String get profileChangePasswordTitle => 'Изменить пароль';

  @override
  String get profileCurrentPasswordLabel => 'Текущий пароль';

  @override
  String get profileNewPasswordLabel => 'Новый пароль';

  @override
  String get profileRepeatNewPasswordLabel => 'Повтори новый пароль';

  @override
  String get profileChangeEmailTitle => 'Изменить почту';

  @override
  String profileCurrentEmailLabel(String email) {
    return 'Сейчас: $email';
  }

  @override
  String get profileNewEmailLabel => 'Новый адрес';

  @override
  String profileCodeSentMessage(String email) {
    return 'Код отправлен на $email. Введи его ниже, чтобы завершить смену.';
  }

  @override
  String get profileCodeFromEmailLabel => 'Код из письма';

  @override
  String get profileSendCodeButton => 'Отправить код';

  @override
  String get sidebarCalendarTitle => 'Календарь';

  @override
  String get sidebarCalendarSubtitle => 'Результаты опросников по дням';

  @override
  String get sidebarWellbeingSubtitle => 'Пройти тест, ситуативная помощь';

  @override
  String get sidebarCallHelpTitle => 'Позвать на помощь';

  @override
  String get sidebarCallHelpSubtitle => 'Подключится врач или специалист';

  @override
  String get sidebarHistoryLabel => 'ИСТОРИЯ';

  @override
  String get sidebarNoConversations => 'Пока нет диалогов';

  @override
  String get sidebarRenameChatTitle => 'Переименовать чат';

  @override
  String get sidebarDeleteChatTitle => 'Удалить чат?';

  @override
  String sidebarDeleteChatBody(String title) {
    return 'Переписка «$title» будет удалена без возможности восстановить.';
  }

  @override
  String get sidebarEmptyConversation => 'Пусто';

  @override
  String get crisisResourcesDefaultTitle => 'Если хочется поговорить с кем-то';

  @override
  String get crisisResourcesBody => '• Экстренная психологическая помощь для взрослых и детей в России, круглосуточно и бесплатно: 8-800-100-49-94\n• Детский и подростковый телефон доверия: 8-800-2000-122 (короткий номер — 124)\n\nЕсли ты не в России — поищи местную кризисную линию по запросу «suicide crisis line» и название своей страны; в США и Канаде можно позвонить или написать на 988.';

  @override
  String get navChat => 'Чат';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navSleep => 'Сон';

  @override
  String get navWellbeing => 'Забота';

  @override
  String get sleepMusicTitle => 'Музыка для сна';

  @override
  String get sleepMusicNoneUploaded => 'Пока нет загруженной музыки — админ ещё не добавил её.';

  @override
  String get customTestListTitle => 'Тесты';

  @override
  String get customTestListEmpty => 'Пока нет доступных тестов.';

  @override
  String get blogTitle => 'Блог';

  @override
  String get blogListEmpty => 'Постов пока нет — загляни позже.';

  @override
  String get who5Q1 => 'Я чувствую себя бодрой(-ым) и в хорошем настроении';

  @override
  String get who5Q2 => 'Я чувствую себя спокойной(-ым) и раскованной(-ым)';

  @override
  String get who5Q3 => 'Я чувствую себя активной(-ым) и энергичной(-ым)';

  @override
  String get who5Q4 => 'Я просыпаюсь и чувствую себя свежей(-им) и отдохнувшей(-им)';

  @override
  String get who5Q5 => 'Каждый день со мной происходят вещи, представляющие для меня интерес';

  @override
  String get who5ScaleAllTime => 'Всё время';

  @override
  String get who5ScaleMostTime => 'Большую часть времени';

  @override
  String get who5ScaleMoreThanHalf => 'Более половины времени';

  @override
  String get who5ScaleLessThanHalf => 'Менее половины времени';

  @override
  String get who5ScaleSomeTime => 'Некоторое время';

  @override
  String get who5ScaleNever => 'Никогда';

  @override
  String get wellbeingSaveFailed => 'Не удалось сохранить результат локально. Можно пройти ещё раз.';

  @override
  String get wellbeingToolsSection => 'ИНСТРУМЕНТЫ';

  @override
  String get wellbeingBreathingTitle => 'Дыхание';

  @override
  String get wellbeingGroundingTitle => 'Заземление';

  @override
  String get wellbeingGratitudeTitle => 'Благодарность';

  @override
  String get wellbeingGratitudeSubtitle => 'Дневник';

  @override
  String get wellbeingBilateralTitle => 'Билатеральная стимуляция';

  @override
  String get wellbeingBilateralSubtitle => 'Слежение глазами';

  @override
  String get wellbeingMuscleRelaxationTitle => 'Мышечная релаксация';

  @override
  String get wellbeingMuscleRelaxationSubtitle => 'Напряжение/отдых';

  @override
  String get wellbeingSafeTitle => 'Сейф';

  @override
  String get wellbeingSafeSubtitle => 'Убрать мысль на потом';

  @override
  String get wellbeingLeavesTitle => 'Листья на ручье';

  @override
  String get wellbeingLeavesSubtitle => 'Отпустить мысль';

  @override
  String get wellbeingFreewritingTitle => 'Фрирайтинг';

  @override
  String get wellbeingFreewritingSubtitle => 'Выгрузка мыслей';

  @override
  String get wellbeingQuestionnairesSection => 'ОПРОСНИКИ';

  @override
  String get wellbeingQuestionnairesDisclaimer => 'Официальные, свободно распространяемые инструменты. Не диагностика — только скрининг для себя.';

  @override
  String get who5CardTitle => 'ВОЗ-5 — общее самочувствие';

  @override
  String get wellbeingReleaseTitle => 'Отпустить';

  @override
  String get wellbeingReleaseSubtitle => 'Написать тяжёлую мысль и сжечь/разбить её';

  @override
  String get wellbeingSleepMusicTitle => 'Музыка для сна';

  @override
  String get wellbeingSleepMusicSubtitle => 'Спокойные звуки перед сном';

  @override
  String get who5HistorySection => 'ИСТОРИЯ ВОЗ-5';

  @override
  String get who5Instructions => 'Отметь, что ближе всего к тому, как ты себя чувствовал(а) последние две недели.';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonNext => 'Далее';

  @override
  String get who5ShowResult => 'Показать результат';

  @override
  String get who5ResultLow => 'Показатель ниже среднего';

  @override
  String get who5ResultNormal => 'Показатель в пределах нормы';

  @override
  String get who5DescriptionLow => 'Это не диагноз. По методике ВОЗ балл ниже 50% — повод обратиться к специалисту для более точной оценки состояния, особенно если так продолжается больше двух недель.';

  @override
  String get who5DescriptionNormal => 'Официальная методика ВОЗ считает такой результат признаком нормального психологического благополучия за последние две недели.';

  @override
  String who5DiscussPrompt(String score, String extra) {
    return 'Я прошёл(ла) опросник ВОЗ-5 (общее самочувствие): $score%$extra. Можешь прокомментировать результат и поддержать меня?';
  }

  @override
  String get who5RecommendSpecialist => ' — методика рекомендует обсудить со специалистом';

  @override
  String get who5DiscussButton => 'Обсудить с ИИ';

  @override
  String get who5BackToHistory => 'К истории';

  @override
  String get wellbeingAiDisclaimer => 'ИИ и автоматические подсчёты могут ошибаться. Этот опросник — инструмент для самонаблюдения, а не диагностика. Для точной оценки психологического состояния обратись к врачу или психотерапевту.';

  @override
  String get wellbeingBreathingSubtitle => '4 фазы по 4 сек';

  @override
  String get who5CardSubtitle => '5 вопросов, минута';

  @override
  String get phq9TileTitle => 'PHQ-9 — депрессивные симптомы';

  @override
  String get phq9TileSubtitle => '9 вопросов, 2-3 минуты';

  @override
  String get gad7TileTitle => 'GAD-7 — тревожные симптомы';

  @override
  String get gad7TileSubtitle => '7 вопросов, 1-2 минуты';

  @override
  String get asrsTileTitle => 'ASRS-v1.1 — скрининг СДВГ';

  @override
  String get asrsTileSubtitle => '6 вопросов, 1-2 минуты';

  @override
  String get who5LicenseAttribution => 'Опросник: World Health Organization-Five Well-Being Index (WHO-5), © World Health Organization 2024, лицензия CC BY-NC-SA 3.0 IGO. Использование ВОЗ этого приложения не подразумевается.';

  @override
  String get helpNoCheckinsSnack => 'Пока нет пройденных опросников — их можно пройти в разделе «Самочувствие».';

  @override
  String get helpPickResultTitle => 'Какой результат отправить?';

  @override
  String get helpWeekSummaryTitle => 'Сводка за неделю';

  @override
  String helpWeekSummaryScore(int count) {
    return '$count записей';
  }

  @override
  String get helpWeekSummaryHeader => 'Результаты опросников за последние 7 дней:';

  @override
  String helpWeekLineWho5(String date, int percent) {
    return '• ВОЗ-5 ($date): $percent%';
  }

  @override
  String helpWeekLinePhq9(String date, int score, String severity, String risk) {
    return '• PHQ-9 ($date): $score/27, «$severity»$risk';
  }

  @override
  String helpWeekLineGad7(String date, int score, String severity) {
    return '• GAD-7 ($date): $score/21, «$severity»';
  }

  @override
  String helpWeekLineAsrs(String date, int shaded) {
    return '• ASRS-v1.1 ($date): $shaded/6';
  }

  @override
  String get helpRiskSignalPhq9Week => ' — отмечены мысли о самоповреждении';

  @override
  String helpSingleWho5Result(String date, int percent, String extra) {
    return 'Результат опросника ВОЗ-5 ($date): $percent%$extra.';
  }

  @override
  String helpSinglePhq9Result(String date, int score, String severity, String risk) {
    return 'Результат опросника PHQ-9 ($date): $score/27, методика описывает это как «$severity»$risk.';
  }

  @override
  String get helpPhq9RiskNote => '. Отмечены мысли о самоповреждении в пункте 9';

  @override
  String helpSingleGad7Result(String date, int score, String severity) {
    return 'Результат опросника GAD-7 ($date): $score/21, методика описывает это как «$severity».';
  }

  @override
  String helpSingleAsrsResult(String date, int shaded, String extra) {
    return 'Результат опросника ASRS-v1.1 ($date): $shaded/6 в зоне значимости$extra.';
  }

  @override
  String get helpClosedStatus => 'Обращение закрыто';

  @override
  String helpConnectedStatus(String email) {
    return 'Подключён: $email';
  }

  @override
  String get helpWaitingStatus => 'Ждём, когда кто-то подключится…';

  @override
  String get helpSendTestResultsTooltip => 'Отправить результаты теста';

  @override
  String get helpFinishButton => 'Завершить';

  @override
  String get helpRequestSentHint => 'Заявка отправлена — сообщение появится, как только кто-то подключится.';

  @override
  String get helpWriteWhatHappenedHint => 'Напиши, что случилось.';

  @override
  String get helpMessageHint => 'Написать сообщение…';

  @override
  String get helpChatContextHeader => 'Что происходило в чате с ИИ до этого обращения';

  @override
  String get helpYourRatingTitle => 'Твоя оценка';

  @override
  String get helpRatingQuestion => 'Как прошло общение с оператором?';

  @override
  String get helpCommentHint => 'Комментарий (необязательно)';

  @override
  String get commonSend => 'Отправить';

  @override
  String get phq9Q1 => 'Вас мало интересовали дела или ничто не доставляло удовольствия';

  @override
  String get phq9Q2 => 'Вы испытывали чувство подавленности, депрессии или безнадёжности';

  @override
  String get phq9Q3 => 'У вас были проблемы с засыпанием или сном, или вы слишком много спали';

  @override
  String get phq9Q4 => 'Вы чувствовали усталость или недостаток энергии';

  @override
  String get phq9Q5 => 'Плохой аппетит или переедание';

  @override
  String get phq9Q6 => 'Вы испытывали чувство неудовлетворённости собой — или думали о том, что вы неудачник, или что подводите себя или свою семью';

  @override
  String get phq9Q7 => 'Трудности с концентрацией внимания, например, когда читаете газету или смотрите телевизор';

  @override
  String get phq9Q8 => 'Вы двигаетесь или говорите настолько медленно, что другие люди могли это заметить. Или наоборот — вы настолько беспокойны или суетливы, что двигаетесь гораздо больше обычного';

  @override
  String get phq9Q9 => 'Мысли о том, что вам было бы лучше умереть, или о том, чтобы навредить себе каким-либо образом';

  @override
  String get gad7Q1 => 'Чувство нервозности, тревоги или напряжённости';

  @override
  String get gad7Q2 => 'Неспособность остановить или контролировать беспокойство';

  @override
  String get gad7Q3 => 'Слишком сильное беспокойство о разных вещах';

  @override
  String get gad7Q4 => 'Трудности с расслаблением';

  @override
  String get gad7Q5 => 'Такое беспокойство, что трудно усидеть на месте';

  @override
  String get gad7Q6 => 'Лёгкая раздражительность или вспыльчивость';

  @override
  String get gad7Q7 => 'Чувство страха, как будто может случиться что-то ужасное';

  @override
  String get pfizerScaleNotAtAll => 'Совсем не беспокоило';

  @override
  String get pfizerScaleSeveralDays => 'Несколько дней';

  @override
  String get pfizerScaleMoreThanHalf => 'Более половины дней';

  @override
  String get pfizerScaleNearlyEveryDay => 'Почти каждый день';

  @override
  String get pfizerSeverityMinimal => 'минимальная выраженность';

  @override
  String get pfizerSeverityMild => 'лёгкая выраженность';

  @override
  String get pfizerSeverityModerate => 'умеренная выраженность';

  @override
  String get phq9SeverityModeratelySevere => 'умеренно выраженная тяжесть';

  @override
  String get pfizerSeveritySevere => 'выраженная тяжесть симптомов';

  @override
  String get phq9IntroTitle => 'Опросник выраженности депрессивных симптомов';

  @override
  String get phq9IntroBody => 'Официальный, широко используемый в первичной медицинской помощи скрининговый инструмент (Patient Health Questionnaire-9). 9 вопросов, 2-3 минуты. Это не диагностика — результат показывает выраженность симптомов за последние 2 недели, а не медицинское заключение. Проходишь и видишь результат только ты — на сервер ничего не отправляется.';

  @override
  String get gad7IntroTitle => 'Опросник выраженности тревожных симптомов';

  @override
  String get gad7IntroBody => 'Официальный, широко используемый в первичной медицинской помощи скрининговый инструмент (Generalized Anxiety Disorder-7). 7 вопросов, 1-2 минуты. Это не диагностика — результат показывает выраженность симптомов за последние 2 недели, а не медицинское заключение. Проходишь и видишь результат только ты — на сервер ничего не отправляется.';

  @override
  String get checkinTakeTestButton => 'Пройти опросник';

  @override
  String get checkinRetakeTestButton => 'Пройти ещё раз';

  @override
  String get checkinHistorySection => 'ИСТОРИЯ';

  @override
  String get pfizerInstructions => 'За последние 2 недели, как часто вас беспокоили следующие проблемы?';

  @override
  String get checkinIfHardRightNow => 'Если тебе сейчас тяжело';

  @override
  String pfizerSeverityDescription(String severity) {
    return 'Методика описывает такой результат как: $severity.';
  }

  @override
  String get pfizerSuggestAssessment => 'При таком результате методика рекомендует обсудить его со специалистом — это скрининг, не диагноз.';

  @override
  String get pfizerNoAssessmentNeeded => 'Официальная методика не считает такой результат поводом для дополнительной оценки — но если тебе тяжело, это не отменяется этой цифрой.';

  @override
  String get phq9RiskNoteDiscuss => ' В пункте про мысли о самоповреждении был отмечен положительный ответ.';

  @override
  String phq9DiscussPrompt(int score, String severity, String riskNote) {
    return 'Я прошёл(ла) опросник PHQ-9 (депрессивные симптомы): $score/27, методика описывает это как «$severity».$riskNote Можешь прокомментировать результат и поддержать меня?';
  }

  @override
  String gad7DiscussPrompt(int score, String severity) {
    return 'Я прошёл(ла) опросник GAD-7 (тревожные симптомы): $score/21, методика описывает это как «$severity». Можешь прокомментировать результат и поддержать меня?';
  }

  @override
  String get commonDone => 'Готово';

  @override
  String checkinMaxScoreSuffix(int max) {
    return 'из $max';
  }

  @override
  String get purchaseAdNotReadyYet => 'Реклама пока недоступна, попробуй чуть позже.';

  @override
  String get purchaseCheckoutOpenFailed => 'Не удалось открыть страницу оплаты.';

  @override
  String get purchaseTitle => 'Подписка';

  @override
  String get purchaseAvailablePlansSection => 'ДОСТУПНЫЕ ТАРИФЫ';

  @override
  String get purchaseNoPlansConfigured => 'Тарифы пока не настроены.';

  @override
  String get purchaseFreeRequestsGone => 'Закончились бесплатные запросы на сегодня?';

  @override
  String get purchaseTelegramPitch => 'Подпишись на наш Telegram-канал — получишь ещё запросов на сегодня, каждый день, пока подписан.';

  @override
  String get purchaseTelegramLinked => 'Telegram привязан';

  @override
  String get purchaseTelegramLinkButton => 'Привязать Telegram';

  @override
  String get purchaseWatchAdButton => 'Смотреть рекламу (+3)';

  @override
  String purchaseAdBonusRemaining(int count) {
    return 'Бонусных запросов от рекламы осталось: $count';
  }

  @override
  String get purchaseCurrentPlanLabel => 'Текущий тариф';

  @override
  String purchaseTokensUsedNoLimit(int used) {
    return '$used токенов использовано в этом месяце · без лимита';
  }

  @override
  String purchaseTokensUsedWithLimit(int used, int limit) {
    return '$used из $limit токенов в этом месяце';
  }

  @override
  String get purchaseCurrentBadge => 'текущий';

  @override
  String purchaseFreeDuration(int days) {
    return 'Бесплатно · $days дней';
  }

  @override
  String purchasePriceDuration(String rub, String usd, int days) {
    return '$rub / $usd · $days дней';
  }

  @override
  String get purchaseComingSoon => 'Скоро будет доступно';

  @override
  String get purchaseBuyButton => 'Купить';

  @override
  String get purchaseStripeOption => 'Банковская карта (Stripe)';

  @override
  String get purchaseTelegramDialogTitle => 'Привязка Telegram';

  @override
  String get purchaseTelegramDialogBody => 'Открой бота и отправь ему этот код в личные сообщения:';

  @override
  String get purchaseOpenBotButton => 'Открыть бота';

  @override
  String get voiceSettingsTitle => 'Голос';

  @override
  String get voiceSettingsDisabledByAdmin => 'Голосовые функции временно выключены администратором.';

  @override
  String get voiceSettingsUseVoice => 'Использовать голос';

  @override
  String get voiceSettingsHiddenHint => 'Микрофон и озвучка ответов скрыты. Включи переключатель выше, чтобы вернуть их.';

  @override
  String get voiceSettingsSpeechRecognitionSection => 'РАСПОЗНАВАНИЕ РЕЧИ';

  @override
  String get voiceSettingsMicAvailable => 'Микрофон доступен — кнопка появится рядом с полем ввода';

  @override
  String get voiceSettingsMicUnavailable => 'Микрофон недоступен на этом устройстве (нет разрешения или движка распознавания)';

  @override
  String get voiceSettingsAutoReadSection => 'ОЗВУЧКА ОТВЕТОВ';

  @override
  String get voiceSettingsAutoReadToggle => 'Озвучивать ответы автоматически';

  @override
  String get voiceSettingsVoiceSection => 'ГОЛОС';

  @override
  String get voiceSettingsVoiceInstructions => 'Прослушай каждый и выбери тот, что звучит для тебя спокойнее — на слух это надёжнее, чем описание.';

  @override
  String get voiceSettingsNoVoicesLoaded => 'Голоса ещё не загрузились или недоступны на этом устройстве.';

  @override
  String get voiceSettingsFemaleSection => 'ЖЕНСКИЙ ГОЛОС';

  @override
  String get voiceSettingsMaleSection => 'МУЖСКОЙ ГОЛОС';

  @override
  String get voiceSettingsOtherSection => 'ДРУГИЕ ВАРИАНТЫ';

  @override
  String get voiceSettingsCouldNotClassify => 'Не удалось определить голос по имени — просто послушай и выбери.';

  @override
  String get voiceSettingsPreviewTooltip => 'Прослушать';

  @override
  String authNetworkError(String details) {
    return 'Не удалось связаться с сервером.\n$details';
  }

  @override
  String authUnexpectedResponse(int code) {
    return 'Сервер вернул неожиданный ответ (код $code).';
  }

  @override
  String authDeleteAccountFailed(int code) {
    return 'Не удалось удалить аккаунт (код $code).';
  }

  @override
  String authRequestFailed(int code) {
    return 'Не удалось отправить запрос (код $code).';
  }

  @override
  String authChangePasswordFailed(int code) {
    return 'Не удалось сменить пароль (код $code).';
  }

  @override
  String authResendCodeFailed(int code) {
    return 'Не удалось отправить код повторно (код $code).';
  }

  @override
  String get authGenericError => 'Ошибка авторизации.';

  @override
  String get operatorIssueWarningTitle => 'Выдать выговор';

  @override
  String get operatorWarningReasonHint => 'За что — эта причина сохранится в истории';

  @override
  String get operatorIssueButton => 'Выдать';

  @override
  String get operatorRevokeAccessTitle => 'Снять доступ к живой помощи?';

  @override
  String operatorRevokeAccessBody(String email) {
    return '$email больше не сможет принимать обращения. Аккаунт и история останутся.';
  }

  @override
  String get operatorRevokeAccessConfirm => 'Снять доступ';

  @override
  String get operatorDeleteAccountTitle => 'Удалить аккаунт целиком?';

  @override
  String operatorDeleteAccountBody(String email) {
    return 'Необратимо: $email и вся история обращений будут удалены. Если нужно просто убрать доступ, не удаляя аккаунт — используй \"Снять доступ\".';
  }

  @override
  String get operatorDeleteAccountConfirm => 'Удалить';

  @override
  String operatorWarningsSectionCount(int count) {
    return 'ВЫГОВОРЫ ($count)';
  }

  @override
  String operatorSessionsSectionCount(int count) {
    return 'ОБРАЩЕНИЯ ($count)';
  }

  @override
  String get operatorNoSessionsYet => 'Ещё не принимал обращений';

  @override
  String get operatorWarningButtonShort => 'Выговор';

  @override
  String get operatorRevokeAccessButtonShort => 'Снять доступ';

  @override
  String get operatorDeleteAccountTooltip => 'Удалить аккаунт целиком';

  @override
  String operatorIssuedByPrefix(String email) {
    return '· $email';
  }

  @override
  String get operatorUnknownUser => 'неизвестно';

  @override
  String get operatorNoRating => 'без оценки';

  @override
  String operatorQuotedComment(String comment) {
    return '«$comment»';
  }

  @override
  String get asrsQ1 => 'Как часто вам трудно завершить последние детали проекта, когда основная сложная часть уже сделана?';

  @override
  String get asrsQ2 => 'Как часто у вас возникают сложности с тем, чтобы навести порядок, когда задача требует организованности?';

  @override
  String get asrsQ3 => 'Как часто у вас возникают проблемы с тем, чтобы не забыть о встречах или обязательствах?';

  @override
  String get asrsQ4 => 'Когда задача требует много размышлений, как часто вы избегаете её или откладываете начало?';

  @override
  String get asrsQ5 => 'Как часто вы ёрзаете или суетитесь руками или ногами, когда приходится долго сидеть?';

  @override
  String get asrsQ6 => 'Как часто вы чувствуете себя чрезмерно активным(ой) и вынужденным(ой) что-то делать, будто вас подгоняет мотор?';

  @override
  String get asrsScaleNever => 'Никогда';

  @override
  String get asrsScaleRarely => 'Редко';

  @override
  String get asrsScaleSometimes => 'Иногда';

  @override
  String get asrsScaleOften => 'Часто';

  @override
  String get asrsScaleVeryOften => 'Очень часто';

  @override
  String get asrsIntroTitle => 'Скрининг симптомов СДВГ у взрослых';

  @override
  String get asrsIntroBody => 'Официальный опросник ВОЗ (Adult ADHD Self-Report Scale, короткая версия из 6 вопросов). 1-2 минуты. Это скрининг, не диагностика — положительный результат означает, что стоит обсудить это со специалистом, не то, что диагноз уже есть. Проходишь и видишь результат только ты — на сервер ничего не отправляется.';

  @override
  String get asrsInstructions => 'За последние 6 месяцев, как часто это происходило?';

  @override
  String get asrsShadedCountSuffix => 'из 6 в зоне значимости';

  @override
  String get asrsSuggestAssessment => 'Официальный порог методики (4 из 6) достигнут — она рекомендует обсудить это со специалистом. Это скрининг, не диагноз.';

  @override
  String get asrsNoAssessmentNeeded => 'Официальная методика не считает такой результат поводом для дополнительной оценки — но если что-то из этого тебя беспокоит, это можно обсудить со специалистом в любом случае.';

  @override
  String asrsDiscussPrompt(int shaded, String extra) {
    return 'Я прошёл(ла) скрининг ASRS-v1.1 (СДВГ): $shaded/6 в зоне значимости$extra. Можешь прокомментировать результат и поддержать меня?';
  }

  @override
  String get authBiometricNotConfigured => 'На этом устройстве не настроена биометрия (Face ID/отпечаток) — сначала включи её в настройках самого устройства.';

  @override
  String get authBiometricConfirmReason => 'Подтверди, чтобы включить вход по биометрии';

  @override
  String get authBiometricConfirmFailed => 'Не удалось подтвердить — попробуй ещё раз.';

  @override
  String authUnexpectedErrorGeneric(String error) {
    return 'Непредвиденная ошибка: $error';
  }

  @override
  String get authSessionNotFound => 'Сессия не найдена. Войди заново.';

  @override
  String get messageMenuEditRetry => 'Редактировать и переспросить';

  @override
  String get messageMenuCopyText => 'Скопировать текст';

  @override
  String get messageCopiedSnack => 'Скопировано';

  @override
  String get messageMenuReadAloud => 'Прочитать вслух';

  @override
  String get messageMenuReport => 'Пожаловаться на ответ';

  @override
  String get messageMenuDelete => 'Удалить сообщение';

  @override
  String get messageEditDialogTitle => 'Редактировать сообщение';

  @override
  String get messageEditDialogWarning => 'Ответ модели на это сообщение и всё, что было после, будет удалено — модель ответит заново на исправленный текст.';

  @override
  String get messageRetryButton => 'Переспросить';

  @override
  String get messageSourcesAdminOnly => 'ИСТОЧНИКИ (видно только админу)';

  @override
  String messageSourcePageSuffix(int page) {
    return ', стр. $page';
  }

  @override
  String messageSourceLine(String filename, String pageSuffix, int similarity) {
    return '$filename$pageSuffix · $similarity%';
  }

  @override
  String get messageChooseWhatYouLike => 'Выбери, что понравится:';

  @override
  String get messageNotNow => 'Не сейчас';

  @override
  String get messageYesLetsTest => 'Да, давай тест';

  @override
  String get messageNoLetsContinue => 'Нет, продолжим так';

  @override
  String get profilePasswordsDontMatch => 'Пароли не совпадают.';

  @override
  String profileCodeSentToEmail(String email) {
    return 'Код отправлен на $email. Введи его ниже, чтобы завершить смену.';
  }

  @override
  String get profileConfirmButton => 'Подтвердить';

  @override
  String get freewritingTitle => 'Фрирайтинг';

  @override
  String get freewritingIntro => 'Пиши непрерывно всё, что приходит в голову — без цензуры, без исправления ошибок, не останавливаясь. Это не для красивого текста, а чтобы разгрузить голову.';

  @override
  String get freewritingHowManyMinutes => 'Сколько минут?';

  @override
  String freewritingMinutesOption(int minutes) {
    return '$minutes мин';
  }

  @override
  String get freewritingStartButton => 'Начать писать';

  @override
  String get freewritingFinishButton => 'Закончить';

  @override
  String get freewritingHint => 'Пиши, не останавливаясь…';

  @override
  String get freewritingTimeUpBody => 'Время вышло. Можешь оставить текст на экране и перечитать, или сразу стереть — как удобнее.';

  @override
  String get freewritingEmptyPlaceholder => '(пусто)';

  @override
  String get freewritingEraseButton => 'Стереть';

  @override
  String get freewritingKeepAndCloseButton => 'Оставить и закрыть';

  @override
  String get groundingSightSense => 'Зрение';

  @override
  String get groundingSightPrompt => 'Назови 5 вещей, которые видишь вокруг себя';

  @override
  String get groundingTouchSense => 'Осязание';

  @override
  String get groundingTouchPrompt => 'Назови 4 вещи, которые можешь потрогать';

  @override
  String get groundingHearingSense => 'Слух';

  @override
  String get groundingHearingPrompt => 'Назови 3 звука, которые слышишь прямо сейчас';

  @override
  String get groundingSmellSense => 'Обоняние';

  @override
  String get groundingSmellPrompt => 'Назови 2 запаха, которые чувствуешь';

  @override
  String get groundingTasteSense => 'Вкус';

  @override
  String get groundingTastePrompt => 'Назови 1 вкус, который чувствуешь или помнишь';

  @override
  String get groundingTitle => 'Техника заземления';

  @override
  String get groundingListeningHint => 'Слушаю — переключусь сам, когда договоришь';

  @override
  String get groundingNextButton => 'Дальше';

  @override
  String get groundingDoneSubtitle => 'Можно повторить в любой момент.';

  @override
  String get groundingIfAnxietyPersists => 'Если тревога не отступает — это нормально, что одной техники может быть недостаточно. Можно поговорить с близким человеком или специалистом.';

  @override
  String get groundingStartOverButton => 'Начать заново';

  @override
  String get muscleHandsGroup => 'Кисти рук';

  @override
  String get muscleHandsTense => 'Сильно сожми кулаки';

  @override
  String get muscleHandsRelease => 'Резко расслабь и почувствуй тепло';

  @override
  String get muscleShouldersGroup => 'Плечи';

  @override
  String get muscleShouldersTense => 'Подними плечи к ушам как можно выше';

  @override
  String get muscleShouldersRelease => 'Отпусти, дай плечам упасть';

  @override
  String get muscleFaceGroup => 'Лицо';

  @override
  String get muscleFaceTense => 'Зажмурься и сожми челюсти';

  @override
  String get muscleFaceRelease => 'Расслабь лицо полностью';

  @override
  String get muscleAbsGroup => 'Пресс';

  @override
  String get muscleAbsTense => 'Напряги живот, будто готовишься к удару';

  @override
  String get muscleAbsRelease => 'Отпусти напряжение';

  @override
  String get muscleLegsGroup => 'Ноги';

  @override
  String get muscleLegsTense => 'Вытяни ноги и напряги стопы';

  @override
  String get muscleLegsRelease => 'Дай ногам расслабиться';

  @override
  String get muscleRelaxationTitle => 'Мышечная релаксация';

  @override
  String muscleRelaxationIntro(int count) {
    return 'По очереди напряжём и расслабим $count групп мышц. На каждую — несколько секунд напряжения, потом расслабление. Устройся поудобнее, чтобы двигать руками/ногами было ничем не стеснено.';
  }

  @override
  String get muscleStartButton => 'Начать';

  @override
  String muscleStepProgress(int current, int total) {
    return '$current из $total';
  }

  @override
  String get muscleDoneText => 'Готово — все группы мышц пройдены.';

  @override
  String get muscleRepeatButton => 'Пройти ещё раз';

  @override
  String chatServerNotResponding(String baseUrl) {
    return 'Сервер не отвечает. Проверь, что бэкенд запущен на $baseUrl';
  }

  @override
  String chatConnectionFailed(String baseUrl, String error) {
    return 'Не удалось подключиться к $baseUrl.\n$error';
  }

  @override
  String get chatSessionExpired => 'Сессия истекла. Выйди и войди заново.';

  @override
  String chatServerErrorCode(int code) {
    return 'Сервер вернул ошибку $code';
  }

  @override
  String chatConnectionDroppedMidResponse(String error) {
    return '\n\n⚠️ Соединение оборвалось во время ответа (например, отвалился туннель). Попробуй отправить сообщение ещё раз.\n$error';
  }

  @override
  String get chatResponseTruncated => '\n\n⚠️ Ответ обрезался — соединение закрылось раньше, чем модель закончила. Попробуй ещё раз.';

  @override
  String get chatDoctorSummaryPrompt => 'Кратко, в 2-3 предложениях, от третьего лица опиши врачу состояние человека на основе этого разговора — что беспокоит, как давно, что уже обсуждалось. Пиши для врача как для коллеги, не для самого человека, и не используй обращение \"ты\"/\"вы\".';

  @override
  String get memoryReleaseIntro => 'Напиши то, что тяжело держать в себе — тяжёлую мысль, обиду, воспоминание. Никто это не увидит и не сохранит — после того, как отпустишь, текст исчезнет насовсем, без возможности вернуть.';

  @override
  String get memoryReleaseHint => 'Пиши здесь…';

  @override
  String get memoryReleaseBurnMode => 'Сжечь';

  @override
  String get memoryReleaseShatterMode => 'Разбить';

  @override
  String get memoryReleaseBurnedResult => 'Сгорело — от текста ничего не осталось.';

  @override
  String get memoryReleaseShatteredResult => 'Разбилось вдребезги — текста больше нет.';

  @override
  String get memoryReleaseWriteMoreButton => 'Написать ещё';

  @override
  String get blogLoadFailed => 'Не удалось загрузить блог.';

  @override
  String get blogLoadPostFailed => 'Не удалось загрузить пост.';

  @override
  String get blogLoadListFailed => 'Не удалось загрузить список постов.';

  @override
  String get blogCreatePostFailed => 'Не удалось создать пост.';

  @override
  String get blogSavePostFailed => 'Не удалось сохранить пост.';

  @override
  String get blogDeletePostFailed => 'Не удалось удалить пост.';

  @override
  String get blogLikeFailed => 'Не удалось поставить лайк.';

  @override
  String get blogLoadCommentsFailed => 'Не удалось загрузить комментарии.';

  @override
  String get blogSendCommentFailed => 'Не удалось отправить комментарий.';

  @override
  String get blogDeleteCommentFailed => 'Не удалось удалить комментарий.';

  @override
  String get myHelpCallPersonTitle => 'Позвать человека на помощь';

  @override
  String get myHelpCallPersonDescription => 'Подключится врач или специалист из команды. Это не замена экстренной службе — если ситуация требует срочной медицинской помощи, звони в местную службу экстренной помощи или обратись в скорую напрямую.';

  @override
  String get myHelpDescribeHint => 'Коротко, что случилось (необязательно)';

  @override
  String get myHelpCallButton => 'Позвать на помощь';

  @override
  String get myHelpMyRequestsSection => 'МОИ ОБРАЩЕНИЯ';

  @override
  String get myHelpStatusPending => 'Ждём подключения';

  @override
  String get myHelpStatusActive => 'Подключено';

  @override
  String get myHelpStatusClosed => 'Закрыто';

  @override
  String get customTestDefaultTitle => 'Тест';

  @override
  String get customTestLoadFailed => 'Не удалось загрузить тест.';

  @override
  String customTestQuestionCount(int count) {
    return '$count вопрос(ов)';
  }

  @override
  String customTestQuestionProgress(int current, int total) {
    return 'Вопрос $current из $total';
  }

  @override
  String get customTestPointsLabel => 'баллов';

  @override
  String customTestDiscussPrompt(String title, int score, String resultNote) {
    return 'Я прошёл(ла) тест «$title»: $score балл(ов)$resultNote. Можешь прокомментировать результат и поддержать меня?';
  }

  @override
  String customTestResultNote(String label) {
    return ' — результат: «$label»';
  }

  @override
  String get reportSentTitle => 'Жалоба отправлена';

  @override
  String get reportSentBody => 'Спасибо — мы посмотрим этот ответ. Текст вопроса и ответа передан вместе с жалобой, чтобы можно было сразу разобраться, не переспрашивая.';

  @override
  String get reportDialogTitle => 'Пожаловаться на ответ';

  @override
  String get reportDialogBody => 'Вопрос и ответ, на который жалуешься, будут переданы вместе с жалобой — иначе не получится разобраться, что именно пошло не так.';

  @override
  String get reportReasonHint => 'Что не так с этим ответом? (необязательно)';

  @override
  String get helpCreateSessionFailed => 'Не удалось создать обращение.';

  @override
  String get helpLoadSessionsFailed => 'Не удалось загрузить обращения.';

  @override
  String get helpLoadMessagesFailed => 'Не удалось загрузить сообщения.';

  @override
  String get helpSendMessageFailed => 'Не удалось отправить сообщение.';

  @override
  String get helpCloseSessionFailed => 'Не удалось закрыть обращение.';

  @override
  String get helpSendRatingFailed => 'Не удалось отправить оценку.';

  @override
  String get helpLoadRequestsFailed => 'Не удалось загрузить заявки.';

  @override
  String get helpLoadActiveSessionsFailed => 'Не удалось загрузить активные обращения.';

  @override
  String get helpRequestAlreadyTaken => 'Эту заявку уже забрал другой оператор.';

  @override
  String get helpAcceptRequestFailed => 'Не удалось принять заявку.';

  @override
  String get breathingInhale => 'Вдох';

  @override
  String get breathingHold => 'Задержка';

  @override
  String get breathingExhale => 'Выдох';

  @override
  String get breathingTitle => 'Дыхательное упражнение';

  @override
  String get breathingReadyToStart => 'Готов(а) начать?';

  @override
  String get breathingStopButton => 'Остановить';

  @override
  String get breathingDisclaimer => 'Простая техника саморегуляции дыхания — не заменяет профессиональную помощь. Если чувствуешь головокружение — останови упражнение и дыши в привычном темпе.';

  @override
  String get themeVariantViolet => 'Фиолетовый';

  @override
  String get themeVariantOcean => 'Океан';

  @override
  String get themeVariantMidnight => 'Полночь';

  @override
  String get themeVariantSunset => 'Закат';

  @override
  String get themeVariantForest => 'Лес';

  @override
  String get themeVariantRose => 'Розовый';

  @override
  String get themeVariantAmber => 'Янтарь';

  @override
  String get themeVariantSlate => 'Графит';

  @override
  String get themeVariantMint => 'Мята';

  @override
  String get customTestsLoadListFailed => 'Не удалось загрузить список тестов.';

  @override
  String get customTestsLoadTestFailed => 'Не удалось загрузить тест.';

  @override
  String get customTestsSubmitAnswersFailed => 'Не удалось отправить ответы.';

  @override
  String get customTestsLoadHistoryFailed => 'Не удалось загрузить историю тестов.';

  @override
  String get customTestsCreateFailed => 'Не удалось создать тест.';

  @override
  String get customTestsSaveFailed => 'Не удалось сохранить тест.';

  @override
  String get customTestsDeleteFailed => 'Не удалось удалить тест.';

  @override
  String get safeContainmentIntro => 'Если мысль или чувство слишком сильные, но сейчас не время с ними разбираться — напиши и убери в сейф. Не пропадёт навсегда, просто подождёт, пока будет время вернуться.';

  @override
  String get safeContainmentHint => 'Что нужно убрать на потом?';

  @override
  String get safeContainmentPutAwayButton => 'Убрать в сейф';

  @override
  String get safeContainmentDoneBody => 'Надёжно спрятано. Оно больше не будет отвлекать прямо сейчас — вернёмся к этому, когда будешь готов(а).';

  @override
  String get voicePreviewPhrase => 'Привет! Так звучит этот голос.';

  @override
  String appSettingsChangeFailed(int code) {
    return 'Не удалось изменить настройку (код $code).';
  }

  @override
  String appSettingsRestoreFailed(int code) {
    return 'Не удалось восстановить настройки (код $code).';
  }

  @override
  String appSettingsLoadPersonaFailed(int code) {
    return 'Не удалось загрузить настройки личности ИИ (код $code).';
  }

  @override
  String appSettingsSavePersonaFailed(int code) {
    return 'Не удалось сохранить личность ИИ (код $code).';
  }

  @override
  String appSettingsResetPersonaFailed(int code) {
    return 'Не удалось сбросить личность ИИ (код $code).';
  }

  @override
  String appSettingsLoadModelFailed(int code) {
    return 'Не удалось загрузить настройки модели (код $code).';
  }

  @override
  String appSettingsSaveModelFailed(int code) {
    return 'Не удалось сохранить настройки модели (код $code).';
  }

  @override
  String appSettingsResetModelFailed(int code) {
    return 'Не удалось сбросить настройки модели (код $code).';
  }

  @override
  String get reminderPrompt1 => 'Как прошёл день? Если хочется поговорить — я здесь.';

  @override
  String get reminderPrompt2 => 'Небольшая пауза — как ты сейчас, в целом?';

  @override
  String get reminderPrompt3 => 'Если накопилось что-то, о чём хочется рассказать — самое время.';

  @override
  String get reminderPrompt4 => 'Как настроение сегодня? Загляни, если нужно выговориться.';

  @override
  String get reminderPrompt5 => 'Просто напоминаю, что можно зайти и поделиться, как прошёл день.';

  @override
  String get reminderChannelName => 'Ежедневные напоминания';

  @override
  String get reminderChannelDescription => 'Напоминание проверить, как дела, в выбранное время';

  @override
  String get supportTitle => 'Поддержка';

  @override
  String get supportMyTicketsSection => 'ТВОИ ОБРАЩЕНИЯ';

  @override
  String get supportNoTicketsYet => 'Обращений пока нет';

  @override
  String get supportDescribeProblem => 'Опиши проблему — мы посмотрим и ответим';

  @override
  String get supportHint => 'Например: не приходит ответ от модели на длинные вопросы…';

  @override
  String get supportSending => 'Отправляю…';

  @override
  String get supportTicketOpen => 'Открыто';

  @override
  String get myReportsTitle => 'Мои жалобы';

  @override
  String get myReportsNoneYet => 'Жалоб пока нет';

  @override
  String get myReportsResolved => 'Разобрано';

  @override
  String get myReportsUnderReview => 'На рассмотрении';

  @override
  String get myReportsYourQuestion => 'Твой вопрос';

  @override
  String get myReportsAiResponseLabel => 'Ответ ИИ, на который пожаловался(-ась)';

  @override
  String get myReportsReasonLabel => 'Причина жалобы';

  @override
  String get myReportsTeamResponseSection => 'ОТВЕТ ОТ КОМАНДЫ';

  @override
  String get leavesOnStreamTitle => 'Листья на ручье';

  @override
  String get leavesOnStreamIntro => 'Напиши мысль, от которой хочешь отпустить себя. Она уплывёт по ручью и растворится — никуда не сохраняется.';

  @override
  String get leavesOnStreamHint => 'Например: я боюсь, что не справлюсь...';

  @override
  String get leavesOnStreamDoneText => 'Мысль уплыла.';

  @override
  String get bilateralTitle => 'Билатеральная стимуляция';

  @override
  String get bilateralIntro => 'Следи за шаром только глазами, не поворачивая голову. Это помогает снизить остроту тревоги. Не заменяет работу со специалистом, если тревога сильная или частая.';

  @override
  String get operatorDashboardTitle => 'Кабинет оператора';

  @override
  String operatorDashboardMyActiveSection(int count) {
    return 'МОИ АКТИВНЫЕ ($count)';
  }

  @override
  String operatorDashboardPendingSection(int count) {
    return 'ОЖИДАЮТ ПОДКЛЮЧЕНИЯ ($count)';
  }

  @override
  String get operatorDashboardNoOneWaiting => 'Пока никто не ждёт подключения';

  @override
  String get operatorDashboardNoDescription => 'Без описания';

  @override
  String get operatorDashboardAcceptButton => 'Принять';

  @override
  String get gratitudeTitle => 'Дневник благодарности';

  @override
  String get gratitudePrompt => 'Три вещи, за которые ты сегодня благодарен(на)';

  @override
  String get gratitudeHint => 'Не обязательно что-то большое — подойдёт и мелочь.';

  @override
  String get gratitudeEntriesSection => 'ЗАПИСИ';

  @override
  String gratitudeBulletItem(String item) {
    return '· $item';
  }

  @override
  String get wellbeingCalendarWho5Label => 'ВОЗ-5';

  @override
  String wellbeingCalendarScoreSuffix(int score) {
    return '$score балл(ов)';
  }

  @override
  String get wellbeingCalendarTitle => 'Календарь самочувствия';

  @override
  String get wellbeingCalendarTakeTestButton => 'Пройти тест';

  @override
  String get wellbeingCalendarEmptyState => 'Пока нет пройденных опросников — они появятся здесь\nпосле прохождения в разделе «Самочувствие».';

  @override
  String get weekdayMon => 'Пн';

  @override
  String get weekdayTue => 'Вт';

  @override
  String get weekdayWed => 'Ср';

  @override
  String get weekdayThu => 'Чт';

  @override
  String get weekdayFri => 'Пт';

  @override
  String get weekdaySat => 'Сб';

  @override
  String get weekdaySun => 'Вс';

  @override
  String get chatQuestionNotFound => '(вопрос не найден)';

  @override
  String get chatTestDeclinedContinuation => 'Пользователь нажал \"Нет, не сейчас\" на предложение теста. Просто продолжи разговор дальше, естественно, не упоминая явно сам отказ и не извиняясь за предложение.';

  @override
  String cloudVoiceLabelFemale(String name) {
    return '$name (женский)';
  }

  @override
  String cloudVoiceLabelMale(String name) {
    return '$name (мужской)';
  }

  @override
  String get modelDowngradedNotice => 'Закончились токены на продвинутую версию ИИ в этом месяце — этот ответ от обычной модели. Оформи подписку выше, чтобы получить больше.';

  @override
  String get modelDowngradedUpgradeButton => 'Повысить тариф';

  @override
  String get settingsLanguageLabel => 'Язык';

  @override
  String get settingsLanguageSystem => 'Системный';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get sleepMusicTabCatalog => 'Каталог';

  @override
  String get sleepMusicTabPlaylists => 'Мои плейлисты';

  @override
  String get sleepMusicNoPlaylists => 'Плейлистов пока нет — создай первый.';

  @override
  String get sleepMusicCreatePlaylist => 'Создать плейлист';

  @override
  String get sleepMusicNewPlaylistHint => 'Название плейлиста';

  @override
  String get sleepMusicEmptyPlaylist => 'В этом плейлисте пока нет треков.';

  @override
  String get sleepMusicAddTrack => 'Добавить трек';

  @override
  String get sleepMusicAddFromCatalog => 'Из каталога';

  @override
  String get sleepMusicUploadOwnFile => 'Загрузить свой файл';

  @override
  String get sleepMusicRemoveFromPlaylist => 'Убрать из плейлиста';

  @override
  String get sleepMusicDeletePlaylist => 'Удалить плейлист';

  @override
  String sleepMusicDeletePlaylistConfirm(String name) {
    return 'Удалить плейлист «$name»? Сами треки останутся в каталоге/личной библиотеке.';
  }

  @override
  String get sleepMusicOwnFileWebNotice => 'На вебе свой файл проиграется только до перезагрузки страницы — сохранить насовсем здесь нельзя.';

  @override
  String get sleepMusicFileReadError => 'Не удалось прочитать файл.';

  @override
  String get sleepMusicNoTracksInCatalogYet => 'В каталоге пока нет звуков — сначала их должен добавить админ.';

  @override
  String get sleepMusicTimerCancel => 'Отключить таймер';

  @override
  String sleepMusicTimerMinutes(int minutes) {
    return '$minutes минут';
  }

  @override
  String get sleepMusicRenamePlaylist => 'Переименовать плейлист';

  @override
  String get sleepMusicLikedTitle => 'Избранное';

  @override
  String get sleepMusicNoLikedYet => 'Пока нет лайкнутых треков — нажми на сердечко у любого трека.';
}
