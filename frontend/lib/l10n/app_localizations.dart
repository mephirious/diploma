import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
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
    Locale('kk'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ZhamSpace'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @reservations.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get reservations;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @facilitiesTab.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilitiesTab;

  /// No description provided for @bookingsTab.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookingsTab;

  /// No description provided for @searchFacilities.
  ///
  /// In en, this message translates to:
  /// **'Search for activities, parks, or clubs'**
  String get searchFacilities;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @football.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get football;

  /// No description provided for @basketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get basketball;

  /// No description provided for @tennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get tennis;

  /// No description provided for @swimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get swimming;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gym;

  /// No description provided for @volleyball.
  ///
  /// In en, this message translates to:
  /// **'Volleyball'**
  String get volleyball;

  /// No description provided for @badminton.
  ///
  /// In en, this message translates to:
  /// **'Badminton'**
  String get badminton;

  /// No description provided for @tabletennis.
  ///
  /// In en, this message translates to:
  /// **'Table Tennis'**
  String get tabletennis;

  /// No description provided for @popularVenues.
  ///
  /// In en, this message translates to:
  /// **'Popular Venues'**
  String get popularVenues;

  /// No description provided for @nearYou.
  ///
  /// In en, this message translates to:
  /// **'Near You'**
  String get nearYou;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRated;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **'per hour'**
  String get perHour;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviews(int count);

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get openNow;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @availableToday.
  ///
  /// In en, this message translates to:
  /// **'Available today'**
  String get availableToday;

  /// No description provided for @fromPrice.
  ///
  /// In en, this message translates to:
  /// **'From {price}₸'**
  String fromPrice(String price);

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String kmAway(String km);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @venueDescriptionTab.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get venueDescriptionTab;

  /// No description provided for @venueContactInfoTab.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get venueContactInfoTab;

  /// No description provided for @venueNoContacts.
  ///
  /// In en, this message translates to:
  /// **'No contact information'**
  String get venueNoContacts;

  /// No description provided for @facilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilities;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @facilityUnavailableNoSchedule.
  ///
  /// In en, this message translates to:
  /// **'No opening hours'**
  String get facilityUnavailableNoSchedule;

  /// No description provided for @facilityUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'This facility cannot be booked.'**
  String get facilityUnavailableHint;

  /// No description provided for @selectStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get selectStartTimeLabel;

  /// No description provided for @selectEndTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get selectEndTimeLabel;

  /// No description provided for @loginToBookDescription.
  ///
  /// In en, this message translates to:
  /// **'Please log in to book this facility.'**
  String get loginToBookDescription;

  /// No description provided for @noSlotsThisDay.
  ///
  /// In en, this message translates to:
  /// **'No time slots are available for this date.'**
  String get noSlotsThisDay;

  /// No description provided for @bookingTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get bookingTotalLabel;

  /// No description provided for @payNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get payNowLabel;

  /// No description provided for @unableToLoadFacilities.
  ///
  /// In en, this message translates to:
  /// **'Unable to load facilities'**
  String get unableToLoadFacilities;

  /// No description provided for @noFacilitiesListed.
  ///
  /// In en, this message translates to:
  /// **'No facilities listed'**
  String get noFacilitiesListed;

  /// No description provided for @facilityMetaSportType.
  ///
  /// In en, this message translates to:
  /// **'{sport} · {type}'**
  String facilityMetaSportType(String sport, String type);

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// No description provided for @bookingNotFound.
  ///
  /// In en, this message translates to:
  /// **'Booking not found'**
  String get bookingNotFound;

  /// No description provided for @facility.
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get facility;

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

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @debitCard.
  ///
  /// In en, this message translates to:
  /// **'Debit Card'**
  String get debitCard;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash on Arrival'**
  String get cash;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processingPayment;

  /// No description provided for @processingPaymentHint.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we confirm your payment.'**
  String get processingPaymentHint;

  /// No description provided for @paymentFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailedTitle;

  /// No description provided for @paymentFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not complete your payment. Check My Bookings for details.'**
  String get paymentFailedMessage;

  /// No description provided for @applePay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get applePay;

  /// No description provided for @googlePay.
  ///
  /// In en, this message translates to:
  /// **'Google Pay'**
  String get googlePay;

  /// No description provided for @kaspi.
  ///
  /// In en, this message translates to:
  /// **'Kaspi'**
  String get kaspi;

  /// No description provided for @halyk.
  ///
  /// In en, this message translates to:
  /// **'Halyk Bank'**
  String get halyk;

  /// No description provided for @savedCards.
  ///
  /// In en, this message translates to:
  /// **'Saved Cards'**
  String get savedCards;

  /// No description provided for @addNewCard.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addNewCard;

  /// No description provided for @otherBankCards.
  ///
  /// In en, this message translates to:
  /// **'Bank Card'**
  String get otherBankCards;

  /// No description provided for @selectCard.
  ///
  /// In en, this message translates to:
  /// **'Select a card'**
  String get selectCard;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bookingConfirmed;

  /// No description provided for @bookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your booking has been confirmed. Check your email for details.'**
  String get bookingSuccess;

  /// No description provided for @viewBooking.
  ///
  /// In en, this message translates to:
  /// **'View Booking'**
  String get viewBooking;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @upcomingBookings.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingBookings;

  /// No description provided for @pastBookings.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get pastBookings;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookings;

  /// No description provided for @startBooking.
  ///
  /// In en, this message translates to:
  /// **'Start exploring and book your first facility!'**
  String get startBooking;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @confirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking?'**
  String get confirmCancel;

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

  /// No description provided for @bookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled successfully'**
  String get bookingCancelled;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @kazakh.
  ///
  /// In en, this message translates to:
  /// **'Қазақша'**
  String get kazakh;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @addFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add facilities to your favorites to see them here'**
  String get addFavorites;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

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

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @authRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'You need an account to access this feature.'**
  String get authRequiredHint;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get notificationsEnabled;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @filterByPrice.
  ///
  /// In en, this message translates to:
  /// **'Filter by Price'**
  String get filterByPrice;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @priceLowest.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowest;

  /// No description provided for @priceHighest.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighest;

  /// No description provided for @ratingHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get ratingHighest;

  /// No description provided for @nearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest to Me'**
  String get nearest;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening Hours'**
  String get openingHours;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parking;

  /// No description provided for @changingRooms.
  ///
  /// In en, this message translates to:
  /// **'Changing Rooms'**
  String get changingRooms;

  /// No description provided for @showers.
  ///
  /// In en, this message translates to:
  /// **'Showers'**
  String get showers;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment Rental'**
  String get equipment;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'Free WiFi'**
  String get wifi;

  /// No description provided for @cafeteria.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria'**
  String get cafeteria;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get pickDate;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @allLevels.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get allLevels;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @spotsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} spots left'**
  String spotsLeft(int count);

  /// No description provided for @playersJoined.
  ///
  /// In en, this message translates to:
  /// **'{count} players joined'**
  String playersJoined(int count);

  /// No description provided for @joinSession.
  ///
  /// In en, this message translates to:
  /// **'Join Session'**
  String get joinSession;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get sessionDetails;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @skillLevel.
  ///
  /// In en, this message translates to:
  /// **'Skill Level'**
  String get skillLevel;

  /// No description provided for @pricePerPerson.
  ///
  /// In en, this message translates to:
  /// **'Price per person'**
  String get pricePerPerson;

  /// No description provided for @spotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Spots Available'**
  String get spotsAvailable;

  /// No description provided for @joinedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'You have joined the session!'**
  String get joinedSuccessfully;

  /// No description provided for @leaveSession.
  ///
  /// In en, this message translates to:
  /// **'Leave Session'**
  String get leaveSession;

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions available'**
  String get noSessions;

  /// No description provided for @findSessions.
  ///
  /// In en, this message translates to:
  /// **'Check back later for open sessions near you'**
  String get findSessions;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @playersCount.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max}'**
  String playersCount(int current, int max);

  /// No description provided for @allChats.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allChats;

  /// No description provided for @venueChats.
  ///
  /// In en, this message translates to:
  /// **'Venues'**
  String get venueChats;

  /// No description provided for @sessionGroups.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessionGroups;

  /// No description provided for @direct.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get direct;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @noChats.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noChats;

  /// No description provided for @startChatting.
  ///
  /// In en, this message translates to:
  /// **'When you message a venue owner, your threads show up here.'**
  String get startChatting;

  /// No description provided for @messageOwner.
  ///
  /// In en, this message translates to:
  /// **'Message owner'**
  String get messageOwner;

  /// No description provided for @chatEmptyThread.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chatEmptyThread;

  /// No description provided for @searchChats.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchChats;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersCount(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @reserveOrBook.
  ///
  /// In en, this message translates to:
  /// **'Reserve or Book'**
  String get reserveOrBook;

  /// No description provided for @newFacilities.
  ///
  /// In en, this message translates to:
  /// **'New Facilities'**
  String get newFacilities;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @promo.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get promo;

  /// No description provided for @placeYourFacility.
  ///
  /// In en, this message translates to:
  /// **'Place Your Facility'**
  String get placeYourFacility;

  /// No description provided for @guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @manageTab.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageTab;

  /// No description provided for @dashboardTab.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTab;

  /// No description provided for @analyticsTab.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get analyticsTab;

  /// No description provided for @ownerHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner Hub'**
  String get ownerHubTitle;

  /// No description provided for @ownerHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your facilities, bookings, and growth'**
  String get ownerHubSubtitle;

  /// No description provided for @ownerFacilityHint.
  ///
  /// In en, this message translates to:
  /// **'Keep your schedule current and your templates polished to maximize occupancy.'**
  String get ownerFacilityHint;

  /// No description provided for @addEditFacility.
  ///
  /// In en, this message translates to:
  /// **'Add / Edit Facility'**
  String get addEditFacility;

  /// No description provided for @availabilitySchedule.
  ///
  /// In en, this message translates to:
  /// **'Availability & Schedule'**
  String get availabilitySchedule;

  /// No description provided for @sessionTemplates.
  ///
  /// In en, this message translates to:
  /// **'Session Templates'**
  String get sessionTemplates;

  /// No description provided for @myFacilities.
  ///
  /// In en, this message translates to:
  /// **'My Facilities'**
  String get myFacilities;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @profileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile completion'**
  String get profileCompletion;

  /// No description provided for @occupancyRate.
  ///
  /// In en, this message translates to:
  /// **'Occupancy rate'**
  String get occupancyRate;

  /// No description provided for @bookingsDashboard.
  ///
  /// In en, this message translates to:
  /// **'Bookings Dashboard'**
  String get bookingsDashboard;

  /// No description provided for @incomingRequests.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get incomingRequests;

  /// No description provided for @upcomingSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingSessionsTitle;

  /// No description provided for @pastSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get pastSessionsTitle;

  /// No description provided for @cancellationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellations'**
  String get cancellationsTitle;

  /// No description provided for @revenueAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Revenue & Analytics'**
  String get revenueAnalytics;

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

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @payouts.
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get payouts;

  /// No description provided for @occupancyByFacility.
  ///
  /// In en, this message translates to:
  /// **'Occupancy by Facility'**
  String get occupancyByFacility;

  /// No description provided for @popularSlotsHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Popular Time Slots Heatmap'**
  String get popularSlotsHeatmap;

  /// No description provided for @bookingChats.
  ///
  /// In en, this message translates to:
  /// **'Bookers'**
  String get bookingChats;

  /// No description provided for @ownerPublicProfile.
  ///
  /// In en, this message translates to:
  /// **'Public Owner Profile'**
  String get ownerPublicProfile;

  /// No description provided for @hostReviews.
  ///
  /// In en, this message translates to:
  /// **'Host reviews'**
  String get hostReviews;

  /// No description provided for @responseRate.
  ///
  /// In en, this message translates to:
  /// **'Response rate'**
  String get responseRate;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @roleTestSwitch.
  ///
  /// In en, this message translates to:
  /// **'Role test switch'**
  String get roleTestSwitch;

  /// No description provided for @roleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get roleCustomer;

  /// No description provided for @roleFacilityOwner.
  ///
  /// In en, this message translates to:
  /// **'Facility owner'**
  String get roleFacilityOwner;

  /// No description provided for @switchToOwnerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Switch to Facility Owner mode and preview owner-only screens?'**
  String get switchToOwnerPrompt;

  /// No description provided for @switchToCustomerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Switch back to Customer mode and restore marketplace user screens?'**
  String get switchToCustomerPrompt;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @reservationsAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Login or register to manage your bookings.'**
  String get reservationsAuthDescription;

  /// No description provided for @bookingFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get bookingFallbackTitle;

  /// No description provided for @venueIdFallback.
  ///
  /// In en, this message translates to:
  /// **'Venue {venueId}'**
  String venueIdFallback(String venueId);

  /// No description provided for @resourcePickerFallback.
  ///
  /// In en, this message translates to:
  /// **'Resource'**
  String get resourcePickerFallback;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @bookingContactInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get bookingContactInfoTitle;

  /// No description provided for @bookingContactInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Phone, email & website'**
  String get bookingContactInfoSubtitle;

  /// No description provided for @contactsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contactsSectionTitle;

  /// No description provided for @paymentRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentRowLabel;

  /// No description provided for @holdExpiresLabel.
  ///
  /// In en, this message translates to:
  /// **'Hold expires'**
  String get holdExpiresLabel;

  /// No description provided for @sessionSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionSectionTitle;

  /// No description provided for @sessionIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get sessionIdLabel;

  /// No description provided for @cancellationReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancellationReasonLabel;

  /// No description provided for @bookingIdLine.
  ///
  /// In en, this message translates to:
  /// **'Booking ID · {id}'**
  String bookingIdLine(String id);

  /// No description provided for @contactTypePhoneDefault.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactTypePhoneDefault;

  /// No description provided for @contactTypeEmailDefault.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactTypeEmailDefault;

  /// No description provided for @contactTypeWebsiteDefault.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get contactTypeWebsiteDefault;

  /// No description provided for @notLoggedInError.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedInError;

  /// No description provided for @bookingFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Booking failed: {error}'**
  String bookingFailedMessage(String error);

  /// No description provided for @bankCardBrandLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank / Brand'**
  String get bankCardBrandLabel;

  /// No description provided for @bankCardBrandHint.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard…'**
  String get bankCardBrandHint;

  /// No description provided for @paymentMyCards.
  ///
  /// In en, this message translates to:
  /// **'My Cards'**
  String get paymentMyCards;

  /// No description provided for @paymentNoSavedCards.
  ///
  /// In en, this message translates to:
  /// **'No saved cards'**
  String get paymentNoSavedCards;

  /// No description provided for @paymentPayButton.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get paymentPayButton;

  /// No description provided for @bookingStatusCreated.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get bookingStatusCreated;

  /// No description provided for @bookingStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bookingStatusPending;

  /// No description provided for @bookingStatusHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get bookingStatusHold;

  /// No description provided for @bookingStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get bookingStatusActive;

  /// No description provided for @cancelReasonPaymentTimeout.
  ///
  /// In en, this message translates to:
  /// **'Payment was not completed in time'**
  String get cancelReasonPaymentTimeout;

  /// No description provided for @cancelReasonUserCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by you'**
  String get cancelReasonUserCancelled;

  /// No description provided for @cancelReasonHoldExpired.
  ///
  /// In en, this message translates to:
  /// **'Reservation hold expired'**
  String get cancelReasonHoldExpired;

  /// No description provided for @cancelReasonAdminCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by the venue'**
  String get cancelReasonAdminCancelled;

  /// No description provided for @cancelReasonRefunded.
  ///
  /// In en, this message translates to:
  /// **'Cancelled due to refund'**
  String get cancelReasonRefunded;

  /// No description provided for @paymentStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentStatusPaid;

  /// No description provided for @paymentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusHold.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get paymentStatusHold;

  /// No description provided for @paymentStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get paymentStatusFailed;

  /// No description provided for @paymentStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get paymentStatusRefunded;
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
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
