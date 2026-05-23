# 🏟️ SportBooking - Sport Facilities Booking Platform

A beautiful, modern Flutter MVP application for browsing and booking sport facilities with complete multi-language support and stunning UI/UX.

<div align="center">
  
  ![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
  ![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
  ![Languages](https://img.shields.io/badge/Languages-EN%20%7C%20RU%20%7C%20KK-green.svg)
  
</div>

---

## ✨ Features

### 🎯 Core Functionality
- **Browse Facilities** - Explore 8+ sport facilities (Football, Basketball, Tennis, Swimming, Gym, Volleyball, Badminton, Table Tennis)
- **Smart Search & Filters** - Search by name, category, and advanced filters
- **Detailed Venue Pages** - Image galleries, amenities, ratings, reviews, and opening hours
- **Easy Booking** - Interactive date picker, time slot selection, and duration settings
- **Mock Payment** - Credit card, debit card, and cash payment options
- **My Reservations** - View upcoming and past bookings with cancellation option
- **Favorites** - Save your favorite facilities for quick access

### 🌍 Internationalization
- **3 Languages** - Full support for English, Russian, and Kazakh
- **Runtime Switching** - Change language instantly from settings
- **Localized Content** - All UI text, dates, and formatting localized

### 🎨 Beautiful Design
- **Modern UI** - Material Design 3 with custom components
- **Light/Dark Themes** - Automatic and manual theme switching
- **Smooth Animations** - Polished transitions and interactions
- **Responsive** - Beautiful on all screen sizes
- **Image Galleries** - Swipeable venue photos with indicators

### 📱 User Experience
- **Bottom Navigation** - Easy access to Home, Reservations, Favorites, and Profile
- **Profile Management** - View and edit personal information
- **Settings** - Language, theme, and notification preferences
- **Mock Data** - Complete MVP with no backend required

---

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** - Version 3.0.0 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart SDK** - Version 3.0.0 or higher (included with Flutter)
- **IDE** - VS Code, Android Studio, or IntelliJ IDEA
- **Device/Emulator** - iOS Simulator, Android Emulator, or physical device

### Installation

1. **Navigate to frontend directory**
```bash
cd frontend
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate localization files**
```bash
flutter gen-l10n
```

4. **Run the app**
```bash
# For Chrome (Web)
flutter run -d chrome

# For iOS Simulator
flutter run -d iphone

# For Android Emulator
flutter run -d emulator

# Or let Flutter choose
flutter run
```

---

## 📱 Using the MVP

This is a **complete MVP with mock data** - no backend or API setup required!

### Demo User Account
The app automatically logs you in with:
- **Name**: Danial Bolat
- **Email**: danial.bolat@example.com
- **Phone**: +7 (777) 123-45-67

### Sample Facilities
The MVP includes 8 pre-configured sport facilities:
- **Premier Football Arena** - ₸15,000/hour
- **Elite Basketball Court** - ₸12,000/hour
- **Grand Tennis Club** - ₸8,000/hour
- **Aqua Sports Complex** - ₸5,000/hour
- **Power Fitness Gym** - ₸3,000/hour
- **Victory Volleyball Arena** - ₸10,000/hour
- **Ace Badminton Center** - ₸6,000/hour
- **Spin Masters Table Tennis** - ₸4,000/hour

### Key Actions
1. **Browse** - Explore facilities on the home page
2. **Search** - Use the search bar to find specific facilities
3. **Filter** - Select categories (Football, Basketball, etc.)
4. **View Details** - Tap any facility to see full details
5. **Book** - Select date, time, and duration, then proceed to payment
6. **Manage** - View your bookings in the Reservations tab
7. **Favorites** - Add facilities to favorites with the heart icon
8. **Settings** - Change language and theme in Profile settings

---

## 🏗️ Architecture

### Clean Architecture Structure

```
lib/
├── core/                      # Core functionality
│   ├── constants/            # App constants
│   ├── data/                 # Mock data providers
│   ├── network/              # API client (for future use)
│   ├── providers/            # Theme & locale providers
│   ├── router/               # Navigation (legacy)
│   ├── theme/                # App themes and colors
│   └── widgets/              # Shared widgets
│
├── features/                  # Feature modules
│   ├── auth/                 # Authentication (mock)
│   │   ├── data/
│   │   │   └── models/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── providers/
│   │
│   ├── reservations/         # Booking management
│   │   ├── data/
│   │   └── presentation/
│   │
│   └── venues/               # Facility browsing & details
│       ├── data/
│       └── presentation/
│           ├── pages/
│           ├── providers/
│           └── widgets/
│
├── l10n/                     # Localization files
│   ├── app_en.arb           # English translations
│   ├── app_ru.arb           # Russian translations
│   └── app_kk.arb           # Kazakh translations
│
└── main.dart                 # App entry point
```

### State Management
- **Riverpod** - Modern, compile-safe state management
- **Providers** - Separate providers for venues, reservations, theme, and locale
- **State Persistence** - Theme and language preferences saved locally

---

## 📦 Dependencies

### Core
- **flutter_riverpod** `^2.4.9` - State management
- **shared_preferences** `^2.2.2` - Local storage for settings
- **intl** `^0.20.2` - Internationalization and date formatting

### UI/UX
- **flutter_localizations** - Multi-language support
- **Material Design 3** - Modern UI components

### Development
- **flutter_lints** `^3.0.0` - Linting rules
- **flutter_dotenv** `^5.1.0` - Environment configuration

---

## 🌍 Internationalization

### Supported Languages

| Language | Code | Status |
|----------|------|--------|
| English  | `en` | ✅ Complete |
| Russian  | `ru` | ✅ Complete |
| Kazakh   | `kk` | ✅ Complete |

### Adding Translations

1. Edit the `.arb` files in `lib/l10n/`:
   - `app_en.arb` - English
   - `app_ru.arb` - Russian  
   - `app_kk.arb` - Kazakh

2. Regenerate localization files:
```bash
flutter gen-l10n
```

3. Use in code:
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.bookNow)  // Displays "Book Now", "Забронировать", or "Брондау"
```

---

## 🎨 Theming

### Color Palette

**Light Theme**
- Primary: `#00BFA5` (Teal)
- Background: `#F5F7FA`
- Surface: `#FFFFFF`

**Dark Theme**
- Primary: `#00BFA5` (Teal)
- Background: `#121212`
- Surface: `#1E1E1E`

### Theme Modes
- **Light** - Bright, clean interface
- **Dark** - OLED-friendly dark theme
- **System** - Follows device theme (default)

Change in: Profile → Settings → Theme

---

## 📱 Screens Overview

### Home Page
- Search bar with real-time filtering
- Category chips (All, Football, Basketball, etc.)
- Popular venues carousel
- Complete venue list with cards
- Pull-to-refresh

### Venue Detail Page
- Image gallery with swipe navigation
- Venue information (rating, location, price)
- 4 tabs: About, Amenities, Availability, Reviews
- Quick booking button

### Booking Flow
1. **Date Selection** - Horizontal date picker (14 days)
2. **Time Slots** - Available times with booked slots disabled
3. **Duration** - 1-6 hours with +/- controls
4. **Payment** - Mock payment with card details or cash option
5. **Confirmation** - Success dialog with booking details

### Reservations Page
- Tabs: Upcoming / Past
- Booking cards with venue image
- Cancellation for upcoming bookings
- Empty state with helpful message

### Favorites Page
- Saved facilities list
- Quick access to favorited venues
- Empty state with call-to-action

### Profile Page
- User information display
- Settings (Language, Theme, Notifications)
- Help & Support links
- Logout option

---

## 🔧 Configuration

### Environment Variables

Create a `.env` file (optional for MVP):
```env
API_BASE_URL=http://localhost:8080
```

### App Constants

Edit `lib/core/constants/app_constants.dart` for:
- API endpoints (future use)
- Timeouts
- Pagination limits

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Check for issues
flutter analyze
```

---

## 🚢 Building for Production

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Then archive in Xcode
```

### Web
```bash
flutter build web --release
# Output: build/web/
```

---

## 🎯 Future Enhancements

- [ ] Real backend integration
- [ ] User authentication (OAuth, social login)
- [ ] Real payment processing
- [ ] Push notifications
- [ ] Map view with venue locations
- [ ] Advanced filtering (price range, distance, rating)
- [ ] Venue owner dashboard
- [ ] Reviews and ratings submission
- [ ] Social sharing
- [ ] Booking history export

---

## 📄 License

This project is part of a diploma thesis.

---

## 👨‍💻 Developer

**Danial Bolat**  
For presentation and evaluation purposes.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Unsplash for venue placeholder images
- Material Design team for design guidelines

---

**Built with ❤️ using Flutter**
