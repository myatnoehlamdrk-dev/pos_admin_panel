class Shop {
  final String id;
  final String shopName;
  final String? shopType;
  final String? shopImage;
  final String? shopPhysicalAddress;
  final String? ownerName;
  final String? ownerEmail;
  final String? ownerPhone;
  final bool isActive;
  final int usersCount;
  final int? salesCount;
  final int? totalRevenue;
  final String? createdAt;

  Shop({
    required this.id,
    required this.shopName,
    this.shopType,
    this.shopImage,
    this.shopPhysicalAddress,
    this.ownerName,
    this.ownerEmail,
    this.ownerPhone,
    required this.isActive,
    this.usersCount = 0,
    this.salesCount,
    this.totalRevenue,
    this.createdAt,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is double) return v.toInt();
    return 0;
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id']?.toString() ?? '',
      shopName: json['shopName'] ?? json['name'] ?? '',
      shopType: json['shopType'] ?? json['type'],
      shopImage: json['shopImage'] ?? json['logoUrl'],
      shopPhysicalAddress: json['shopPhysicalAddress'] ?? json['physicalAddress'],
      ownerName: json['ownerName'] ?? json['ownerInformation']?['name'],
      ownerEmail: json['ownerEmail'] ?? json['ownerInformation']?['email'],
      ownerPhone: json['ownerPhone'] ?? json['ownerInformation']?['phone'],
      isActive: json['isActive'] ?? false,
      usersCount: _toInt(json['usersCount']),
      salesCount: json['salesCount'] != null ? _toInt(json['salesCount']) : null,
      totalRevenue: json['totalRevenue'] != null ? _toInt(json['totalRevenue']) : null,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
