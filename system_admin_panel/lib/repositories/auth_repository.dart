import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthRepository {
  final Dio _dio;
  final SharedPreferences _prefs;

  AuthRepository(this._dio, this._prefs);

  String? get token => _prefs.getString('auth_token');

  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }

  void setAuthHeader() {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(ApiConfig.login, data: {
      'email': email,
      'password': password,
    });

    final data = response.data;

    if (data['access_token'] != null) {
      await saveToken(data['access_token']);
      setAuthHeader();
    }

    return data;
  }

  Future<void> logout() async {
    try {
      setAuthHeader();
      await _dio.post('/api/auth/logout');
    } finally {
      await clearToken();
      _dio.options.headers.remove('Authorization');
    }
  }
}
