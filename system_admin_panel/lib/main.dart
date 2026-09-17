import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'config/api_config.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/shop_detail_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/user_detail_provider.dart';
import 'providers/user_provider.dart';
import 'repositories/admin_repository.dart';
import 'repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = prefs.getString('auth_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) {
      if (error.response?.statusCode == 401) {
        prefs.remove('auth_token');
      }
      handler.next(error);
    },
  ));

  final authRepo = AuthRepository(dio, prefs);
  final adminRepo = AdminRepository(dio);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(adminRepo)),
        ChangeNotifierProvider(create: (_) => ShopProvider(adminRepo)),
        ChangeNotifierProvider(create: (_) => UserProvider(adminRepo)),
        ChangeNotifierProvider(create: (_) => UserDetailProvider(adminRepo)),
        ChangeNotifierProvider(create: (_) => ShopDetailProvider(adminRepo)),
        Provider.value(value: adminRepo),
      ],
      child: const AdminApp(),
    ),
  );
}
