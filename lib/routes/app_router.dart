import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/billing/presentation/screens/billing_screen.dart';
import '../features/billing/presentation/screens/invoice_detail_screen.dart';
import '../features/billing/presentation/screens/bills_history_screen.dart';
import '../features/customers/presentation/screens/customers_screen.dart';
import '../features/customers/presentation/screens/customer_detail_screen.dart';
import '../features/inventory/presentation/screens/inventory_screen.dart';
import '../features/inventory/presentation/screens/product_detail_screen.dart';
import '../features/reports/presentation/screens/reports_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/invoice_settings_screen.dart';
import '../features/settings/presentation/screens/business_settings_screen.dart';
import '../features/settings/presentation/screens/tax_settings_screen.dart';
import '../features/printer/presentation/screens/printer_settings_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/expenses/presentation/screens/expenses_screen.dart';
import '../features/quotations/presentation/screens/quotations_screen.dart';
import '../features/credit_notes/presentation/screens/credit_notes_screen.dart';
import '../features/staff/presentation/screens/staff_screen.dart';
import '../features/subscriptions/presentation/screens/subscription_screen.dart';
import '../features/help/presentation/screens/help_screen.dart';
import '../features/about/presentation/screens/about_screen.dart';
import '../features/backup/presentation/screens/backup_restore_screen.dart';
import '../features/scanner/presentation/screens/scanner_settings_screen.dart';
import '../features/data_management/presentation/screens/import_export_screen.dart';
import '../features/sync/presentation/screens/sync_settings_screen.dart';
import '../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../features/legal/presentation/screens/terms_screen.dart';
import '../features/legal/presentation/screens/privacy_screen.dart';
import '../features/cash_management/presentation/screens/daily_closing_screen.dart';
import '../core/widgets/main_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/billing',
            builder: (context, state) => const BillingScreen(),
            routes: [
              GoRoute(
                path: 'invoice/:id',
                builder: (context, state) {
                  final invoiceId = state.pathParameters['id']!;
                  return InvoiceDetailScreen(invoiceId: invoiceId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/bills-history',
            builder: (context, state) => const BillsHistoryScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
            routes: [
              GoRoute(
                path: 'product/:id',
                builder: (context, state) {
                  final productId = state.pathParameters['id']!;
                  return ProductDetailScreen(productId: productId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomersScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final customerId = state.pathParameters['id']!;
                  return CustomerDetailScreen(customerId: customerId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpensesScreen(),
          ),
          GoRoute(
            path: '/quotations',
            builder: (context, state) => const QuotationsScreen(),
          ),
          GoRoute(
            path: '/credit-notes',
            builder: (context, state) => const CreditNotesScreen(),
          ),
          GoRoute(
            path: '/staff',
            builder: (context, state) => const StaffScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'printer',
                builder: (context, state) => const PrinterSettingsScreen(),
              ),
              GoRoute(
                path: 'invoice',
                builder: (context, state) => const InvoiceSettingsScreen(),
              ),
              GoRoute(
                path: 'business',
                builder: (context, state) => const BusinessSettingsScreen(),
              ),
              GoRoute(
                path: 'tax',
                builder: (context, state) => const TaxSettingsScreen(),
              ),
              GoRoute(
                path: 'scanner',
                builder: (context, state) => const ScannerSettingsScreen(),
              ),
              GoRoute(
                path: 'import-export',
                builder: (context, state) => const ImportExportScreen(),
              ),
              GoRoute(
                path: 'sync',
                builder: (context, state) => const SyncSettingsScreen(),
              ),
              GoRoute(
                path: 'notifications',
                builder: (context, state) => const NotificationSettingsScreen(),
              ),
              GoRoute(
                path: 'terms',
                builder: (context, state) => const TermsScreen(),
              ),
              GoRoute(
                path: 'privacy',
                builder: (context, state) => const PrivacyScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/subscription',
            builder: (context, state) => const SubscriptionScreen(),
          ),
          GoRoute(
            path: '/help',
            builder: (context, state) => const HelpScreen(),
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: '/backup-restore',
            builder: (context, state) => const BackupRestoreScreen(),
          ),
          GoRoute(
            path: '/daily-closing',
            builder: (context, state) => const DailyClosingScreen(),
          ),
        ],
      ),
    ],
  );
});