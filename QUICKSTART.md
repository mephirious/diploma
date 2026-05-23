# 🚀 Quick Start Guide - SportBooking MVP

Get the SportBooking MVP running in minutes!

---

## ⚡ Fast Setup (< 5 minutes)

### 1. Prerequisites Check

Make sure you have Flutter installed:
```bash
flutter --version
```

If not installed, visit: https://flutter.dev/docs/get-started/install

### 2. Navigate to Frontend

```bash
cd frontend
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Generate Localizations

```bash
flutter gen-l10n
```

### 5. Run the App

```bash
flutter run
```

That's it! The app will launch with all mock data ready to use.

---

## 📱 What You Can Do

### Immediately Available Features:

✅ **Browse 8 Sport Facilities**
- Football Arena
- Basketball Court
- Tennis Club
- Swimming Pool
- Gym
- Volleyball Arena
- Badminton Center
- Table Tennis Hall

✅ **Search & Filter**
- Search by name or category
- Filter by sport type
- Sort by price or rating

✅ **Book Facilities**
- Pick date (next 14 days)
- Select time slot
- Choose duration (1-6 hours)
- Mock payment

✅ **Manage Bookings**
- View upcoming reservations
- See booking history
- Cancel bookings

✅ **Personalize**
- Add to favorites
- Switch language (EN/RU/KK)
- Toggle light/dark theme

---

## 🎨 Trying Different Features

### Change Language
1. Tap **Profile** (bottom right)
2. Tap **Language**
3. Select: English / Русский / Қазақша

### Switch Theme
1. Tap **Profile**
2. Tap **Theme**
3. Choose: Light / Dark / System

### Book a Facility
1. Tap any venue card on **Home**
2. Tap **Book Now**
3. Select date, time, and duration
4. Tap **Proceed to Payment**
5. Choose payment method
6. Tap **Confirm Payment**
7. See success confirmation!

### Add to Favorites
- Tap the ❤️ icon on any venue card
- View all favorites in the **Favorites** tab

---

## 🔧 Troubleshooting

### App Won't Build?
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter gen-l10n
flutter run
```

### Localization Errors?
```bash
# Regenerate localizations
flutter gen-l10n
```

### Want to Reset?
```bash
# Stop the app and restart
# Mock data resets automatically
```

---

## 📱 Best Viewing Experience

**Recommended:**
- iOS Simulator (iPhone 14 Pro)
- Chrome Browser
- Android Emulator (Pixel 5)

**Screen Size:**
- Works on all sizes, optimized for phones

---

## 💡 Pro Tips

1. **Use Chrome for fastest testing** - `flutter run -d chrome`
2. **Hot reload** - Press `r` in terminal while app is running
3. **Hot restart** - Press `R` for full restart
4. **Toggle inspector** - Press `i` to debug layout

---

## 🎯 MVP Limitations (Intentional)

This is a presentation MVP with:
- ✅ Mock data (no backend needed)
- ✅ Mock payment (no real transactions)
- ✅ Mock user (auto-logged in)
- ❌ No real API calls
- ❌ No data persistence (resets on restart)
- ❌ No real authentication

These are **by design** for easy demonstration!

---

## 📧 Need Help?

This is a self-contained MVP. Everything should work out of the box!

If you encounter issues:
1. Ensure Flutter SDK is properly installed
2. Run `flutter doctor` to check setup
3. Try `flutter clean && flutter pub get`

---

**Enjoy exploring SportBooking! 🏟️**
