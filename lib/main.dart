import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/data/models/subscription_model.dart';
import 'features/usage/data/models/usage_log_model.dart';
import 'features/customers/data/models/customer_model.dart';
import 'features/expenses/data/models/expense_model.dart';
import 'features/staff/data/models/staff_model.dart';
import 'features/quotations/data/models/quotation_model.dart';
import 'features/inventory/data/models/product_model.dart';
import 'features/billing/data/models/bill_model.dart';
import 'features/billing/presentation/widgets/discount_dialog.dart';
import 'features/billing/presentation/widgets/tax_settings_dialog.dart';
import 'features/billing/presentation/adapters/discount_type_adapter.dart';
import 'features/billing/presentation/adapters/tax_type_adapter.dart';
import 'features/cash_management/data/models/daily_closing_model.dart';
import 'features/data_management/data/models/export_history_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  await Hive.initFlutter();
  
  // Register all Hive adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(SubscriptionModelAdapter());
  Hive.registerAdapter(UsageLogModelAdapter());
  Hive.registerAdapter(CustomerModelAdapter());
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(StaffModelAdapter());
  Hive.registerAdapter(QuotationModelAdapter());
  Hive.registerAdapter(QuotationItemAdapter());
  Hive.registerAdapter(BillModelAdapter());
  Hive.registerAdapter(BillItemModelAdapter());
  Hive.registerAdapter(PaymentSplitModelAdapter());
  Hive.registerAdapter(BillStatusAdapter());
  Hive.registerAdapter(DiscountTypeAdapter());
  Hive.registerAdapter(TaxTypeAdapter());
  Hive.registerAdapter(DailyClosingModelAdapter());
  Hive.registerAdapter(ExportHistoryModelAdapter());
  
  await Hive.openBox(AppConstants.businessInfoBox);
  await Hive.openBox<ProductModel>(AppConstants.productsBox);
  await Hive.openBox<CustomerModel>(AppConstants.customersBox);
  await Hive.openBox(AppConstants.invoicesBox);
  await Hive.openBox<BillModel>(AppConstants.billsBox);
  await Hive.openBox<QuotationModel>(AppConstants.quotationsBox);
  await Hive.openBox(AppConstants.settingsBox);
  
  runApp(
    const ProviderScope(
      child: QuickBillsApp(),
    ),
  );
}

class QuickBillsApp extends ConsumerWidget {
  const QuickBillsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}