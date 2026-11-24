# AllGo Customer Super App

Production-quality all-in-one on-demand delivery and mobility Flutter mobile application for consumers. Combines Restaurant Food Delivery, Hyperlocal Grocery Ordering, Intercity & Express Parcel Booking (Porter-style), Instant Taxi/Auto Rides, and Hourly Professional Driver Hire in a single cohesive experience.

---

## 🚀 Key Features by Domain

1. **Food & Hyperlocal Groceries**:
   - Store discovery with banner carousels, category filter chips, and recommended merchants.
   - Interactive outlet catalog with sticky category tabs, in-store instant search, veg-only toggles, and price sorting.
   - Rich product cards featuring FSSAI veg/non-veg badges, strike-through MRP, percentage discount calculations, and one-tap quantity steppers.
   - Cart management supporting delivery tips (₹0, ₹10, ₹20, ₹30, ₹50), delivery instructions, cooking notes, and scheduled delivery time slots.

2. **Express Courier & Parcel Delivery**:
   - Porter-style parcel vehicle chooser (Two-Wheeler up to 20kg, Three-Wheeler up to 500kg, Tata Ace up to 1000kg, Pickup Truck up to 1500kg).
   - Fragile item handling surcharge calculations.
   - Live package tracking with 4-digit recipient verification Delivery PIN.

3. **Mobility & Hourly Drivers**:
   - On-demand ride booking with live fare estimates and driver matching.
   - Hourly professional driver hire for personal vehicle transit.

4. **Tracking, Real-Time Telemetry & Post-Order**:
   - Google Maps live courier route polyline with bearing heading rotations.
   - Exponential polling backoff (3s -> 6s -> 10s) with automatic background pause (`WidgetsBindingObserver`).
   - Direct In-App Chat with delivery partner featuring instant pre-configured quick reply chips.
   - Direct telephone dialing integration via `url_launcher`.
   - Native social order tracking sharing via `share_plus`.
   - Comprehensive Rate & Review workflow covering food quality and courier service.

5. **Security, Privacy & Compliance**:
   - Complete compliance with India's Digital Personal Data Protection (DPDP) Act Section 12.
   - Biometric authentication lock integration.
   - Active device session management and remote session revocation.
   - Guest browsing support allowing complete catalog exploration before mandatory checkout authentication.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x, Flutter 3.24+)
- **State Management**: [Riverpod 2.x](https://riverpod.dev) (`flutter_riverpod`, `ConsumerStatefulWidget`, Notifiers)
- **Navigation & Deep Linking**: [go_router](https://pub.dev/packages/go_router) with named routes (`/order/:id`, `/track/:id`)
- **Network Image Caching**: [cached_network_image](https://pub.dev/packages/cached_network_image) with skeleton shimmer placeholders
- **Internationalization**: `flutter_localizations` with native ARB translations for English (`en`), Hindi (`hi`), and Tamil (`ta`)
- **Design Tokens**: `AllGoCustomerTheme` supporting fully dynamic Light and Dark mode persisted in secure storage
- **Backend Decoupling**: Screens requiring APIs not yet finalized by backend rely on strict abstract interfaces marked `// BACKEND-NEEDED:` with deterministic mock fallbacks

---

## 📂 Directory Structure

```
lib/
├── main.dart                          # Production crash reporting boundary & async init
├── src/
│   ├── common/                        # Error mappers, friendly exceptions
│   ├── components/                    # Domain UI widgets (Cart, Offers, Tracking sheets)
│   ├── localization/                  # Generated AppLocalizations & ARB source files
│   ├── providers/                     # Riverpod state notifiers & app settings
│   ├── repositories/                  # Mock/Real abstracted backend interfaces
│   ├── router/                        # GoRouter configuration & deep link paths
│   ├── screens/                       # Presentation screens (Home, Catalog, Cart, Tracking)
│   │   └── legal/                     # Terms of Service, Privacy Policy, About
│   ├── theme/                         # Light & Dark theme definitions & typography tokens
│   └── widgets/                       # Reusable foundation widgets (VegBadge, NetworkImage)
test/                                  # 40+ comprehensive widget & unit test suites
```

---

## 🧪 Verification & Testing

### Static Code Analysis
Run the analyzer to verify zero errors and warnings:
```bash
flutter analyze
```

### Automated Test Suite
Execute the entire test suite covering all domains:
```bash
flutter test
```

---

## 📦 Building for Android & iOS

### Android Release APK / App Bundle
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS Release Archive
```bash
flutter build ipa --release
```

---

## 🔒 Production Readiness Standard
- Zero raw unhandled exceptions exposed to users (all mapped via `FriendlyError`).
- Minimum 48dp touch targets on all interactive controls.
- Dynamic font scaling support from 0.8x to 1.5x without screen overflows.
