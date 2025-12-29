class AppConstants {
  static const String appName = 'FarmaDigi POS';
  static const String fontIndex = 'Inter';

  // Hive Box Names
  static const String boxAuth = 'auth_box';
  static const String boxSettings = 'settings_box';
  static const String boxProducts = 'products_box';
  static const String boxCart = 'cart_box';
  static const String boxTransactionQueue = 'transaction_queue_box';

  // Supabase Table Names (schema public)
  static const String tableProfiles = 'profiles';
  static const String tableProducts = 'products';
  static const String tableTransactions = 'transactions';

  // Storage Keys
  static const String keyToken = 'token';
  static const String keyAppMode = 'app_mode';
}
