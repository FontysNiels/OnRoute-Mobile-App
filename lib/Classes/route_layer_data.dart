class RouteLayerData {
  final List<Layer> layers;
  final List<int> visibleLayers;
  final String title;
  final String description;
  final String thumbnail;
  final String titleImage;
  final List<String> tags;
  dynamic viewpoint;

  RouteLayerData({
    required this.layers,
    required this.visibleLayers,
    required this.title,
    required this.thumbnail,
    required this.titleImage,
    required this.description,
    required this.tags,
    required this.viewpoint,
  });

  factory RouteLayerData.fromJson(Map<String, dynamic> json) {
    return RouteLayerData(
      layers:
          (json['layers'] as List)
              .map((layer) => Layer.fromJson(layer))
              .toList(),
      visibleLayers: List<int>.from(json['visibleLayers']),
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      titleImage: json['titleImage'],
      tags:
          (json['tags'] as List<dynamic>).map((tag) => tag.toString()).toList(),
      viewpoint: json['viewpoint'],
    );
  }

  Map<String, dynamic> toJson() => {
    'layers': layers.map((layer) => layer.toJson()).toList(),
    'visibleLayers': visibleLayers,
    'title': title,
    'thumbnail': thumbnail,
    'titleImage': titleImage,
    'description': description,
    'tags': tags,
    'viewpoint': viewpoint,
  };
}

class Layer {
  final FeatureSet featureSet;
  Layer({required this.featureSet});

  factory Layer.fromJson(Map<String, dynamic> json) {
    return Layer(
      featureSet: FeatureSet.fromJson(json['featureSet']),
    );
  }
  Map<String, dynamic> toJson() => {'featureSet': featureSet.toJson()};
}

class FeatureSet {
  final List<RouteFeature> features;
  final String geometryType;
  final RouteSpatialReference spatialReference;

  FeatureSet({
    required this.features,
    required this.geometryType,
    required this.spatialReference,
  });

  factory FeatureSet.fromJson(Map<String, dynamic> json) {
    return FeatureSet(
      features:
          (json['features'] as List)
              .map((feature) => RouteFeature.fromJson(feature))
              .toList(),
      geometryType: json['geometryType'],
      spatialReference: RouteSpatialReference.fromJson(
        json['spatialReference'],
      ),
    );
  }
  Map<String, dynamic> toJson() => {
    'features': features.map((f) => f.toJson()).toList(),
    'geometryType': geometryType,
    'spatialReference': spatialReference.toJson(),
  };
}

class RouteFeature {
  final Map<String, dynamic> attributes;
  final RouteGeometry geometry;
  final Symbol? symbol;

  RouteFeature({
    required this.attributes,
    required this.geometry,
    this.symbol,
  });

  factory RouteFeature.fromJson(Map<String, dynamic> json) {
    return RouteFeature(
      attributes: Map<String, dynamic>.from(json['attributes']),
      geometry: RouteGeometry.fromJson(json['geometry']),
      symbol: json['symbol'] != null ? Symbol.fromJson(json['symbol']) : null,
    );
  }
  Map<String, dynamic> toJson() => {
    'attributes': attributes,
    'geometry': geometry.toJson(),
    if (symbol != null) 'symbol': symbol!.toJson(),
  };
}

class RouteGeometry {
  final RouteSpatialReference spatialReference;
  final List<dynamic>? paths;
  final double? x;
  final double? y;

  RouteGeometry({required this.spatialReference, this.paths, this.x, this.y});

  factory RouteGeometry.fromJson(Map<String, dynamic> json) {
    return RouteGeometry(
      spatialReference: RouteSpatialReference.fromJson(
        json['spatialReference'],
      ),
      paths: json['paths'],
      x: json['x'],
      y: json['y'],
    );
  }
  Map<String, dynamic> toJson() => {
    'spatialReference': spatialReference.toJson(),
    if (paths != null) 'paths': paths,
    if (x != null) 'x': x,
    if (y != null) 'y': y,
  };
}

class RouteSpatialReference {
  final int latestWkid;
  final int wkid;

  RouteSpatialReference({required this.latestWkid, required this.wkid});
  @override
  String toString() {
    return '{"latestWkid": $latestWkid, "wkid": $wkid}';
  }

  factory RouteSpatialReference.fromJson(Map<String, dynamic> json) {
    return RouteSpatialReference(
      latestWkid: json['latestWkid'],
      wkid: json['wkid'],
    );
  }
  Map<String, dynamic> toJson() => {'latestWkid': latestWkid, 'wkid': wkid};
}

class Symbol {
  final String type;
  final List<int>? color;
  final int? size;
  final int? width;
  final String? style;

  Symbol({required this.type, this.color, this.size, this.width, this.style});

  factory Symbol.fromJson(Map<String, dynamic> json) {
    return Symbol(
      type: json['type'],
      color: json['color'] != null ? List<int>.from(json['color']) : null,
      size: json['size'],
      width: json['width'],
      style: json['style'],
    );
  }
  Map<String, dynamic> toJson() => {
    'type': type,
    if (color != null) 'color': color,
    if (size != null) 'size': size,
    if (width != null) 'width': width,
    if (style != null) 'style': style,
  };
}