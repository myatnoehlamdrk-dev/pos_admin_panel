import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authRepository.login(email, password);

      if (response['role'] != 'admin') {
        _error = 'Access denied. Admin privileges required.';
        _isLoading = false;
        notifyListeners();
        await _authRepository.clearToken();
        return false;
      }

      _user = User.fromJson(response);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String msg = data?['message'] ?? e.message;
        // Laravel validation errors: { errors: { email: ["..."] } }
        final errors = data?['errors'];
        if (errors is Map && errors['email'] is List && (errors['email'] as List).isNotEmpty) {
          msg = (errors['email'] as List).first.toString();
        }
        _error = statusCode == 422 ? msg : 'Login failed: $msg';
      } else {
        _error = 'Login failed. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    notifyListeners();
  }
}
