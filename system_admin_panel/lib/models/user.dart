class User {
  final String id;
  final String fullName;
  final String email;
  final String shopId;
  final String? type;
  final String? phone;
  final String? social;
  final String? image;
  final String? imageDeleteUrl;
  final String? role;
  final String? address;
  final String? status;
  final String? nrcNo;
  final String? billingWay;
  final String? dateOfBirth;
  final String? gender;
  final bool activeStatus;
  final bool isVerified;
  final ShopInfo? shop;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.shopId,
    this.type,
    this.phone,
    this.social,
    this.image,
    this.imageDeleteUrl,
    this.role,
    this.address,
    this.status,
    this.nrcNo,
    this.billingWay,
    this.dateOfBirth,
    this.gender,
    required this.activeStatus,
    required this.isVerified,
    this.shop,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      shopId: json['shopId']?.toString() ?? '',
      type: json['type']?.toString(),
      phone: json['phone']?.toString(),
      social: json['social']?.toString(),
      image: json['image']?.toString(),
      imageDeleteUrl: json['imageDeleteUrl']?.toString(),
      role: json['role']?.toString(),
      address: json['address']?.toString(),
      status: json['status']?.toString(),
      nrcNo: json['nrcNo']?.toString(),
      billingWay: json['billingWay']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      gender: json['gender']?.toString(),
      activeStatus: _toBool(json['activeStatus']),
      isVerified: _toBool(json['isVerified']),
      shop: json['shop'] != null ? ShopInfo.fromJson(json['shop']) : null,
    );
  }

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return false;
  }
}

class ShopInfo {
  final String id;
  final String shopName;
  final String? shopType;
  final String? shopImage;

  ShopInfo({
    required this.id,
    required this.shopName,
    this.shopType,
    this.shopImage,
  });

  factory ShopInfo.fromJson(Map<String, dynamic> json) {
    return ShopInfo(
      id: json['id']?.toString() ?? '',
      shopName: json['shopName'] ?? json['name'] ?? '',
      shopType: json['shopType'] ?? json['type'],
      shopImage: json['shopImage'] ?? json['logoUrl'],
    );
  }
}
