class RouteLayerData {
  // final double opacity;
  // final bool visibility;
  final List<Layer> layers;
  final List<int> visibleLayers;
  final String title;
  final String description;
  final String thumbnail;

  RouteLayerData({
    // required this.opacity,
    // required this.visibility,
    required this.layers,
    required this.visibleLayers,
    required this.title,
    required this.thumbnail,
    required this.description,
  });

  factory RouteLayerData.fromJson(Map<String, dynamic> json) {
    return RouteLayerData(
      // opacity: json['opacity'],
      // visibility: json['visibility'],
      layers:
          (json['layers'] as List)
              .map((layer) => Layer.fromJson(layer))
              .toList(),
      visibleLayers: List<int>.from(json['visibleLayers']),
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() => {
    'layers': layers.map((layer) => layer.toJson()).toList(),
    'visibleLayers': visibleLayers,
    'title': title,
    'thumbnail': thumbnail,
    'description': description,
  };
}

class Layer {
  final FeatureSet featureSet;
  // final LayerDefinition layerDefinition;

  // Layer({required this.featureSet, required this.layerDefinition});
  Layer({required this.featureSet});

  factory Layer.fromJson(Map<String, dynamic> json) {
    return Layer(
      featureSet: FeatureSet.fromJson(json['featureSet']),
      // layerDefinition: LayerDefinition.fromJson(json['layerDefinition']),
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
  // final String? displayText;

  RouteFeature({
    required this.attributes,
    required this.geometry,
    this.symbol,
    // this.displayText,
  });

  factory RouteFeature.fromJson(Map<String, dynamic> json) {
    return RouteFeature(
      attributes: Map<String, dynamic>.from(json['attributes']),
      geometry: RouteGeometry.fromJson(json['geometry']),
      symbol: json['symbol'] != null ? Symbol.fromJson(json['symbol']) : null,
      // displayText: json['displayText'],
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

// class LayerDefinition {
//   final String capabilities;
//   final DrawingInfo drawingInfo;
//   final Extent extent;
//   final List<Field> fields;
//   final String geometryType;
//   final String name;

//   LayerDefinition({
//     required this.capabilities,
//     required this.drawingInfo,
//     required this.extent,
//     required this.fields,
//     required this.geometryType,
//     required this.name,
//   });

//   factory LayerDefinition.fromJson(Map<String, dynamic> json) {
//     return LayerDefinition(
//       capabilities: json['capabilities'],
//       drawingInfo: DrawingInfo.fromJson(json['drawingInfo']),
//       extent: Extent.fromJson(json['extent']),
//       fields:
//           (json['fields'] as List)
//               .map((field) => Field.fromJson(field))
//               .toList(),
//       geometryType: json['geometryType'],
//       name: json['name'],
//     );
//   }
// }

// class DrawingInfo {
//   final Renderer renderer;

//   DrawingInfo({required this.renderer});

//   factory DrawingInfo.fromJson(Map<String, dynamic> json) {
//     return DrawingInfo(renderer: Renderer.fromJson(json['renderer']));
//   }
// }

// class Renderer {
//   final String type;
//   final Symbol symbol;

//   Renderer({required this.type, required this.symbol});

//   factory Renderer.fromJson(Map<String, dynamic> json) {
//     return Renderer(
//       type: json['type'],
//       symbol: Symbol.fromJson(json['symbol']),
//     );
//   }
// }

// class Extent {
//   final SpatialReference spatialReference;
//   final double xmin;
//   final double ymin;
//   final double xmax;
//   final double ymax;

//   Extent({
//     required this.spatialReference,
//     required this.xmin,
//     required this.ymin,
//     required this.xmax,
//     required this.ymax,
//   });

//   factory Extent.fromJson(Map<String, dynamic> json) {
//     return Extent(
//       spatialReference: SpatialReference.fromJson(json['spatialReference']),
//       xmin: json['xmin'],
//       ymin: json['ymin'],
//       xmax: json['xmax'],
//       ymax: json['ymax'],
//     );
//   }
// }

// class Field {
//   final String name;
//   final String alias;
//   final String type;

//   Field({required this.name, required this.alias, required this.type});

//   factory Field.fromJson(Map<String, dynamic> json) {
//     return Field(name: json['name'], alias: json['alias'], type: json['type']);
//   }
// }
