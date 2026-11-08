# Vidsell

Vidsell is a Flutter-based marketplace and social commerce application focused on product discovery, listing management, and seller/customer interaction. The app includes an onboarding/authentication flow, product feed, category discovery, chat and notifications, wallet features, and premium/VIP subscription experiences.

## Features

- Phone/email login and OTP verification flow
- Registration and onboarding screens
- Home feed with product browsing and quick actions
- Discover section with category browsing and search
- New listing creation flow and listing management
- User cabinet/profile management
- Wallet and top-up payment flow
- Messaging and notifications
- Share links and product detail interactions
- Premium/VIP subscription screens

## Tech Stack

- Flutter
- Dart
- Material Design UI
- flutter_screenutil for responsive sizing
- flutter_map with OpenStreetMap tiles for in-app maps
- flutter_svg for SVG icons
- url_launcher, share_plus, path_provider, photo_manager
- device_preview for UI previews
- dio for REST/JSON API access
- flutter_secure_storage for session tokens

## Project Structure

```text
vidsell/
├── android/               # Android project files
├── ios/                   # iOS project files
├── lib/
│   ├── core/              # Shared constants, nav helpers, widgets, utilities
│   ├── features/          # App features (auth, home, discover, cabinet, etc.)
│   └── main.dart          # App entry point
├── assets/                # Images, icons, and static assets
├── test/                  # Tests
├── analysis_options.yaml
├── pubspec.yaml           # Project dependencies and config
├── README.md
└── ...
```

## Prerequisites

Before running the project, make sure you have:

- Flutter SDK 3.11.0 or newer
- Android Studio / Xcode / Chrome for device/emulator support
- A connected device or simulator

## Getting Started

1. Clone the repository
2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

For a specific device target:

```bash
flutter devices
flutter run -d <device-id>
```

### Maps

In-app maps use `flutter_map` and the public OpenStreetMap tile service over
HTTPS. The map displays OpenStreetMap contributor attribution. The public tile
service has a usage policy and no application-specific availability guarantee;
review its policy before production traffic and select a suitable tile provider
if the app's usage requires higher limits or an SLA.

### Backend modes

The app uses mock repositories by default so it can run before the backend is
available. To connect to a REST/JSON backend, provide the API URL and select
the API repository implementations:

```bash
flutter run \
  --dart-define=BACKEND_MODE=api \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://staging-api.vidsell.az/api
```

The API client sends the stored access token as a Bearer token. The current
repository contracts expect these endpoint groups:

- `/auth/otp/request`, `/auth/otp/verify`, `/auth/otp/login`,
  `/auth/register`, `/auth/logout`
- `/listings` (feed and listing creation)
- `/listings/{listingId}` (listing detail)
- `/media/upload` (multipart image/video upload)
- `/videos/{id}` and `/videos/{id}/pause`, `/videos/{id}/resume`
- `/me/listings`, `/me/listings/{listingId}/status`,
  `/me/listings/{listingId}` (owned listing management)
- `/products/me/status-counts`
- `/search`, `/search/suggestions`
- `/me/favorites`, `/listings/{listingId}/favorite`
- `/me/follows`, `/stores/{storeId}/follow`
- `/me/saved-searches`
- `/listings/{listingId}/reports`, `/users/{userId}/block`
- `DELETE /me/favorites`, `DELETE /me/follows` (clear engagement lists)
- `/categories/{categoryId}/subcategories`
- `/cities`
- `/me`
- `/settings`
- `/wallet`, `/wallet/transactions`, `/wallet/top-ups`
- `/wallet/refunds`
- `/promotions/availability`
- `/payments/payment-methods` (reserved for PSP tokenization; raw card data
  must not be sent to this backend)
- `/business-accounts`, `/business-accounts/{id}`
- `/business-accounts/{id}/verification`
- `/business-accounts/{id}/listings`
- `/business-accounts/{id}/analytics`

Wallet top-ups in API mode use a payment token. The legacy raw-card repository
method is intentionally rejected by the API implementation; replace the
placeholder payment provider with the selected PSP's mobile SDK before
production so card data never reaches this application backend.

The backend should return JSON fields matching the existing models. Payment
card handling must be replaced with the selected payment provider's tokenized
flow before production; do not store raw card data.

## Release readiness

Development uses mock repositories by default. Staging and production require
an explicit HTTPS API URL and automatically disable mock mode. Never pass
payment card data to the application API; configure the selected PSP mobile SDK
before enabling production payments.

Android release builds require a local `android/key.properties` file or a
CI-generated equivalent. Do not commit that file or its keystore. Release
builds enable shrinking and resource optimization.

```bash
flutter test
flutter test integration_test/app_smoke_test.dart
flutter build appbundle --release `
  --dart-define=APP_ENV=production `
  --dart-define=BACKEND_MODE=api `
  --dart-define=API_BASE_URL=https://api.vidsell.az/api
```

To run the app in web mode:

```bash
flutter run -d chrome
```

## Useful Commands

```bash
flutter analyze
flutter test
flutter build apk
flutter build ios
```

## Notes

- The app currently starts from the login screen in `lib/main.dart`.
- `device_preview` is enabled during development for UI testing across device sizes.
- Most screens are organized under `lib/features` for easier feature-based development.

## Contribution

This project is best developed with the Flutter extension in VS Code or Android Studio. Keep feature code within the existing `lib/features` folders and shared UI/helpers in `lib/core`.
