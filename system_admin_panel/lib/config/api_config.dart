class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';

  static const String adminDashboard = '/api/admin/dashboard';
  static const String adminSalesChart = '/api/admin/dashboard/sales-chart';
  static const String adminTopProducts = '/api/admin/dashboard/top-products';

  static const String adminShops = '/api/admin/shops';
  static String adminShopToggle(String id) => '/api/admin/shops/$id/toggle-active';
  static String adminShopDelete(String id) => '/api/admin/shops/$id';

  static const String adminUsers = '/api/admin/users';
  static const String adminPendingUsers = '/api/admin/users/pending';
  static String adminUserApprove(String id) => '/api/admin/users/$id/approve';
  static String adminUserToggle(String id) => '/api/admin/users/$id/toggle-active';
  static String adminUserDelete(String id) => '/api/admin/users/$id';

  static const String images = '/api/images';
}
