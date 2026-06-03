// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'ZhamSpace';

  @override
  String get home => 'Главная';

  @override
  String get explore => 'Обзор';

  @override
  String get favorites => 'Избранное';

  @override
  String get reservations => 'Мои брони';

  @override
  String get profile => 'Профиль';

  @override
  String get sessions => 'Сессии';

  @override
  String get chats => 'Чаты';

  @override
  String get facilitiesTab => 'Площадки';

  @override
  String get bookingsTab => 'Брони';

  @override
  String get searchFacilities => 'Поиск спортзалов, парков, клубов';

  @override
  String get allCategories => 'Все категории';

  @override
  String get football => 'Футбол';

  @override
  String get basketball => 'Баскетбол';

  @override
  String get tennis => 'Теннис';

  @override
  String get swimming => 'Бассейн';

  @override
  String get gym => 'Тренажерный зал';

  @override
  String get volleyball => 'Волейбол';

  @override
  String get badminton => 'Бадминтон';

  @override
  String get tabletennis => 'Настольный теннис';

  @override
  String get ice_hockey => 'Хоккей';

  @override
  String get judo => 'Дзюдо';

  @override
  String get chess => 'Шахматы';

  @override
  String get boxing => 'Бокс';

  @override
  String get mma => 'ММА';

  @override
  String get athletics => 'Лёгкая атлетика';

  @override
  String get handball => 'Гандбол';

  @override
  String get futsal => 'Футзал';

  @override
  String get golf => 'Гольф';

  @override
  String get climbing => 'Скалолазание';

  @override
  String get yoga => 'Йога';

  @override
  String get pilates => 'Пилатес';

  @override
  String get crossfit => 'Кроссфит';

  @override
  String get cycling => 'Велоспорт';

  @override
  String get running => 'Бег';

  @override
  String get esports => 'Киберспорт';

  @override
  String get other => 'Другое';

  @override
  String get popularVenues => 'Популярные площадки';

  @override
  String get nearYou => 'Рядом с вами';

  @override
  String get topRated => 'Лучшие';

  @override
  String get seeAll => 'Показать все';

  @override
  String get perHour => 'в час';

  @override
  String get rating => 'Рейтинг';

  @override
  String reviews(int count) {
    return '$count отзывов';
  }

  @override
  String get bookNow => 'Забронировать';

  @override
  String get viewDetails => 'Подробнее';

  @override
  String get openNow => 'Открыто';

  @override
  String get closed => 'Закрыто';

  @override
  String get availableToday => 'Доступно сегодня';

  @override
  String fromPrice(String price) {
    return 'От $price₸';
  }

  @override
  String kmAway(String km) {
    return '$km км';
  }

  @override
  String get about => 'Описание';

  @override
  String get venueDescriptionTab => 'Описание';

  @override
  String get venueContactInfoTab => 'Контакты';

  @override
  String get venueNoContacts => 'Нет контактных данных';

  @override
  String get facilities => 'Удобства';

  @override
  String get availability => 'Доступность';

  @override
  String get location => 'Местоположение';

  @override
  String get reviewsTitle => 'Отзывы';

  @override
  String get selectDate => 'Выберите дату';

  @override
  String get selectTime => 'Выберите время';

  @override
  String get duration => 'Длительность';

  @override
  String get hours => 'часов';

  @override
  String get hour => 'час';

  @override
  String get available => 'Доступно';

  @override
  String get booked => 'Забронировано';

  @override
  String get unavailable => 'Недоступно';

  @override
  String get facilityUnavailableNoSchedule => 'Нет графика работы';

  @override
  String get facilityUnavailableHint => 'Эту площадку нельзя забронировать.';

  @override
  String get selectStartTimeLabel => 'Начало';

  @override
  String get selectEndTimeLabel => 'Окончание';

  @override
  String get loginToBookDescription => 'Войдите, чтобы забронировать площадку.';

  @override
  String get noSlotsThisDay => 'На эту дату нет доступных интервалов.';

  @override
  String get bookingTotalLabel => 'Итого';

  @override
  String get payNowLabel => 'К оплате';

  @override
  String get unableToLoadFacilities => 'Не удалось загрузить площадки';

  @override
  String get noFacilitiesListed => 'Площадки не найдены';

  @override
  String facilityMetaSportType(String sport, String type) {
    return '$sport · $type';
  }

  @override
  String get bookingDetails => 'Детали бронирования';

  @override
  String get bookingNotFound => 'Бронирование не найдено';

  @override
  String get facility => 'Площадка';

  @override
  String get date => 'Дата';

  @override
  String get time => 'Время';

  @override
  String get totalPrice => 'Общая стоимость';

  @override
  String get proceedToPayment => 'Перейти к оплате';

  @override
  String get payment => 'Оплата';

  @override
  String get paymentMethod => 'Способ оплаты';

  @override
  String get creditCard => 'Кредитная карта';

  @override
  String get debitCard => 'Карта';

  @override
  String get cash => 'Наличными при посещении';

  @override
  String get cardNumber => 'Номер карты';

  @override
  String get expiryDate => 'Срок действия';

  @override
  String get cvv => 'CVV';

  @override
  String get confirmPayment => 'Подтвердить оплату';

  @override
  String get processingPayment => 'Обработка платежа...';

  @override
  String get processingPaymentHint =>
      'Пожалуйста, подождите, пока мы подтверждаем оплату.';

  @override
  String get paymentFailedTitle => 'Оплата не прошла';

  @override
  String get paymentFailedMessage =>
      'Не удалось завершить оплату. Подробности — в разделе «Мои бронирования».';

  @override
  String get applePay => 'Apple Pay';

  @override
  String get googlePay => 'Google Pay';

  @override
  String get kaspi => 'Kaspi';

  @override
  String get halyk => 'Halyk Bank';

  @override
  String get savedCards => 'Сохранённые карты';

  @override
  String get addNewCard => 'Добавить карту';

  @override
  String get otherBankCards => 'Банковская карта';

  @override
  String get selectCard => 'Выберите карту';

  @override
  String get bookingConfirmed => 'Бронирование подтверждено!';

  @override
  String get bookingSuccess =>
      'Ваше бронирование подтверждено. Проверьте email для деталей.';

  @override
  String get viewBooking => 'Просмотр брони';

  @override
  String get backToHome => 'На главную';

  @override
  String get upcomingBookings => 'Предстоящие';

  @override
  String get pastBookings => 'Прошедшие';

  @override
  String get noBookings => 'Нет бронирований';

  @override
  String get startBooking =>
      'Начните изучать и забронируйте вашу первую площадку!';

  @override
  String get cancelBooking => 'Отменить бронирование';

  @override
  String get confirmCancel =>
      'Вы уверены, что хотите отменить это бронирование?';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get bookingCancelled => 'Бронирование успешно отменено';

  @override
  String get myProfile => 'Мой профиль';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get lightMode => 'Светлая тема';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get systemDefault => 'Системная';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get kazakh => 'Қазақша';

  @override
  String get myFavorites => 'Мое избранное';

  @override
  String get noFavorites => 'Нет избранного';

  @override
  String get addFavorites =>
      'Добавьте площадки в избранное, чтобы увидеть их здесь';

  @override
  String get myBookings => 'Мои бронирования';

  @override
  String get personalInfo => 'Личная информация';

  @override
  String get fullName => 'Полное имя';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Номер телефона';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get logout => 'Выйти';

  @override
  String get confirmLogout => 'Вы уверены, что хотите выйти?';

  @override
  String get login => 'Вход';

  @override
  String get register => 'Регистрация';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get signIn => 'Войти';

  @override
  String get authRequiredHint =>
      'Войдите или зарегистрируйтесь, чтобы получить доступ.';

  @override
  String get authErrorTryAgain => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationsEnabled => 'Push-уведомления';

  @override
  String get emailNotifications => 'Email уведомления';

  @override
  String get helpSupport => 'Помощь и поддержка';

  @override
  String get termsConditions => 'Условия использования';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get aboutUs => 'О нас';

  @override
  String get version => 'Версия';

  @override
  String get filterByPrice => 'Фильтр по цене';

  @override
  String get priceRange => 'Диапазон цен';

  @override
  String get applyFilters => 'Применить фильтры';

  @override
  String get clearFilters => 'Очистить фильтры';

  @override
  String get sortBy => 'Сортировать';

  @override
  String get priceLowest => 'Цена: по возрастанию';

  @override
  String get priceHighest => 'Цена: по убыванию';

  @override
  String get ratingHighest => 'Высокий рейтинг';

  @override
  String get nearest => 'Ближайшие ко мне';

  @override
  String get openingHours => 'Часы работы';

  @override
  String get amenities => 'Удобства';

  @override
  String get parking => 'Парковка';

  @override
  String get changingRooms => 'Раздевалки';

  @override
  String get showers => 'Душевые';

  @override
  String get equipment => 'Аренда оборудования';

  @override
  String get wifi => 'Бесплатный WiFi';

  @override
  String get cafeteria => 'Кафе';

  @override
  String get getDirections => 'Построить маршрут';

  @override
  String get call => 'Позвонить';

  @override
  String get share => 'Поделиться';

  @override
  String get now => 'Сейчас';

  @override
  String get today => 'Сегодня';

  @override
  String get pickDate => 'Дата';

  @override
  String get filters => 'Фильтры';

  @override
  String get level => 'Уровень';

  @override
  String get allLevels => 'Все уровни';

  @override
  String get beginner => 'Начинающий';

  @override
  String get intermediate => 'Средний';

  @override
  String get advanced => 'Продвинутый';

  @override
  String spotsLeft(int count) {
    return '$count мест осталось';
  }

  @override
  String playersJoined(int count) {
    return '$count игроков присоединились';
  }

  @override
  String get joinSession => 'Присоединиться';

  @override
  String get sessionDetails => 'Детали сессии';

  @override
  String get host => 'Организатор';

  @override
  String get participants => 'Участники';

  @override
  String get skillLevel => 'Уровень навыков';

  @override
  String get pricePerPerson => 'Цена за человека';

  @override
  String get spotsAvailable => 'Свободных мест';

  @override
  String get joinedSuccessfully => 'Вы присоединились к сессии!';

  @override
  String get joinedLabel => 'Участвую';

  @override
  String get sessionFull => 'Мест нет';

  @override
  String get sessionLocked => 'Регистрация закрыта';

  @override
  String get joinLoginRequired => 'Войдите, чтобы присоединиться к сессии';

  @override
  String get leftSessionSuccessfully => 'Вы покинули сессию';

  @override
  String get leaveSessionConfirm => 'Вы уверены, что хотите покинуть сессию?';

  @override
  String get leaveSession => 'Покинуть сессию';

  @override
  String get noSessions => 'Нет доступных сессий';

  @override
  String get findSessions => 'Загляните позже для открытых сессий рядом';

  @override
  String get live => 'LIVE';

  @override
  String playersCount(int current, int max) {
    return '$current/$max';
  }

  @override
  String get allChats => 'Все';

  @override
  String get venueChats => 'Залы';

  @override
  String get sessionGroups => 'Сессии';

  @override
  String get direct => 'Личные';

  @override
  String get typeMessage => 'Введите сообщение...';

  @override
  String get noChats => 'Нет разговоров';

  @override
  String get startChatting =>
      'Когда вы напишете владельцу площадки, переписка появится здесь.';

  @override
  String get messageOwner => 'Написать владельцу';

  @override
  String get chatEmptyThread => 'Пока нет сообщений';

  @override
  String get searchChats => 'Поиск разговоров...';

  @override
  String get online => 'В сети';

  @override
  String membersCount(int count) {
    return '$count участников';
  }

  @override
  String get justNow => 'Только что';

  @override
  String minutesAgo(int count) {
    return '$count мин. назад';
  }

  @override
  String get reserveOrBook => 'Бронировать';

  @override
  String get newFacilities => 'Новые площадки';

  @override
  String get news => 'Новости';

  @override
  String get promo => 'Акции';

  @override
  String get placeYourFacility => 'Разместить площадку';

  @override
  String get guide => 'Гид';

  @override
  String get price => 'Цена';

  @override
  String get distance => 'Расстояние';

  @override
  String get book => 'Бронировать';

  @override
  String get confirmed => 'Подтверждено';

  @override
  String get completed => 'Завершено';

  @override
  String get cancelled => 'Отменено';

  @override
  String get manageTab => 'Управление';

  @override
  String get dashboardTab => 'Панель';

  @override
  String get analyticsTab => 'Доход';

  @override
  String get ownerHubTitle => 'Кабинет владельца';

  @override
  String get ownerHubSubtitle =>
      'Управляйте площадками, бронированиями и ростом';

  @override
  String get ownerFacilityHint =>
      'Держите расписание актуальным и шаблоны сессий заполненными, чтобы повышать загрузку.';

  @override
  String get addEditFacility => 'Добавить / Редактировать площадку';

  @override
  String get availabilitySchedule => 'Доступность и расписание';

  @override
  String get sessionTemplates => 'Шаблоны сессий';

  @override
  String get myFacilities => 'Мои площадки';

  @override
  String get statusActive => 'Активна';

  @override
  String get statusDraft => 'Черновик';

  @override
  String get statusSuspended => 'Приостановлена';

  @override
  String get profileCompletion => 'Заполнение профиля';

  @override
  String get occupancyRate => 'Уровень загрузки';

  @override
  String get bookingsDashboard => 'Панель бронирований';

  @override
  String get incomingRequests => 'Входящие';

  @override
  String get upcomingSessionsTitle => 'Предстоящие';

  @override
  String get pastSessionsTitle => 'Прошедшие';

  @override
  String get cancellationsTitle => 'Отмены';

  @override
  String get revenueAnalytics => 'Доход и аналитика';

  @override
  String get daily => 'За день';

  @override
  String get weekly => 'За неделю';

  @override
  String get monthly => 'За месяц';

  @override
  String get payouts => 'Выплаты';

  @override
  String get occupancyByFacility => 'Загрузка по площадкам';

  @override
  String get popularSlotsHeatmap => 'Тепловая карта популярных слотов';

  @override
  String get bookingChats => 'Клиенты';

  @override
  String get ownerPublicProfile => 'Публичный профиль владельца';

  @override
  String get hostReviews => 'Отзывы как хост';

  @override
  String get responseRate => 'Скорость ответа';

  @override
  String get memberSince => 'С нами с';

  @override
  String get roleTestSwitch => 'Тестовое переключение роли';

  @override
  String get roleCustomer => 'Пользователь';

  @override
  String get roleFacilityOwner => 'Владелец площадки';

  @override
  String get switchToOwnerPrompt =>
      'Переключиться в режим владельца площадки и открыть owner-интерфейс?';

  @override
  String get switchToCustomerPrompt =>
      'Вернуться в режим пользователя и восстановить интерфейс маркетплейса?';

  @override
  String get retry => 'Повторить';

  @override
  String get reservationsAuthDescription =>
      'Войдите или зарегистрируйтесь, чтобы управлять бронированиями.';

  @override
  String get bookingFallbackTitle => 'Бронирование';

  @override
  String venueIdFallback(String venueId) {
    return 'Площадка $venueId';
  }

  @override
  String get resourcePickerFallback => 'Объект';

  @override
  String get addressLabel => 'Адрес';

  @override
  String get bookingContactInfoTitle => 'Контакты';

  @override
  String get bookingContactInfoSubtitle => 'Телефон, email и сайт';

  @override
  String get contactsSectionTitle => 'Контакты';

  @override
  String get paymentRowLabel => 'Оплата';

  @override
  String get holdExpiresLabel => 'Бронь истекает';

  @override
  String get sessionSectionTitle => 'Сессия';

  @override
  String get sessionIdLabel => 'ID сессии';

  @override
  String get cancellationReasonLabel => 'Причина отмены';

  @override
  String bookingIdLine(String id) {
    return 'ID бронирования · $id';
  }

  @override
  String get contactTypePhoneDefault => 'Телефон';

  @override
  String get contactTypeEmailDefault => 'Email';

  @override
  String get contactTypeWebsiteDefault => 'Сайт';

  @override
  String get notLoggedInError => 'Не выполнен вход';

  @override
  String bookingFailedMessage(String error) {
    return 'Ошибка бронирования: $error';
  }

  @override
  String get bankCardBrandLabel => 'Банк / платёжная система';

  @override
  String get bankCardBrandHint => 'Visa, Mastercard…';

  @override
  String get paymentMyCards => 'Мои карты';

  @override
  String get paymentNoSavedCards => 'Нет сохранённых карт';

  @override
  String get paymentPayButton => 'Оплатить';

  @override
  String get bookingStatusCreated => 'Ожидает оплаты';

  @override
  String get bookingStatusPending => 'Ожидает';

  @override
  String get bookingStatusHold => 'Удержание';

  @override
  String get bookingStatusActive => 'Активно';

  @override
  String get cancelReasonPaymentTimeout => 'Оплата не была завершена вовремя';

  @override
  String get cancelReasonUserCancelled => 'Отменено вами';

  @override
  String get cancelReasonHoldExpired => 'Время бронирования истекло';

  @override
  String get cancelReasonAdminCancelled => 'Отменено площадкой';

  @override
  String get cancelReasonRefunded => 'Отменено из-за возврата';

  @override
  String get cancelReasonMinimumNotMet => 'Недостаточно участников';

  @override
  String get cancelReasonOwnerCancelled => 'Отменено организатором сессии';

  @override
  String get cancelReasonSessionExpired => 'Сессия завершилась без начала';

  @override
  String get cancelReasonHoldCreationFailed =>
      'Не удалось зарезервировать время';

  @override
  String get paymentStatusPaid => 'Оплачено';

  @override
  String get paymentStatusPending => 'Ожидает';

  @override
  String get paymentStatusHold => 'Удержание';

  @override
  String get paymentStatusFailed => 'Ошибка';

  @override
  String get paymentStatusRefunded => 'Возврат';

  @override
  String get savedCardLocalOnlyNotice =>
      'Сохранённые карты хранятся только на этом устройстве для mock-оплаты. Банковский токен не отправляется.';

  @override
  String get cardNumberInvalid => 'Введите корректный номер карты.';

  @override
  String get cardExpiryInvalid => 'Введите будущий срок действия.';

  @override
  String get cardCvvInvalid => 'Введите корректный CVV.';

  @override
  String get cardDetailsInvalid => 'Проверьте данные карты и попробуйте снова.';

  @override
  String get slotJustBecameUnavailable =>
      'Этот слот только что стал недоступен. Выберите другое время.';

  @override
  String holdCountdown(String timeLeft) {
    return 'Истекает через $timeLeft';
  }

  @override
  String get holdExpiredNow => 'Бронь истекла';

  @override
  String get confirmCancelPaidRefund =>
      'Это бронирование оплачено. При отмене будет запрошен mock-возврат, затем бронирование отменится. Продолжить?';

  @override
  String get bookingCancelledRefundRequested =>
      'Бронирование отменено, возврат запрошен';

  @override
  String bookingCancelFailed(String error) {
    return 'Не удалось отменить бронирование: $error';
  }

  @override
  String priceRangePerPerson(int min, int max) {
    return '$min–$max ₸ / чел.';
  }

  @override
  String priceQuotePerPerson(int amount) {
    return '$amount ₸ / чел. ориентир';
  }

  @override
  String stablePricePerPerson(int amount) {
    return '$amount ₸ / чел.';
  }

  @override
  String get finalPriceLocksShort => 'фиксируется позже';

  @override
  String get fixedSplitPriceDisclosure =>
      'Для fixed-split финальная цена на человека зависит от участников и фиксируется при заполнении сессии или в момент блокировки.';

  @override
  String get promoSectionTitle => 'Доступные акции';

  @override
  String get promoEnterCode => 'Есть промокод?';

  @override
  String get promoCodeHint => 'Введите код';

  @override
  String get promoApply => 'Применить';

  @override
  String get promoRemove => 'Убрать акцию';

  @override
  String get promoCodeInvalid => 'Неверный промокод';

  @override
  String get promoConditionsNotMet =>
      'Бронирование не соответствует условиям акции';

  @override
  String get promoVenuesTitle => 'Площадки с акциями';

  @override
  String get promoVenuesBannerTitle => 'Специальные предложения';

  @override
  String get promoVenuesBannerSubtitle =>
      'Площадки с активными скидками и акциями';

  @override
  String get promoVenuesEmpty => 'Нет активных акций';

  @override
  String get promoVenuesEmptySubtitle =>
      'Сейчас нет площадок с активными акциями. Загляните позже!';

  @override
  String get subtotal => 'Подытог';

  @override
  String get placeFacilityTitle => 'Разместить площадку';

  @override
  String get placeFacilitySubtitle =>
      'Разместите свою спортивную площадку на ZhamSpace и привлекайте тысячи активных игроков в вашем городе.';

  @override
  String get facilityNameLabel => 'Название площадки';

  @override
  String get placeFacilityFullNameHint => 'Введите ваше полное имя';

  @override
  String get placeFacilityPhoneHint => '+7 (700) 000-00-00';

  @override
  String get placeFacilityNameHint => 'например, Arena Sport Club';

  @override
  String get placeFacilityContactButton => 'Связаться с нами';

  @override
  String get placeFacilitySuccessTitle => 'Заявка отправлена!';

  @override
  String get placeFacilitySuccessMessage =>
      'Спасибо! Мы свяжемся с вами в ближайшее время для обсуждения размещения вашей площадки.';

  @override
  String get placeFacilityFullNameRequired => 'Введите ваше полное имя';

  @override
  String get placeFacilityPhoneRequired => 'Введите номер телефона';

  @override
  String get placeFacilityPhoneInvalid => 'Введите корректный номер телефона';

  @override
  String get placeFacilityNameRequired => 'Введите название площадки';

  @override
  String get placeFacilityCommentLabel => 'Комментарий';

  @override
  String get placeFacilityCommentHint =>
      'Добавьте детали о площадке, адресе или удобном времени связи';

  @override
  String get placeFacilityDocumentLabel => 'Документ';

  @override
  String get placeFacilityDocumentHint => 'Прикрепите PDF или изображение';

  @override
  String get placeFacilityDocumentAction => 'Выбрать';

  @override
  String get placeFacilityDocumentRequired => 'Прикрепите PDF или изображение';

  @override
  String get placeFacilitySubmitError =>
      'Не удалось отправить заявку. Попробуйте еще раз.';

  @override
  String get placeFacilityMyRequestsTitle => 'Мои заявки';

  @override
  String get placeFacilityMyRequestsEmpty => 'Заявок пока нет';

  @override
  String get placeFacilityLoadRequestsError =>
      'Не удалось загрузить ваши заявки.';

  @override
  String get placeFacilitySentAt => 'Отправлена';

  @override
  String get placeFacilityUpdatedAt => 'Обновлена';

  @override
  String get venueRequestStatusCreated => 'Создана';

  @override
  String get venueRequestStatusAwaiting => 'Ожидает';

  @override
  String get venueRequestStatusReviewing => 'На рассмотрении';

  @override
  String get venueRequestStatusApproved => 'Одобрена';

  @override
  String get venueRequestStatusCancelled => 'Отклонена';

  @override
  String get venueRequestStatusApprovedMessage =>
      'Ваша заявка одобрена. В ближайшее время ваша площадка будет размещена.';

  @override
  String get venueRequestStatusCreatedMessage =>
      'Площадка по этой заявке успешно создана. Управляйте объектами в платформе владельца.';

  @override
  String get venueRequestStatusRejectedMessage =>
      'Ваша заявка отклонена. Свяжитесь со службой поддержки для получения дополнительной информации.';

  @override
  String get guideTitle => 'Гид';

  @override
  String get guideBannerTitle => 'Как работает ZhamSpace';

  @override
  String get guideBannerSubtitle =>
      'Всё, что нужно для поиска, бронирования и игры';

  @override
  String get guideSectionGettingStarted => 'Начало работы';

  @override
  String get guideSectionGettingStartedSubtitle =>
      'Просматривайте площадки и находите спорт рядом с вами';

  @override
  String get guideSectionBooking => 'Бронирование';

  @override
  String get guideSectionBookingSubtitle =>
      'Выберите дату, время и подтвердите бронь';

  @override
  String get guideSectionSessions => 'Сессии';

  @override
  String get guideSectionSessionsSubtitle =>
      'Находите открытые игры и присоединяйтесь к игрокам';

  @override
  String get guideSectionPayments => 'Оплата и брони';

  @override
  String get guideSectionPaymentsSubtitle =>
      'Оплачивайте безопасно и управляйте бронированиями';

  @override
  String get guideSectionProfile => 'Профиль и избранное';

  @override
  String get guideSectionProfileSubtitle =>
      'Сохраняйте площадки, настройки и режимы';

  @override
  String get guideSectionOwners => 'Для владельцев';

  @override
  String get guideSectionOwnersSubtitle =>
      'Разместите площадку и управляйте бронями';

  @override
  String get guideSectionSupport => 'Помощь и поддержка';

  @override
  String get guideSectionSupportSubtitle =>
      'Ответы на вопросы и связь с командой';

  @override
  String get guideContentGettingStarted =>
      'Откройте вкладку Главная, чтобы изучить спортивные площадки рядом с вами. Используйте поиск, чтобы найти активности, парки или клубы по названию. Фильтруйте по категориям — футбол, баскетбол, теннис и другие.\n\nНажмите на карточку площадки, чтобы увидеть фото, описание, доступные объекты, цены и контакты. Добавляйте площадки в избранное для быстрого доступа.';

  @override
  String get guideContentBooking =>
      'На странице площадки выберите объект и нажмите Забронировать. Выберите дату и доступный временной слот в календаре. Проверьте итоговую цену и перейдите к оплате.\n\nДля бронирования необходимо войти в аккаунт. После оплаты бронь появится в разделе Мои брони, где можно просмотреть детали или отменить.';

  @override
  String get guideContentSessions =>
      'Перейдите на вкладку Сессии, чтобы найти групповые активности от площадок или игроков. Фильтруйте по виду спорта, уровню или дате.\n\nНажмите на сессию, чтобы увидеть детали — организатора, участников, цену за человека и свободные места. Войдите и нажмите Присоединиться. Вы можете покинуть сессию до начала на странице деталей.';

  @override
  String get guideContentPayments =>
      'ZhamSpace поддерживает оплату картой и локальные способы — Kaspi и Halyk Bank. Сохранённые карты хранятся локально на устройстве для быстрой оплаты.\n\nПосле бронирования отслеживайте статус в Мои брони — подтверждено, завершено или отменено. Оплаченные брони можно отменить с запросом возврата. Удержание брони истекает, если оплата не завершена вовремя.';

  @override
  String get guideContentProfile =>
      'Вкладка Профиль содержит личные данные, язык и тему. Переключайтесь между светлой, тёмной темой или системной. Выбирайте английский, русский или казахский.\n\nСохраняйте избранные площадки с любой карточки. Владельцы могут переключиться в режим владельца из профиля для управления площадками, бронями и аналитикой.';

  @override
  String get guideContentOwners =>
      'Хотите разместить площадку? Нажмите Разместить площадку на главной и отправьте контактные данные. Наша команда свяжется с вами для подключения.\n\nВ режиме владельца используйте Owner Hub для управления площадками, расписанием, входящими заявками и аналитикой доходов.';

  @override
  String get guideContentSupport =>
      'Нужна помощь? Изучите этот гид для ответов на частые вопросы о бронировании, оплате и сессиях.\n\nДля других вопросов используйте Разместить площадку или напишите владельцу площадки через чат на странице деталей.';
}
