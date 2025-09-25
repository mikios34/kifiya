# Kifiya – Flutter Banking App

This App includes authentication, account management, transfers, and transaction history – all wrapped in a clean, modern UI and a pragmatic architecture you can actually maintain.

you clone, set the base URL, run flutter pub get, then flutter run. The rest of this doc is here when you need it.

---

## Quick start

1) Prerequisites
   - Flutter (3.x+ recommended): `flutter --version`
   - Dart SDK bundled with Flutter
   - Android Studio/Xcode for emulators or a physical device

2) Clone and install
   - `git clone <repo-url>`
   - `cd kifiya`
   - `flutter pub get`

3) Configure environment
   - Open `lib/core/constants/app_constants.dart` and set `baseUrl` to your backend host.
   - Make sure the API is reachable from your emulator/device.

4) Run
   - Android: `flutter run -d emulator-5554` (or your device id)
   - iOS: `flutter run -d <ios-device>`
   - Web (optional): `flutter run -d chrome`

If you hit a network/auth error on first run, check the “Troubleshooting” section below.

---

## What’s inside (features)

- Authentication
  - Register and login via REST endpoints
  - Tokens stored securely via `flutter_secure_storage`

- Accounts
  - Fetch paginated list of accounts
  - Account carousel UI on Accounts page and quick preview on Home
  - Clean, responsive card design with gradients and masked numbers

- Transfers
  - Pick source account from a horizontal carousel
  - Enter destination account number and amount
  - Request body: `{ fromAccountNumber, toAccountNumber, amount }`
  - In-flight and success/error feedback via Bloc

- Transactions
  - Paginated list per account: `GET /api/transactions/{accountId}`
  - Robust parser handles both empty and non-empty API responses
  - Infinite scrolling + pull-to-refresh
  - Bottom sheet with details (amount, type, direction, timestamp, description)

- Navigation & UX
  - GoRouter for clean routes
  - Consistent typography via Google Fonts (Poppins)
  - Theming and icon assets for a polished feel

---

## Tech stack

- Flutter + Dart
- State management: Bloc (flutter_bloc)
- Networking: Dio (with auth headers via an interceptor)
- DI/Service Locator: GetIt
- Routing: GoRouter
- Secure storage: flutter_secure_storage

---

## Project structure

```
lib/
  core/
    assets/                 # icons (paths in AppIcons)
    constants/              # AppConstants (baseUrl)
    services/               # token storage, etc.
    theme/                  # AppTheme
    widgets/                # common widgets (e.g., CircularIconContainer)

  features/
    auth/
      data/
        api_service/        # AuthApiService
        model/              # UserModel
        repository/         # AuthRepository
      presentation/
        bloc/               # AuthBloc, events, states
        pages/              # login, register

    account/
      data/                 # Account model/api/repository
      presentation/
        bloc/               # AccountBloc
        pages/              # AccountsPage (carousel)

    transfer/
      data/                 # Transfer model/api/repository
      presentation/
        bloc/               # TransferBloc

    transaction/
      data/                 # Transaction model/api/repository
      presentation/
        bloc/               # TransactionBloc
        pages/              # TransactionsPage (infinite scroll + details sheet)

  features/home/            # HomePage, BasePage, sections

  injector.dart             # GetIt wiring (Dio, services, repos, blocs)
  router.dart               # GoRouter routes
  main.dart                 # app entry
```

---

## Architecture, in plain English

We follow a feature-first, layered-ish approach:

- data layer → API services (Dio) + repositories (Either<Failure, Success>)
- presentation layer → Bloc for each feature, pages/widgets consume BlocBuilder/BlocConsumer
- DI via GetIt in `injector.dart` so everything is testable and injectable

The pattern is simple to reason about: UI dispatches an event → Bloc calls repository → repository calls API → Bloc yields a new state → UI rebuilds. Errors are mapped to friendly `Failure` types, not thrown across the app.

---

## API endpoints (current)

- Auth
  - `POST /api/auth/register`
  - `POST /api/auth/login`
  - `POST /api/auth/refresh-token`

- Accounts
  - `GET /api/accounts`            → paginated (response with content[] when not empty)
  - `GET /api/accounts/{id}`
  - `POST /api/accounts`           → `{ accountType, initialBalance }`

- Transfers
  - `POST /api/accounts/transfer`  → `{ fromAccountNumber, toAccountNumber, amount }`

- Transactions
  - `GET /api/transactions/{accountId}`
    - Handles two shapes:
      - empty: no `content` field, has `empty: true`
      - non-empty: includes `content: []` and `sort: []`

---

## Running, building, formatting

- Get deps: `flutter pub get`
- Run: `flutter run`
- Format: `flutter format .`
- Analyze: `flutter analyze`
- Build APK: `flutter build apk --release`
- Build iOS: `flutter build ios --release`

---

## Environment & configuration

- Base URL lives in `lib/core/constants/app_constants.dart`. Point it to your backend (http(s)://...).
- Auth tokens are stored via `TokenStorageService` (secure on device). The Dio interceptor attaches tokens to requests and can react to 401s if you wish to extend it.
- Assets are referenced via `AppIcons` and included under `assets/icons/` (see `pubspec.yaml`).

---

## Troubleshooting

- “Failed to fetch … type cast” on transactions
  - We’ve implemented a resilient parser that handles both empty and non-empty responses. If you still see it, confirm the backend matches the samples in this README, then check the console logs added in `TransactionApiService`.

- Network/SSL errors on Android emulator
  - Ensure the backend is reachable from the emulator (use 10.0.2.2 instead of localhost).

- I get 401/403 after login
  - Confirm tokens are returned and saved. See logs from `DioInterceptor`. Clear app data and try again.

- Nothing shows on Transactions page
  - Make sure you navigated with a valid `accountId` (Home → tap account). Pull to refresh to re-fetch.

---

## Contributing (for your future self or teammates)

- Keep features self-contained under `features/<name>`
- Add/extend Blocs per feature rather than one mega-bloc
- Handle API differences in the model layer – keep UIs clean
- Prefer small, readable components over clever one-liners

If you’re adding a new screen, copy an existing feature’s structure (data/api/repository + presentation/bloc/pages) and wire it up in `injector.dart` and `router.dart`.

---

## Notes

- Fonts: Poppins via GoogleFonts throughout
- UI: designed for clarity and approachability; gradients and cards match the brand palette in `AppTheme`
- This codebase is intentionally straightforward. It should be easy to onboard to, even months later.

