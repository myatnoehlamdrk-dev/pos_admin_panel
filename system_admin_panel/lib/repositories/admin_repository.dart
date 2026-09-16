import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/dashboard_stats.dart';
import '../models/shop.dart';
import '../models/user.dart';

class AdminRepository {
  final Dio _dio;

  AdminRepository(this._dio);

  Map<String, dynamic> _parseResponse(dynamic response) {
    final data = response.data;
    return data is Map<String, dynamic> ? data : {'data': data};
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is double) return v.toInt();
    return 0;
  }

  // Dashboard

  Future<DashboardStats> getDashboardStats() async {
    final response = await _dio.get(ApiConfig.adminDashboard);
    final parsed = _parseResponse(response);
    return DashboardStats.fromJson(parsed['data'] ?? parsed);
  }

  Future<List<SalesChartData>> getSalesChart({int days = 7}) async {
    final response = await _dio.get(ApiConfig.adminSalesChart, queryParameters: {'days': days});
    final parsed = _parseResponse(response);
    final list = parsed['data'] ?? parsed;
    return (list as List).map((e) => SalesChartData.fromJson(e)).toList();
  }

  Future<List<TopProduct>> getTopProducts({int limit = 10}) async {
    final response = await _dio.get(ApiConfig.adminTopProducts, queryParameters: {'limit': limit});
    final parsed = _parseResponse(response);
    final list = parsed['data'] ?? parsed;
    return (list as List).map((e) => TopProduct.fromJson(e)).toList();
  }

  // Shops

  Future<PaginatedResponse<Shop>> getShops({
    String? search,
    String? type,
    bool? active,
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (type != null) params['type'] = type;
    if (active != null) params['active'] = active;

    final response = await _dio.get(ApiConfig.adminShops, queryParameters: params);
    final parsed = _parseResponse(response);
    final data = parsed['data'] ?? parsed;

    return PaginatedResponse(
      items: (data['shops'] as List).map((e) => Shop.fromJson(e)).toList(),
      total: _toInt(data['pagination']['total']),
      currentPage: _toInt(data['pagination']['current_page']),
      lastPage: _toInt(data['pagination']['last_page']),
    );
  }

  Future<void> toggleShopActive(String id) async {
    await _dio.put(ApiConfig.adminShopToggle(id));
  }

  Future<void> deleteShop(String id) async {
    await _dio.delete(ApiConfig.adminShopDelete(id));
  }

  // Users

  Future<PaginatedResponse<User>> getUsers({
    String? search,
    String? role,
    bool? active,
    String? shopId,
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (role != null) params['role'] = role;
    if (active != null) params['active'] = active;
    if (shopId != null) params['shop_id'] = shopId;

    final response = await _dio.get(ApiConfig.adminUsers, queryParameters: params);
    final parsed = _parseResponse(response);
    final data = parsed['data'] ?? parsed;

    return PaginatedResponse(
      items: (data['users'] as List).map((e) => User.fromJson(e)).toList(),
      total: _toInt(data['pagination']['total']),
      currentPage: _toInt(data['pagination']['current_page']),
      lastPage: _toInt(data['pagination']['last_page']),
    );
  }

  Future<List<User>> getPendingUsers() async {
    final response = await _dio.get(ApiConfig.adminPendingUsers);
    final parsed = _parseResponse(response);
    final list = parsed['data'] ?? parsed;
    return (list as List).map((e) => User.fromJson(e)).toList();
  }

  Future<void> approveUser(String userId, String shopId) async {
    await _dio.put(ApiConfig.adminUserApprove(userId), data: {'shop_id': shopId});
  }

  Future<void> toggleUserActive(String id) async {
    await _dio.put(ApiConfig.adminUserToggle(id));
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete(ApiConfig.adminUserDelete(id));
  }
}
