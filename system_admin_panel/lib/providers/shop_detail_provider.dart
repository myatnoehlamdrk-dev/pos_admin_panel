import 'package:flutter/material.dart';
import '../models/shop_detail.dart';
import '../repositories/admin_repository.dart';

class ShopDetailProvider extends ChangeNotifier {
  final AdminRepository _adminRepository;

  ShopDetailProvider(this._adminRepository);

  ShopDetail? _shopDetail;
  ShopAnalytics? _analytics;
  List<Map<String, dynamic>> _transactions = [];
  int _transactionsPage = 1;
  int _transactionsLastPage = 1;
  int _transactionsTotal = 0;
  bool _isLoadingDetail = false;
  bool _isLoadingAnalytics = false;
  bool _isLoadingTransactions = false;
  String? _error;

  ShopDetail? get shopDetail => _shopDetail;
  ShopAnalytics? get analytics => _analytics;
  List<Map<String, dynamic>> get transactions => _transactions;
  int get transactionsPage => _transactionsPage;
  int get transactionsLastPage => _transactionsLastPage;
  int get transactionsTotal => _transactionsTotal;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get error => _error;

  Future<void> loadShopDetail(String id) async {
    try {
      _isLoadingDetail = true;
      _error = null;
      notifyListeners();

      _shopDetail = await _adminRepository.getShopDetail(id);
      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> loadShopAnalytics(String id) async {
    try {
      _isLoadingAnalytics = true;
      _error = null;
      notifyListeners();

      _analytics = await _adminRepository.getShopAnalytics(id);
      _isLoadingAnalytics = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  Future<void> loadShopTransactions(String id, {int page = 1}) async {
    try {
      _isLoadingTransactions = true;
      _error = null;
      notifyListeners();

      final result = await _adminRepository.getShopTransactions(id, page: page);
      _transactions = result.items;
      _transactionsPage = result.currentPage;
      _transactionsLastPage = result.lastPage;
      _transactionsTotal = result.total;
      _isLoadingTransactions = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  void reset() {
    _shopDetail = null;
    _analytics = null;
    _transactions = [];
    _transactionsPage = 1;
    _transactionsLastPage = 1;
    _transactionsTotal = 0;
    _error = null;
  }
}
