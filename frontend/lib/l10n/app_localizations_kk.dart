// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'ZhamSpace';

  @override
  String get home => 'Басты бет';

  @override
  String get explore => 'Шолу';

  @override
  String get favorites => 'Таңдаулылар';

  @override
  String get reservations => 'Менің брондарым';

  @override
  String get profile => 'Профиль';

  @override
  String get sessions => 'Сессиялар';

  @override
  String get chats => 'Чаттар';

  @override
  String get facilitiesTab => 'Алаңдар';

  @override
  String get bookingsTab => 'Брондар';

  @override
  String get searchFacilities => 'Спорт залдарды, парктарды іздеу';

  @override
  String get allCategories => 'Барлық санаттар';

  @override
  String get football => 'Футбол';

  @override
  String get basketball => 'Баскетбол';

  @override
  String get tennis => 'Теннис';

  @override
  String get swimming => 'Бассейн';

  @override
  String get gym => 'Жаттығу залы';

  @override
  String get volleyball => 'Волейбол';

  @override
  String get badminton => 'Бадминтон';

  @override
  String get tabletennis => 'Үстел теннисі';

  @override
  String get popularVenues => 'Танымал алаңдар';

  @override
  String get nearYou => 'Сізге жақын';

  @override
  String get topRated => 'Ең жақсылар';

  @override
  String get seeAll => 'Барлығын көру';

  @override
  String get perHour => 'сағатына';

  @override
  String get rating => 'Рейтинг';

  @override
  String reviews(int count) {
    return '$count пікір';
  }

  @override
  String get bookNow => 'Брондау';

  @override
  String get viewDetails => 'Толығырақ';

  @override
  String get openNow => 'Ашық';

  @override
  String get closed => 'Жабық';

  @override
  String get availableToday => 'Бүгін қолжетімді';

  @override
  String fromPrice(String price) {
    return '$price₸-ден';
  }

  @override
  String kmAway(String km) {
    return '$km км';
  }

  @override
  String get about => 'Сипаттама';

  @override
  String get venueDescriptionTab => 'Сипаттама';

  @override
  String get venueContactInfoTab => 'Байланыс';

  @override
  String get venueNoContacts => 'Байланыс ақпараты жоқ';

  @override
  String get facilities => 'Қолайлылықтар';

  @override
  String get availability => 'Қолжетімділік';

  @override
  String get location => 'Орналасқан жері';

  @override
  String get reviewsTitle => 'Пікірлер';

  @override
  String get selectDate => 'Күнді таңдаңыз';

  @override
  String get selectTime => 'Уақытты таңдаңыз';

  @override
  String get duration => 'Ұзақтығы';

  @override
  String get hours => 'сағат';

  @override
  String get hour => 'сағат';

  @override
  String get available => 'Қолжетімді';

  @override
  String get booked => 'Брондалған';

  @override
  String get unavailable => 'Қолжетімсіз';

  @override
  String get facilityUnavailableNoSchedule => 'Жұмыс кестесі жоқ';

  @override
  String get facilityUnavailableHint => 'Бұл алаңды брондау мүмкін емес.';

  @override
  String get selectStartTimeLabel => 'Басталуы';

  @override
  String get selectEndTimeLabel => 'Аяқталуы';

  @override
  String get loginToBookDescription => 'Алаңды брондау үшін жүйеге кіріңіз.';

  @override
  String get noSlotsThisDay => 'Осы күнге бос уақыт интервалдары жоқ.';

  @override
  String get bookingTotalLabel => 'Барлығы';

  @override
  String get payNowLabel => 'Төлеуге';

  @override
  String get unableToLoadFacilities => 'Алаңдарды жүктеу сәтсіз аяқталды';

  @override
  String get noFacilitiesListed => 'Алаңдар тізімделмеген';

  @override
  String facilityMetaSportType(String sport, String type) {
    return '$sport · $type';
  }

  @override
  String get bookingDetails => 'Брондау мәліметтері';

  @override
  String get bookingNotFound => 'Брон табылмады';

  @override
  String get facility => 'Алаң';

  @override
  String get date => 'Күні';

  @override
  String get time => 'Уақыты';

  @override
  String get totalPrice => 'Жалпы құны';

  @override
  String get proceedToPayment => 'Төлемге өту';

  @override
  String get payment => 'Төлем';

  @override
  String get paymentMethod => 'Төлем әдісі';

  @override
  String get creditCard => 'Несие картасы';

  @override
  String get debitCard => 'Дебет картасы';

  @override
  String get cash => 'Қолма-қол ақша';

  @override
  String get cardNumber => 'Карта номері';

  @override
  String get expiryDate => 'Жарамдылық мерзімі';

  @override
  String get cvv => 'CVV';

  @override
  String get confirmPayment => 'Төлемді растау';

  @override
  String get processingPayment => 'Төлем өңделуде...';

  @override
  String get processingPaymentHint => 'Төлемді растау үшін күте тұрыңыз.';

  @override
  String get paymentFailedTitle => 'Төлем сәтсіз аяқталды';

  @override
  String get paymentFailedMessage =>
      'Төлемді аяқтау мүмкін болмады. Мәліметтер «Менің брондарым» бөлімінде.';

  @override
  String get applePay => 'Apple Pay';

  @override
  String get googlePay => 'Google Pay';

  @override
  String get kaspi => 'Kaspi';

  @override
  String get halyk => 'Halyk Bank';

  @override
  String get savedCards => 'Сақталған карталар';

  @override
  String get addNewCard => 'Жаңа карта қосу';

  @override
  String get otherBankCards => 'Банк картасы';

  @override
  String get selectCard => 'Картаны таңдаңыз';

  @override
  String get bookingConfirmed => 'Брондау расталды!';

  @override
  String get bookingSuccess =>
      'Сіздің брондауыңыз расталды. Толық ақпаратты email-ден қараңыз.';

  @override
  String get viewBooking => 'Брондауды көру';

  @override
  String get backToHome => 'Басты бетке';

  @override
  String get upcomingBookings => 'Келешектегі';

  @override
  String get pastBookings => 'Өткен';

  @override
  String get noBookings => 'Брондау жоқ';

  @override
  String get startBooking =>
      'Зерттеуді бастаңыз және алғашқы алаңыңызды брондаңыз!';

  @override
  String get cancelBooking => 'Брондауды болдырмау';

  @override
  String get confirmCancel =>
      'Бұл брондауды болдырмағыңыз келетініне сенімдісіз бе?';

  @override
  String get yes => 'Иә';

  @override
  String get no => 'Жоқ';

  @override
  String get bookingCancelled => 'Брондау сәтті болдырылды';

  @override
  String get myProfile => 'Менің профилім';

  @override
  String get editProfile => 'Профильді өңдеу';

  @override
  String get settings => 'Баптаулар';

  @override
  String get language => 'Тіл';

  @override
  String get theme => 'Тақырып';

  @override
  String get lightMode => 'Ашық тақырып';

  @override
  String get darkMode => 'Қараңғы тақырып';

  @override
  String get systemDefault => 'Жүйелік';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get kazakh => 'Қазақша';

  @override
  String get myFavorites => 'Менің таңдаулыларым';

  @override
  String get noFavorites => 'Таңдаулылар жоқ';

  @override
  String get addFavorites =>
      'Алаңдарды таңдаулыларға қосыңыз, оларды мұнда көру үшін';

  @override
  String get myBookings => 'Менің брондарым';

  @override
  String get personalInfo => 'Жеке ақпарат';

  @override
  String get fullName => 'Толық аты-жөні';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Телефон номері';

  @override
  String get save => 'Сақтау';

  @override
  String get cancel => 'Болдырмау';

  @override
  String get logout => 'Шығу';

  @override
  String get confirmLogout => 'Шығуға сенімдісіз бе?';

  @override
  String get login => 'Кіру';

  @override
  String get register => 'Тіркелу';

  @override
  String get password => 'Құпия сөз';

  @override
  String get confirmPassword => 'Құпия сөзді растау';

  @override
  String get forgotPassword => 'Құпия сөзді ұмыттыңыз ба?';

  @override
  String get dontHaveAccount => 'Аккаунт жоқ па?';

  @override
  String get alreadyHaveAccount => 'Аккаунт бар ма?';

  @override
  String get signUp => 'Тіркелу';

  @override
  String get signIn => 'Кіру';

  @override
  String get authRequiredHint =>
      'Осы мүмкіндікті пайдалану үшін тіркеліңіз немесе кіріңіз.';

  @override
  String get notifications => 'Хабарландырулар';

  @override
  String get notificationsEnabled => 'Push-хабарландырулар';

  @override
  String get emailNotifications => 'Email хабарландырулар';

  @override
  String get helpSupport => 'Көмек және қолдау';

  @override
  String get termsConditions => 'Пайдалану шарттары';

  @override
  String get privacyPolicy => 'Құпиялылық саясаты';

  @override
  String get aboutUs => 'Біз туралы';

  @override
  String get version => 'Нұсқа';

  @override
  String get filterByPrice => 'Бағасы бойынша сүзгі';

  @override
  String get priceRange => 'Баға диапазоны';

  @override
  String get applyFilters => 'Сүзгілерді қолдану';

  @override
  String get clearFilters => 'Сүзгілерді тазарту';

  @override
  String get sortBy => 'Сұрыптау';

  @override
  String get priceLowest => 'Баға: өсу бойынша';

  @override
  String get priceHighest => 'Баға: кему бойынша';

  @override
  String get ratingHighest => 'Жоғары рейтингті';

  @override
  String get nearest => 'Маған ең жақын';

  @override
  String get openingHours => 'Жұмыс уақыты';

  @override
  String get amenities => 'Қолайлылықтар';

  @override
  String get parking => 'Паркинг';

  @override
  String get changingRooms => 'Киім ауыстыратын бөлмелер';

  @override
  String get showers => 'Душ';

  @override
  String get equipment => 'Жабдықты жалға алу';

  @override
  String get wifi => 'Тегін WiFi';

  @override
  String get cafeteria => 'Кафе';

  @override
  String get getDirections => 'Бағыт алу';

  @override
  String get call => 'Қоңырау шалу';

  @override
  String get share => 'Бөлісу';

  @override
  String get now => 'Қазір';

  @override
  String get today => 'Бүгін';

  @override
  String get pickDate => 'Күні';

  @override
  String get filters => 'Сүзгілер';

  @override
  String get level => 'Деңгей';

  @override
  String get allLevels => 'Барлық деңгейлер';

  @override
  String get beginner => 'Бастаушы';

  @override
  String get intermediate => 'Орташа';

  @override
  String get advanced => 'Кәсіби';

  @override
  String spotsLeft(int count) {
    return '$count орын қалды';
  }

  @override
  String playersJoined(int count) {
    return '$count ойыншы қосылды';
  }

  @override
  String get joinSession => 'Қосылу';

  @override
  String get sessionDetails => 'Сессия мәліметтері';

  @override
  String get host => 'Ұйымдастырушы';

  @override
  String get participants => 'Қатысушылар';

  @override
  String get skillLevel => 'Шеберлік деңгейі';

  @override
  String get pricePerPerson => 'Адамға баға';

  @override
  String get spotsAvailable => 'Бос орындар';

  @override
  String get joinedSuccessfully => 'Сіз сессияға қосылдыңыз!';

  @override
  String get leaveSession => 'Сессиядан шығу';

  @override
  String get noSessions => 'Қолжетімді сессиялар жоқ';

  @override
  String get findSessions => 'Жақында ашық сессияларды кейін қараңыз';

  @override
  String get live => 'LIVE';

  @override
  String playersCount(int current, int max) {
    return '$current/$max';
  }

  @override
  String get allChats => 'Барлығы';

  @override
  String get venueChats => 'Спорт залдары';

  @override
  String get sessionGroups => 'Сессиялар';

  @override
  String get direct => 'Жеке';

  @override
  String get typeMessage => 'Хабар жазыңыз...';

  @override
  String get noChats => 'Әлі сөйлесулер жоқ';

  @override
  String get startChatting =>
      'Спорт нысанының иесіне жазсаңыз, сөйлесу осы жерде пайда болады.';

  @override
  String get messageOwner => 'Иесіне жазу';

  @override
  String get chatEmptyThread => 'Әлі хабарлар жоқ';

  @override
  String get searchChats => 'Сөйлесулерді іздеу...';

  @override
  String get online => 'Желіде';

  @override
  String membersCount(int count) {
    return '$count мүше';
  }

  @override
  String get justNow => 'Жаңа ғана';

  @override
  String minutesAgo(int count) {
    return '$count мин. бұрын';
  }

  @override
  String get reserveOrBook => 'Брондау';

  @override
  String get newFacilities => 'Жаңа алаңдар';

  @override
  String get news => 'Жаңалықтар';

  @override
  String get promo => 'Акциялар';

  @override
  String get placeYourFacility => 'Алаң қосу';

  @override
  String get guide => 'Нұсқаулық';

  @override
  String get price => 'Бағасы';

  @override
  String get distance => 'Қашықтық';

  @override
  String get book => 'Брондау';

  @override
  String get confirmed => 'Расталды';

  @override
  String get completed => 'Аяқталды';

  @override
  String get cancelled => 'Болдырмалды';

  @override
  String get manageTab => 'Басқару';

  @override
  String get dashboardTab => 'Панель';

  @override
  String get analyticsTab => 'Табыс';

  @override
  String get ownerHubTitle => 'Ие кабинеті';

  @override
  String get ownerHubSubtitle =>
      'Алаңдар, броньдар және өсімді бір жерден басқарыңыз';

  @override
  String get ownerFacilityHint =>
      'Жүктемені арттыру үшін кестені үнемі жаңартып, сессия шаблондарын толық толтырыңыз.';

  @override
  String get addEditFacility => 'Алаң қосу / өңдеу';

  @override
  String get availabilitySchedule => 'Қолжетімділік және кесте';

  @override
  String get sessionTemplates => 'Сессия шаблондары';

  @override
  String get myFacilities => 'Менің алаңдарым';

  @override
  String get statusActive => 'Белсенді';

  @override
  String get statusDraft => 'Жоба';

  @override
  String get statusSuspended => 'Тоқтатылған';

  @override
  String get profileCompletion => 'Профиль толықтығы';

  @override
  String get occupancyRate => 'Жүктелу деңгейі';

  @override
  String get bookingsDashboard => 'Бронь панелі';

  @override
  String get incomingRequests => 'Кіріс';

  @override
  String get upcomingSessionsTitle => 'Алдағылар';

  @override
  String get pastSessionsTitle => 'Өткендер';

  @override
  String get cancellationsTitle => 'Бас тартулар';

  @override
  String get revenueAnalytics => 'Табыс және аналитика';

  @override
  String get daily => 'Күндік';

  @override
  String get weekly => 'Апталық';

  @override
  String get monthly => 'Айлық';

  @override
  String get payouts => 'Төлемдер';

  @override
  String get occupancyByFacility => 'Алаң бойынша жүктелу';

  @override
  String get popularSlotsHeatmap => 'Танымал уақыт слоттарының heatmap-ы';

  @override
  String get bookingChats => 'Брондаушылар';

  @override
  String get ownerPublicProfile => 'Иенің ашық профилі';

  @override
  String get hostReviews => 'Хост пікірлері';

  @override
  String get responseRate => 'Жауап беру деңгейі';

  @override
  String get memberSince => 'Мүше болған жыл';

  @override
  String get roleTestSwitch => 'Рөлді тест ауыстырғыш';

  @override
  String get roleCustomer => 'Қолданушы';

  @override
  String get roleFacilityOwner => 'Алаң иесі';

  @override
  String get switchToOwnerPrompt =>
      'Алаң иесі режиміне ауысып, owner-интерфейсті көру керек пе?';

  @override
  String get switchToCustomerPrompt =>
      'Қолданушы режиміне қайта ауысып, маркетплейс интерфейсіне оралу керек пе?';

  @override
  String get retry => 'Қайталау';

  @override
  String get reservationsAuthDescription =>
      'Броньдарды басқару үшін кіріңіз немесе тіркеліңіз.';

  @override
  String get bookingFallbackTitle => 'Бронь';

  @override
  String venueIdFallback(String venueId) {
    return 'Алаң $venueId';
  }

  @override
  String get resourcePickerFallback => 'Нысан';

  @override
  String get addressLabel => 'Мекенжай';

  @override
  String get bookingContactInfoTitle => 'Байланыс';

  @override
  String get bookingContactInfoSubtitle => 'Телефон, email және сайт';

  @override
  String get contactsSectionTitle => 'Байланыстар';

  @override
  String get paymentRowLabel => 'Төлем';

  @override
  String get holdExpiresLabel => 'Бронь мерзімі бітеді';

  @override
  String get sessionSectionTitle => 'Сессия';

  @override
  String get sessionIdLabel => 'Сессия ID';

  @override
  String get cancellationReasonLabel => 'Бас тарту себебі';

  @override
  String bookingIdLine(String id) {
    return 'Бронь ID · $id';
  }

  @override
  String get contactTypePhoneDefault => 'Телефон';

  @override
  String get contactTypeEmailDefault => 'Email';

  @override
  String get contactTypeWebsiteDefault => 'Сайт';

  @override
  String get notLoggedInError => 'Кірілмеген';

  @override
  String bookingFailedMessage(String error) {
    return 'Бронь сәтсіз: $error';
  }

  @override
  String get bankCardBrandLabel => 'Банк / желі';

  @override
  String get bankCardBrandHint => 'Visa, Mastercard…';

  @override
  String get paymentMyCards => 'Менің карталарым';

  @override
  String get paymentNoSavedCards => 'Сақталған карталар жоқ';

  @override
  String get paymentPayButton => 'Төлеу';

  @override
  String get bookingStatusCreated => 'Төлем күтілуде';

  @override
  String get bookingStatusPending => 'Күтуде';

  @override
  String get bookingStatusHold => 'Ұстау';

  @override
  String get bookingStatusActive => 'Белсенді';

  @override
  String get cancelReasonPaymentTimeout => 'Төлем уақытында аяқталмады';

  @override
  String get cancelReasonUserCancelled => 'Сіз бас тарттыңыз';

  @override
  String get cancelReasonHoldExpired => 'Бронь ұстау мерзімі аяқталды';

  @override
  String get cancelReasonAdminCancelled => 'Орын иесі бас тартты';

  @override
  String get cancelReasonRefunded => 'Қайтаруға байланысты бас тартылды';

  @override
  String get paymentStatusPaid => 'Төленді';

  @override
  String get paymentStatusPending => 'Күтуде';

  @override
  String get paymentStatusHold => 'Ұстауда';

  @override
  String get paymentStatusFailed => 'Сәтсіз';

  @override
  String get paymentStatusRefunded => 'Қайтарылды';
}
