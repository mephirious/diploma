// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ZhamSpace';

  @override
  String get home => 'Home';

  @override
  String get explore => 'Explore';

  @override
  String get favorites => 'Favorites';

  @override
  String get reservations => 'My Bookings';

  @override
  String get profile => 'Profile';

  @override
  String get sessions => 'Sessions';

  @override
  String get chats => 'Chats';

  @override
  String get facilitiesTab => 'Facilities';

  @override
  String get bookingsTab => 'Bookings';

  @override
  String get searchFacilities => 'Search for activities, parks, or clubs';

  @override
  String get allCategories => 'All Categories';

  @override
  String get football => 'Football';

  @override
  String get basketball => 'Basketball';

  @override
  String get tennis => 'Tennis';

  @override
  String get swimming => 'Swimming';

  @override
  String get gym => 'Gym';

  @override
  String get volleyball => 'Volleyball';

  @override
  String get badminton => 'Badminton';

  @override
  String get tabletennis => 'Table Tennis';

  @override
  String get popularVenues => 'Popular Venues';

  @override
  String get nearYou => 'Near You';

  @override
  String get topRated => 'Top Rated';

  @override
  String get seeAll => 'See All';

  @override
  String get perHour => 'per hour';

  @override
  String get rating => 'Rating';

  @override
  String reviews(int count) {
    return '$count reviews';
  }

  @override
  String get bookNow => 'Book Now';

  @override
  String get viewDetails => 'View Details';

  @override
  String get openNow => 'Open Now';

  @override
  String get closed => 'Closed';

  @override
  String get availableToday => 'Available today';

  @override
  String fromPrice(String price) {
    return 'From $price₸';
  }

  @override
  String kmAway(String km) {
    return '$km km';
  }

  @override
  String get about => 'About';

  @override
  String get venueDescriptionTab => 'Description';

  @override
  String get venueContactInfoTab => 'Contact info';

  @override
  String get venueNoContacts => 'No contact information';

  @override
  String get facilities => 'Facilities';

  @override
  String get availability => 'Availability';

  @override
  String get location => 'Location';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get duration => 'Duration';

  @override
  String get hours => 'hours';

  @override
  String get hour => 'hour';

  @override
  String get available => 'Available';

  @override
  String get booked => 'Booked';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get facilityUnavailableNoSchedule => 'No opening hours';

  @override
  String get facilityUnavailableHint => 'This facility cannot be booked.';

  @override
  String get selectStartTimeLabel => 'Start time';

  @override
  String get selectEndTimeLabel => 'End time';

  @override
  String get loginToBookDescription => 'Please log in to book this facility.';

  @override
  String get noSlotsThisDay => 'No time slots are available for this date.';

  @override
  String get bookingTotalLabel => 'Total';

  @override
  String get payNowLabel => 'Pay now';

  @override
  String get unableToLoadFacilities => 'Unable to load facilities';

  @override
  String get noFacilitiesListed => 'No facilities listed';

  @override
  String facilityMetaSportType(String sport, String type) {
    return '$sport · $type';
  }

  @override
  String get bookingDetails => 'Booking Details';

  @override
  String get bookingNotFound => 'Booking not found';

  @override
  String get facility => 'Facility';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get proceedToPayment => 'Proceed to Payment';

  @override
  String get payment => 'Payment';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get debitCard => 'Debit Card';

  @override
  String get cash => 'Cash on Arrival';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get cvv => 'CVV';

  @override
  String get confirmPayment => 'Confirm Payment';

  @override
  String get processingPayment => 'Processing payment...';

  @override
  String get processingPaymentHint =>
      'Please wait while we confirm your payment.';

  @override
  String get paymentFailedTitle => 'Payment failed';

  @override
  String get paymentFailedMessage =>
      'We could not complete your payment. Check My Bookings for details.';

  @override
  String get applePay => 'Apple Pay';

  @override
  String get googlePay => 'Google Pay';

  @override
  String get kaspi => 'Kaspi';

  @override
  String get halyk => 'Halyk Bank';

  @override
  String get savedCards => 'Saved Cards';

  @override
  String get addNewCard => 'Add New Card';

  @override
  String get otherBankCards => 'Bank Card';

  @override
  String get selectCard => 'Select a card';

  @override
  String get bookingConfirmed => 'Booking Confirmed!';

  @override
  String get bookingSuccess =>
      'Your booking has been confirmed. Check your email for details.';

  @override
  String get viewBooking => 'View Booking';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get upcomingBookings => 'Upcoming';

  @override
  String get pastBookings => 'Past';

  @override
  String get noBookings => 'No bookings yet';

  @override
  String get startBooking => 'Start exploring and book your first facility!';

  @override
  String get cancelBooking => 'Cancel Booking';

  @override
  String get confirmCancel => 'Are you sure you want to cancel this booking?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get bookingCancelled => 'Booking cancelled successfully';

  @override
  String get myProfile => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get kazakh => 'Қазақша';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get addFavorites =>
      'Add facilities to your favorites to see them here';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone Number';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get authRequiredHint => 'You need an account to access this feature.';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Push Notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutUs => 'About Us';

  @override
  String get version => 'Version';

  @override
  String get filterByPrice => 'Filter by Price';

  @override
  String get priceRange => 'Price Range';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get sortBy => 'Sort By';

  @override
  String get priceLowest => 'Price: Low to High';

  @override
  String get priceHighest => 'Price: High to Low';

  @override
  String get ratingHighest => 'Highest Rated';

  @override
  String get nearest => 'Nearest to Me';

  @override
  String get openingHours => 'Opening Hours';

  @override
  String get amenities => 'Amenities';

  @override
  String get parking => 'Parking';

  @override
  String get changingRooms => 'Changing Rooms';

  @override
  String get showers => 'Showers';

  @override
  String get equipment => 'Equipment Rental';

  @override
  String get wifi => 'Free WiFi';

  @override
  String get cafeteria => 'Cafeteria';

  @override
  String get getDirections => 'Get Directions';

  @override
  String get call => 'Call';

  @override
  String get share => 'Share';

  @override
  String get now => 'Now';

  @override
  String get today => 'Today';

  @override
  String get pickDate => 'Date';

  @override
  String get filters => 'Filters';

  @override
  String get level => 'Level';

  @override
  String get allLevels => 'All Levels';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String spotsLeft(int count) {
    return '$count spots left';
  }

  @override
  String playersJoined(int count) {
    return '$count players joined';
  }

  @override
  String get joinSession => 'Join Session';

  @override
  String get sessionDetails => 'Session Details';

  @override
  String get host => 'Host';

  @override
  String get participants => 'Participants';

  @override
  String get skillLevel => 'Skill Level';

  @override
  String get pricePerPerson => 'Price per person';

  @override
  String get spotsAvailable => 'Spots Available';

  @override
  String get joinedSuccessfully => 'You have joined the session!';

  @override
  String get leaveSession => 'Leave Session';

  @override
  String get noSessions => 'No sessions available';

  @override
  String get findSessions => 'Check back later for open sessions near you';

  @override
  String get live => 'LIVE';

  @override
  String playersCount(int current, int max) {
    return '$current/$max';
  }

  @override
  String get allChats => 'All';

  @override
  String get venueChats => 'Venues';

  @override
  String get sessionGroups => 'Sessions';

  @override
  String get direct => 'Direct';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get noChats => 'No conversations yet';

  @override
  String get startChatting =>
      'When you message a venue owner, your threads show up here.';

  @override
  String get messageOwner => 'Message owner';

  @override
  String get chatEmptyThread => 'No messages yet';

  @override
  String get searchChats => 'Search conversations...';

  @override
  String get online => 'Online';

  @override
  String membersCount(int count) {
    return '$count members';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String get reserveOrBook => 'Reserve or Book';

  @override
  String get newFacilities => 'New Facilities';

  @override
  String get news => 'News';

  @override
  String get promo => 'Promo';

  @override
  String get placeYourFacility => 'Place Your Facility';

  @override
  String get guide => 'Guide';

  @override
  String get price => 'Price';

  @override
  String get distance => 'Distance';

  @override
  String get book => 'Book';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get manageTab => 'Manage';

  @override
  String get dashboardTab => 'Dashboard';

  @override
  String get analyticsTab => 'Revenue';

  @override
  String get ownerHubTitle => 'Owner Hub';

  @override
  String get ownerHubSubtitle => 'Manage your facilities, bookings, and growth';

  @override
  String get ownerFacilityHint =>
      'Keep your schedule current and your templates polished to maximize occupancy.';

  @override
  String get addEditFacility => 'Add / Edit Facility';

  @override
  String get availabilitySchedule => 'Availability & Schedule';

  @override
  String get sessionTemplates => 'Session Templates';

  @override
  String get myFacilities => 'My Facilities';

  @override
  String get statusActive => 'Active';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get profileCompletion => 'Profile completion';

  @override
  String get occupancyRate => 'Occupancy rate';

  @override
  String get bookingsDashboard => 'Bookings Dashboard';

  @override
  String get incomingRequests => 'Incoming';

  @override
  String get upcomingSessionsTitle => 'Upcoming';

  @override
  String get pastSessionsTitle => 'Past';

  @override
  String get cancellationsTitle => 'Cancellations';

  @override
  String get revenueAnalytics => 'Revenue & Analytics';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get payouts => 'Payouts';

  @override
  String get occupancyByFacility => 'Occupancy by Facility';

  @override
  String get popularSlotsHeatmap => 'Popular Time Slots Heatmap';

  @override
  String get bookingChats => 'Bookers';

  @override
  String get ownerPublicProfile => 'Public Owner Profile';

  @override
  String get hostReviews => 'Host reviews';

  @override
  String get responseRate => 'Response rate';

  @override
  String get memberSince => 'Member since';

  @override
  String get roleTestSwitch => 'Role test switch';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get roleFacilityOwner => 'Facility owner';

  @override
  String get switchToOwnerPrompt =>
      'Switch to Facility Owner mode and preview owner-only screens?';

  @override
  String get switchToCustomerPrompt =>
      'Switch back to Customer mode and restore marketplace user screens?';

  @override
  String get retry => 'Retry';

  @override
  String get reservationsAuthDescription =>
      'Login or register to manage your bookings.';

  @override
  String get bookingFallbackTitle => 'Booking';

  @override
  String venueIdFallback(String venueId) {
    return 'Venue $venueId';
  }

  @override
  String get resourcePickerFallback => 'Resource';

  @override
  String get addressLabel => 'Address';

  @override
  String get bookingContactInfoTitle => 'Contact info';

  @override
  String get bookingContactInfoSubtitle => 'Phone, email & website';

  @override
  String get contactsSectionTitle => 'Contacts';

  @override
  String get paymentRowLabel => 'Payment';

  @override
  String get holdExpiresLabel => 'Hold expires';

  @override
  String get sessionSectionTitle => 'Session';

  @override
  String get sessionIdLabel => 'Session ID';

  @override
  String get cancellationReasonLabel => 'Cancellation reason';

  @override
  String bookingIdLine(String id) {
    return 'Booking ID · $id';
  }

  @override
  String get contactTypePhoneDefault => 'Phone';

  @override
  String get contactTypeEmailDefault => 'Email';

  @override
  String get contactTypeWebsiteDefault => 'Website';

  @override
  String get notLoggedInError => 'Not logged in';

  @override
  String bookingFailedMessage(String error) {
    return 'Booking failed: $error';
  }

  @override
  String get bankCardBrandLabel => 'Bank / Brand';

  @override
  String get bankCardBrandHint => 'Visa, Mastercard…';

  @override
  String get paymentMyCards => 'My Cards';

  @override
  String get paymentNoSavedCards => 'No saved cards';

  @override
  String get paymentPayButton => 'Pay';

  @override
  String get bookingStatusCreated => 'Awaiting payment';

  @override
  String get bookingStatusPending => 'Pending';

  @override
  String get bookingStatusHold => 'Hold';

  @override
  String get bookingStatusActive => 'Active';

  @override
  String get cancelReasonPaymentTimeout => 'Payment was not completed in time';

  @override
  String get cancelReasonUserCancelled => 'Cancelled by you';

  @override
  String get cancelReasonHoldExpired => 'Reservation hold expired';

  @override
  String get cancelReasonAdminCancelled => 'Cancelled by the venue';

  @override
  String get cancelReasonRefunded => 'Cancelled due to refund';

  @override
  String get paymentStatusPaid => 'Paid';

  @override
  String get paymentStatusPending => 'Pending';

  @override
  String get paymentStatusHold => 'On hold';

  @override
  String get paymentStatusFailed => 'Failed';

  @override
  String get paymentStatusRefunded => 'Refunded';
}
