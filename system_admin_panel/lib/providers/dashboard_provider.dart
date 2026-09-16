import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../repositories/admin_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final AdminRepository _adminRepository;

  DashboardProvider(this._adminRepository);

  DashboardStats? _stats;
  List<SalesChartData> _salesChart = [];
  List<TopProduct> _topProducts = [];
  bool _isLoading = false;
  String? _error;

  DashboardStats? get stats => _stats;
  List<SalesChartData> get salesChart => _salesChart;
  List<TopProduct> get topProducts => _topProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard({int days = 7}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final results = await Future.wait([
        _adminRepository.getDashboardStats(),
        _adminRepository.getSalesChart(days: days),
        _adminRepository.getTopProducts(limit: 10),
      ]);

      _stats = results[0] as DashboardStats;
      _salesChart = results[1] as List<SalesChartData>;
      _topProducts = results[2] as List<TopProduct>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
