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
  String get paymentStatusPaid => 'Оплачено';

  @override
  String get paymentStatusPending => 'Ожидает';

  @override
  String get paymentStatusHold => 'Удержание';

  @override
  String get paymentStatusFailed => 'Ошибка';

  @override
  String get paymentStatusRefunded => 'Возврат';
}
