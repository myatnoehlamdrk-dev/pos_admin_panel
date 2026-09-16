import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../repositories/admin_repository.dart';

class ShopProvider extends ChangeNotifier {
  final AdminRepository _adminRepository;

  ShopProvider(this._adminRepository);

  List<Shop> _shops = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _isLoading = false;
  String? _error;

  List<Shop> get shops => _shops;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadShops({
    String? search,
    String? type,
    bool? active,
    int page = 1,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _adminRepository.getShops(
        search: search,
        type: type,
        active: active,
        page: page,
      );

      _shops = result.items;
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

  Future<bool> toggleShopActive(String id) async {
    try {
      await _adminRepository.toggleShopActive(id);
      final index = _shops.indexWhere((s) => s.id == id);
      if (index != -1) {
        _shops[index] = Shop(
          id: _shops[index].id,
          shopName: _shops[index].shopName,
          shopType: _shops[index].shopType,
          shopImage: _shops[index].shopImage,
          shopPhysicalAddress: _shops[index].shopPhysicalAddress,
          ownerName: _shops[index].ownerName,
          ownerEmail: _shops[index].ownerEmail,
          ownerPhone: _shops[index].ownerPhone,
          isActive: !_shops[index].isActive,
          usersCount: _shops[index].usersCount,
          salesCount: _shops[index].salesCount,
          totalRevenue: _shops[index].totalRevenue,
          createdAt: _shops[index].createdAt,
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

  Future<bool> deleteShop(String id) async {
    try {
      await _adminRepository.deleteShop(id);
      _shops.removeWhere((s) => s.id == id);
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
