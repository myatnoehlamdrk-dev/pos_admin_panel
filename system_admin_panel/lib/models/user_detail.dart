import 'user.dart';

class UserDetail {
  final User user;
  final UserAnalytics? analytics;

  UserDetail({
    required this.user,
    this.analytics,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      user: User.fromJson(json['user'] ?? json),
      analytics: json['analytics'] != null
          ? UserAnalytics.fromJson(json['analytics'])
          : null,
    );
  }
}

class UserAnalytics {
  final int totalTransactions;
  final double avgTransactionValue;
  final int totalItemsSold;
  final String? lastActive;
  final List<DailySales> salesChart;
  final List<TopProductSales> topProducts;
  final PerformanceMetrics? performance;

  UserAnalytics({
    required this.totalTransactions,
    required this.avgTransactionValue,
    required this.totalItemsSold,
    this.lastActive,
    required this.salesChart,
    required this.topProducts,
    this.performance,
  });

  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    return UserAnalytics(
      totalTransactions: _toInt(json['totalTransactions'] ?? json['total_transactions']),
      avgTransactionValue: _toDouble(json['avgTransactionValue'] ?? json['avg_transaction_value']),
      totalItemsSold: _toInt(json['totalItemsSold'] ?? json['total_items_sold']),
      lastActive: json['lastActive']?.toString() ?? json['last_active']?.toString(),
      salesChart: (json['salesChart'] ?? json['sales_chart'] as List? ?? [])
          .map((e) => DailySales.fromJson(e))
          .toList(),
      topProducts: (json['topProducts'] ?? json['top_products'] as List? ?? [])
          .map((e) => TopProductSales.fromJson(e))
          .toList(),
      performance: json['performance'] != null
          ? PerformanceMetrics.fromJson(json['performance'])
          : null,
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is double) return v.toInt();
    return 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}

class DailySales {
  final String date;
  final int amount;
  final int count;

  DailySales({
    required this.date,
    required this.amount,
    required this.count,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: json['date']?.toString() ?? '',
      amount: UserAnalytics._toInt(json['amount']),
      count: UserAnalytics._toInt(json['count']),
    );
  }
}

class TopProductSales {
  final String productId;
  final String productName;
  final String shopName;
  final int quantitySold;
  final int totalRevenue;

  TopProductSales({
    required this.productId,
    required this.productName,
    required this.shopName,
    required this.quantitySold,
    required this.totalRevenue,
  });

  factory TopProductSales.fromJson(Map<String, dynamic> json) {
    return TopProductSales(
      productId: json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? json['product_name']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? json['shop_name']?.toString() ?? '',
      quantitySold: UserAnalytics._toInt(json['quantitySold'] ?? json['quantity_sold']),
      totalRevenue: UserAnalytics._toInt(json['totalRevenue'] ?? json['total_revenue']),
    );
  }
}

class PerformanceMetrics {
  final double avgDailySales;
  final int activeDays;
  final String? peakHour;
  final double completionRate;

  PerformanceMetrics({
    required this.avgDailySales,
    required this.activeDays,
    this.peakHour,
    required this.completionRate,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      avgDailySales: UserAnalytics._toDouble(json['avgDailySales'] ?? json['avg_daily_sales']),
      activeDays: UserAnalytics._toInt(json['activeDays'] ?? json['active_days']),
      peakHour: json['peakHour']?.toString() ?? json['peak_hour']?.toString(),
      completionRate: UserAnalytics._toDouble(json['completionRate'] ?? json['completion_rate']),
    );
  }
}
