class Poi {
  final int objectId;
  final String title;
  final String? description;
  final String? category;
  final String? mail;
  final String? phone;
  final String? website;
  // final DateTime? openingHours;
  final String? openingHours;
  final String? address;
  final String? asset;
  final PoiGeometry geometry;
  final String? routes;

  Poi({
    required this.objectId,
    required this.title,
    this.description,
    this.category,
    this.mail,
    this.phone,
    this.website,
    this.openingHours,
    this.address,
    this.asset,
    required this.geometry,
    required this.routes,
  });

  factory Poi.fromJsonOnline(Map<String, dynamic> json) {
    // print(json['attributes']['openingHours']);
    return Poi(
      objectId: json['attributes']['OBJECTID'],
      title: json['attributes']['naam'],
      description: json['attributes']['beschrijving'],
      category: json['attributes']['categorie'],
      mail: json['attributes']['email'],
      phone: json['attributes']['phone'],
      website: json['attributes']['web'],
      // openingHours:
      //     json['attributes']['openingstijden'] != null
      //         ? DateTime.parse(json['attributes']['openingHours'])
      //         : null,
      openingHours: json['attributes']['openingstijden'],
      address: json['attributes']['adres'],
      asset: json['attributes']['asset'],
      routes: json['attributes']['routes'],
      geometry: PoiGeometry.fromJson(json['geometry']),
    );
  }

    factory Poi.fromJsonLocal(Map<String, dynamic> json) {
    // print(json['attributes']['openingHours']);
    return Poi(
      objectId: json['objectId'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      mail: json['mail'],
      phone: json['phone'],
      website: json['website'],
      // openingHours:
      //     json['attributes']['openingstijden'] != null
      //         ? DateTime.parse(json['attributes']['openingHours'])
      //         : null,
      openingHours: json['openingHours'],
      address: json['address'],
      asset: json['asset'],
      routes: json['routes'],
      geometry: PoiGeometry.fromJson(json['geometry']),
    );
  }

  Map<String, dynamic> toJson() => {
    'objectId': objectId,
    'title': title,
    'description': description,
    'category': category,
    'mail': mail,
    'phone': phone,
    'website': website,
    // 'openingHours': openingHours?.toIso8601String(),
    'address': address,
    'asset': asset,
    'routes': routes,
    'geometry': geometry.toJson(),
  };
}

class PoiGeometry {
  final double? x;
  final double? y;

  PoiGeometry({this.x, this.y});

  factory PoiGeometry.fromJson(Map<String, dynamic> json) {
    return PoiGeometry(x: json['x'], y: json['y']);
  }

  Map<String, dynamic> toJson() => {
    if (x != null) 'x': x,
    if (y != null) 'y': y,
  };
}
