class AppConstants {
  static const String appName = 'QuickBills';
  static const String appVersion = '1.0.0';
  
  static const String baseUrl = 'https://api.quickbills.com/v1';
  
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  
  static const String businessInfoBox = 'business_info';
  static const String productsBox = 'products';
  static const String customersBox = 'customers';
  static const String invoicesBox = 'invoices';
  static const String billsBox = 'bills';
  static const String quotationsBox = 'quotations';
  static const String settingsBox = 'settings';
  
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  static const List<String> paymentMethods = [
    'Cash',
    'Card',
    'UPI',
    'Bank Transfer',
    'Cheque'
  ];
  
  static const Map<String, double> taxRates = {
    'GST 5%': 5.0,
    'GST 12%': 12.0,
    'GST 18%': 18.0,
    'GST 28%': 28.0,
  };
}