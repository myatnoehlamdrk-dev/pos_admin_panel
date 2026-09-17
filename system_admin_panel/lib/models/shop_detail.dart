import 'shop.dart';

class ShopDetail {
  final Shop shop;
  final ShopAnalytics? analytics;

  ShopDetail({
    required this.shop,
    this.analytics,
  });

  factory ShopDetail.fromJson(Map<String, dynamic> json) {
    return ShopDetail(
      shop: Shop.fromJson(json['shop'] ?? json),
      analytics: json['analytics'] != null
          ? ShopAnalytics.fromJson(json['analytics'])
          : null,
    );
  }
}

class ShopAnalytics {
  final int totalSales;
  final int totalRevenue;
  final double avgSaleValue;
  final int totalProducts;
  final int activeUsers;
  final List<DailyRevenue> revenueChart;
  final List<CategorySales> salesByCategory;
  final List<TopSellingProduct> topProducts;
  final ShopPerformance? performance;

  ShopAnalytics({
    required this.totalSales,
    required this.totalRevenue,
    required this.avgSaleValue,
    required this.totalProducts,
    required this.activeUsers,
    required this.revenueChart,
    required this.salesByCategory,
    required this.topProducts,
    this.performance,
  });

  factory ShopAnalytics.fromJson(Map<String, dynamic> json) {
    return ShopAnalytics(
      totalSales: _toInt(json['totalSales'] ?? json['total_sales']),
      totalRevenue: _toInt(json['totalRevenue'] ?? json['total_revenue']),
      avgSaleValue: _toDouble(json['avgSaleValue'] ?? json['avg_sale_value']),
      totalProducts: _toInt(json['totalProducts'] ?? json['total_products']),
      activeUsers: _toInt(json['activeUsers'] ?? json['active_users']),
      revenueChart: (json['revenueChart'] ?? json['revenue_chart'] as List? ?? [])
          .map((e) => DailyRevenue.fromJson(e))
          .toList(),
      salesByCategory: (json['salesByCategory'] ?? json['sales_by_category'] as List? ?? [])
          .map((e) => CategorySales.fromJson(e))
          .toList(),
      topProducts: (json['topProducts'] ?? json['top_products'] as List? ?? [])
          .map((e) => TopSellingProduct.fromJson(e))
          .toList(),
      performance: json['performance'] != null
          ? ShopPerformance.fromJson(json['performance'])
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

class DailyRevenue {
  final String date;
  final int amount;
  final int count;

  DailyRevenue({
    required this.date,
    required this.amount,
    required this.count,
  });

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      date: json['date']?.toString() ?? '',
      amount: ShopAnalytics._toInt(json['amount']),
      count: ShopAnalytics._toInt(json['count']),
    );
  }
}

class CategorySales {
  final String category;
  final int count;
  final int revenue;

  CategorySales({
    required this.category,
    required this.count,
    required this.revenue,
  });

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    return CategorySales(
      category: json['category']?.toString() ?? '',
      count: ShopAnalytics._toInt(json['count']),
      revenue: ShopAnalytics._toInt(json['revenue']),
    );
  }
}

class TopSellingProduct {
  final String productId;
  final String productName;
  final int quantitySold;
  final int totalRevenue;

  TopSellingProduct({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
  });

  factory TopSellingProduct.fromJson(Map<String, dynamic> json) {
    return TopSellingProduct(
      productId: json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? json['product_name']?.toString() ?? '',
      quantitySold: ShopAnalytics._toInt(json['quantitySold'] ?? json['quantity_sold']),
      totalRevenue: ShopAnalytics._toInt(json['totalRevenue'] ?? json['total_revenue']),
    );
  }
}

class ShopPerformance {
  final double avgDailyRevenue;
  final int activeDays;
  final double growthRate;
  final double customerRetention;

  ShopPerformance({
    required this.avgDailyRevenue,
    required this.activeDays,
    required this.growthRate,
    required this.customerRetention,
  });

  factory ShopPerformance.fromJson(Map<String, dynamic> json) {
    return ShopPerformance(
      avgDailyRevenue: ShopAnalytics._toDouble(json['avgDailyRevenue'] ?? json['avg_daily_revenue']),
      activeDays: ShopAnalytics._toInt(json['activeDays'] ?? json['active_days']),
      growthRate: ShopAnalytics._toDouble(json['growthRate'] ?? json['growth_rate']),
      customerRetention: ShopAnalytics._toDouble(json['customerRetention'] ?? json['customer_retention']),
    );
  }
}
