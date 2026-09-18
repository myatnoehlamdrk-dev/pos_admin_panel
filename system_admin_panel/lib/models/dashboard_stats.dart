class DashboardStats {
  final int totalShops;
  final int activeShops;
  final int totalUsers;
  final int pendingApprovals;
  final int totalProducts;
  final int totalSales;
  final int totalRevenue;
  final int todaySalesCount;
  final int todayRevenue;
  final int monthSalesCount;
  final int monthRevenue;

  DashboardStats({
    required this.totalShops,
    required this.activeShops,
    required this.totalUsers,
    required this.pendingApprovals,
    required this.totalProducts,
    required this.totalSales,
    required this.totalRevenue,
    required this.todaySalesCount,
    required this.todayRevenue,
    required this.monthSalesCount,
    required this.monthRevenue,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is double) return v.toInt();
    return 0;
  }

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalShops: _toInt(json['total_shops']),
      activeShops: _toInt(json['active_shops']),
      totalUsers: _toInt(json['total_users']),
      pendingApprovals: _toInt(json['pending_approvals']),
      totalProducts: _toInt(json['total_products']),
      totalSales: _toInt(json['total_sales']),
      totalRevenue: _toInt(json['total_revenue']),
      todaySalesCount: _toInt(json['today_sales_count']),
      todayRevenue: _toInt(json['today_revenue']),
      monthSalesCount: _toInt(json['month_sales_count']),
      monthRevenue: _toInt(json['month_revenue']),
    );
  }
}

class SalesChartData {
  final String date;
  final int count;
  final int total;

  SalesChartData({
    required this.date,
    required this.count,
    required this.total,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is double) return v.toInt();
    return 0;
  }

  factory SalesChartData.fromJson(Map<String, dynamic> json) {
    return SalesChartData(
      date: json['date']?.toString() ?? '',
      count: _toInt(json['count']),
      total: _toInt(json['total']),
    );
  }
}

class TopProduct {
  final String productName;
  final String? productImage;
  final String shopName;
  final int unitPrice;
  final int totalQuantity;
  final int totalRevenue;
  final int stock;

  TopProduct({
    required this.productName,
    this.productImage,
    required this.shopName,
    required this.unitPrice,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.stock,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is double) return v.toInt();
    return 0;
  }

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productName: json['product_name']?.toString() ?? '',
      productImage: json['product_image']?.toString(),
      shopName: json['shop_name']?.toString() ?? '',
      unitPrice: _toInt(json['unit_price']),
      totalQuantity: _toInt(json['total_quantity']),
      totalRevenue: _toInt(json['total_revenue']),
      stock: _toInt(json['stock']),
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int currentPage;
  final int lastPage;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });
}
