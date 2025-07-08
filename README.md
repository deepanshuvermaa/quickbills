# QuickBills - POS & Billing Application

A comprehensive Point of Sale (POS) and billing application built with Flutter for small to medium businesses.

## Features

### Core Features
- **Authentication System**: JWT-based authentication with role management
- **POS & Billing**: Real-time cart management, multiple payment methods
- **Bluetooth Printing**: Thermal printer support for receipts
- **Inventory Management**: Product catalog with stock tracking
- **Customer Management**: Customer database with purchase history
- **Business Analytics**: Sales reports and performance metrics
- **Subscription Management**: Tiered subscription plans with Razorpay integration
- **Usage Tracking**: Comprehensive activity logging with offline sync

### Additional Features
- Offline-first architecture with automatic sync
- Multi-store support
- Barcode scanning
- Tax calculations (GST support)
- Draft bills
- Credit notes & returns
- 30-day free trial for new users
- Grace period for expired subscriptions

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository
```bash
cd quickbills
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate Hive adapters
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. Run the app

For development:
```bash
./run_dev.sh
```

For production:
```bash
./run_prod.sh
```

Or manually with environment variables:
```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:3000 \
  --dart-define=IS_PRODUCTION=false \
  --dart-define=ENABLE_LOGGING=true
```

## Project Structure

```
lib/
├── core/               # Core functionality
│   ├── constants/      # App constants
│   ├── themes/         # App themes
│   ├── utils/          # Utilities
│   └── widgets/        # Common widgets
├── features/           # Feature modules
│   ├── auth/           # Authentication
│   ├── billing/        # POS & billing
│   ├── inventory/      # Inventory management
│   ├── customers/      # Customer management
│   ├── reports/        # Analytics & reports
│   ├── settings/       # App settings
│   └── printer/        # Printer integration
├── routes/             # Navigation
└── main.dart           # App entry point
```

## Architecture

The app follows Clean Architecture principles with:
- **Presentation Layer**: UI screens and widgets with Riverpod providers
- **Domain Layer**: Business logic, entities, and repository interfaces
- **Data Layer**: Repository implementations, API clients, and local storage

## State Management

Using Riverpod for state management across the application with:
- Authentication state management
- Usage tracking
- Subscription status
- Cart and billing state

## Backend Integration

The app integrates with a Node.js/Express backend providing:
- JWT-based authentication with refresh tokens
- Subscription management with Razorpay
- Usage tracking and analytics
- PostgreSQL database

### API Endpoints
- **Authentication**: `/api/auth/*` (login, register, refresh)
- **Subscriptions**: `/api/subscriptions/*` (plans, status, payments)
- **Usage Tracking**: `/api/usage/*` (logging, stats, sync)

## Key Dependencies

- **flutter_riverpod**: State management
- **go_router**: Navigation
- **flutter_bluetooth_serial**: Bluetooth printing
- **hive**: Local database with offline support
- **dio**: Network requests with interceptors
- **flutter_secure_storage**: Secure token storage
- **fl_chart**: Charts and analytics
- **connectivity_plus**: Network status monitoring

## Development

### Running Tests
```bash
flutter test
```

### Building for Production

Android:
```bash
flutter build apk --release
```

iOS:
```bash
flutter build ios --release
```

## Environment Variables

The app uses the following environment variables:
- `API_BASE_URL`: Backend API URL (default: http://localhost:3000)
- `IS_PRODUCTION`: Production mode flag (default: false)
- `ENABLE_LOGGING`: Enable API logging (default: true)
- `RAZORPAY_KEY_ID`: Razorpay payment gateway key

## Security Features

- JWT tokens stored in secure storage
- Automatic token refresh
- API request/response interceptors
- Certificate pinning support
- Encrypted local storage for sensitive data

## License

This project is proprietary software. All rights reserved.