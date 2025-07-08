# QuickBills Flutter App - Development Guide

## Project Overview
QuickBills is a comprehensive Point of Sale (POS) and billing application built with Flutter for small to medium businesses. It features JWT authentication, offline-first architecture, Bluetooth printing, and subscription management.

## Key Features Implemented
- ✅ JWT Authentication with refresh tokens
- ✅ Comprehensive hamburger menu navigation
- ✅ POS & billing module with cart functionality
- ✅ Bluetooth thermal printer support (58mm/80mm)
- ✅ Inventory management with barcode scanning
- ✅ Customer management system
- ✅ Business analytics dashboard
- ✅ Subscription management with Razorpay
- ✅ Usage tracking with offline sync
- ✅ Multi-language support ready
- ✅ Responsive design (phone & tablet)

## Architecture
The app follows Clean Architecture principles:
- **Presentation Layer**: Screens, widgets, and Riverpod providers
- **Domain Layer**: Business logic, entities, and repository interfaces
- **Data Layer**: API clients, local storage (Hive), and repository implementations

## State Management
Using Riverpod for state management with providers for:
- Authentication state
- Subscription status
- Inventory management
- Usage tracking
- Cart state

## Backend Integration
Integrates with Node.js/Express backend:
- Base URL: Configurable via environment variables
- Authentication: Bearer token in headers
- Automatic token refresh on 401 errors
- Offline support with sync capabilities

## Key Commands
```bash
# Run in development
./run_dev.sh

# Run in production
./run_prod.sh

# Generate Hive adapters
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Environment Variables
- `API_BASE_URL`: Backend API URL
- `IS_PRODUCTION`: Production flag
- `ENABLE_LOGGING`: API logging toggle
- `RAZORPAY_KEY_ID`: Payment gateway key

## Important Files
- `/lib/core/network/api_client.dart`: API configuration with interceptors
- `/lib/features/auth/presentation/providers/auth_provider.dart`: Auth state management
- `/lib/features/printer/data/services/bluetooth_printer_service.dart`: Printer integration
- `/lib/core/widgets/app_drawer.dart`: Navigation drawer implementation

## Testing Credentials
For development/testing, you can use:
- Email: test@quickbills.com
- Password: test123

## Printer Testing
The app supports ESC/POS thermal printers:
1. Enable Bluetooth permissions
2. Scan for printers in Printer Settings
3. Connect to your printer
4. Use "Print Test Receipt" to verify

## Offline Functionality
- All data stored locally using Hive
- Automatic sync when online
- Usage logs batched for efficiency
- Conflict resolution for multi-device sync

## Security Features
- JWT tokens in secure storage
- Automatic token refresh
- Certificate pinning ready
- Encrypted local storage
- Permission-based access control

## Next Steps for Enhancement
1. Implement push notifications
2. Add multi-store support
3. Enhance reporting with export features
4. Add backup/restore functionality
5. Implement real-time sync with WebSocket