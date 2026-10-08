/// A worker in the shop.
class StaffMember {
  final String name;
  final String role;
  final String phone;

  const StaffMember({this.name = '', this.role = '', this.phone = ''});

  Map<String, dynamic> toJson() => {'name': name, 'role': role, 'phone': phone};

  factory StaffMember.fromJson(Map<String, dynamic> j) => StaffMember(
    name: j['name'] as String? ?? '',
    role: j['role'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
  );
}

/// A service the shop offers with its price.
class ServiceItem {
  final String name;
  final int price;

  const ServiceItem({this.name = '', this.price = 0});

  Map<String, dynamic> toJson() => {'name': name, 'price': price};

  factory ServiceItem.fromJson(Map<String, dynamic> j) => ServiceItem(
    name: j['name'] as String? ?? '',
    price: (j['price'] as num?)?.toInt() ?? 0,
  );
}

/// Everything about the shop: owner, name, contact, location, logo,
/// staff, services and the measurement fields the shop uses.
class ShopProfile {
  final String ownerName;
  final String shopName;
  final String phone;
  final String address;
  final String logoPath;
  final double? lat;
  final double? lng;
  final List<StaffMember> staff;
  final List<ServiceItem> services;
  final List<String> measurementFields;

  const ShopProfile({
    this.ownerName = '',
    this.shopName = '',
    this.phone = '',
    this.address = '',
    this.logoPath = '',
    this.lat,
    this.lng,
    this.staff = const [],
    this.services = const [],
    this.measurementFields = const [],
  });

  static const ShopProfile empty = ShopProfile();

  bool get hasLocation => lat != null && lng != null;

  /// A link that opens the shop in Google Maps.
  String get mapsUrl {
    if (hasLocation) return 'https://www.google.com/maps?q=$lat,$lng';
    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
  }

  ShopProfile copyWith({
    String? ownerName,
    String? shopName,
    String? phone,
    String? address,
    String? logoPath,
    double? lat,
    double? lng,
    List<StaffMember>? staff,
    List<ServiceItem>? services,
    List<String>? measurementFields,
  }) {
    return ShopProfile(
      ownerName: ownerName ?? this.ownerName,
      shopName: shopName ?? this.shopName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      logoPath: logoPath ?? this.logoPath,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      staff: staff ?? this.staff,
      services: services ?? this.services,
      measurementFields: measurementFields ?? this.measurementFields,
    );
  }

  Map<String, dynamic> toJson() => {
    'ownerName': ownerName,
    'shopName': shopName,
    'phone': phone,
    'address': address,
    'logoPath': logoPath,
    'lat': lat,
    'lng': lng,
    'staff': staff.map((s) => s.toJson()).toList(),
    'services': services.map((s) => s.toJson()).toList(),
    'measurementFields': measurementFields,
  };

  factory ShopProfile.fromJson(Map<String, dynamic> j) => ShopProfile(
    ownerName: j['ownerName'] as String? ?? '',
    shopName: j['shopName'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
    address: j['address'] as String? ?? '',
    logoPath: j['logoPath'] as String? ?? '',
    lat: (j['lat'] as num?)?.toDouble(),
    lng: (j['lng'] as num?)?.toDouble(),
    staff: ((j['staff'] as List?) ?? const [])
        .map((e) => StaffMember.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    services: ((j['services'] as List?) ?? const [])
        .map((e) => ServiceItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    measurementFields: ((j['measurementFields'] as List?) ?? const [])
        .cast<String>(),
  );
}
