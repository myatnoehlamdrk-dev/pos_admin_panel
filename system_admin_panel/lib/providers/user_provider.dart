import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/admin_repository.dart';

class UserProvider extends ChangeNotifier {
  final AdminRepository _adminRepository;

  UserProvider(this._adminRepository);

  List<User> _users = [];
  List<User> _pendingUsers = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  List<User> get pendingUsers => _pendingUsers;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers({
    String? search,
    String? role,
    bool? active,
    String? shopId,
    int page = 1,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _adminRepository.getUsers(
        search: search,
        role: role,
        active: active,
        shopId: shopId,
        page: page,
      );

      _users = result.items;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _pendingUsers = await _adminRepository.getPendingUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveUser(String userId, String shopId) async {
    try {
      await _adminRepository.approveUser(userId, shopId);
      _pendingUsers.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserActive(String id) async {
    try {
      await _adminRepository.toggleUserActive(id);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        final old = _users[index];
        _users[index] = User(
          id: old.id,
          fullName: old.fullName,
          email: old.email,
          shopId: old.shopId,
          type: old.type,
          phone: old.phone,
          social: old.social,
          image: old.image,
          imageDeleteUrl: old.imageDeleteUrl,
          role: old.role,
          address: old.address,
          status: old.status,
          nrcNo: old.nrcNo,
          billingWay: old.billingWay,
          dateOfBirth: old.dateOfBirth,
          gender: old.gender,
          activeStatus: !old.activeStatus,
          isVerified: old.isVerified,
          shop: old.shop,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      await _adminRepository.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      _total--;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
