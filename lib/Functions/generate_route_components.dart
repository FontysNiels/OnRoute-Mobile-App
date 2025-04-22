import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';

List<Graphic> generatePointGraphics(RouteLayerData routeInfo) {
  List<Graphic> graphics = [];
  for (var element in routeInfo.layers[2].featureSet.features) {
    if (element.geometry.x != null) {
      final parsedX = element.geometry.x;
      final parsedY = element.geometry.y;

      final startPoint = ArcGISPoint(
        x: parsedX!,
        y: parsedY!,
        spatialReference: SpatialReference.webMercator,
      );

      final routeStartCircleSymbol = SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: Colors.blue,
        size: 15.0,
      );

      graphics.add(
        Graphic(geometry: startPoint, symbol: routeStartCircleSymbol),
      );
    }
  }
  return graphics;
}

List<Graphic> generatePoiGraphics(List<Poi> routeInfo) {
  List<Graphic> graphics = [];
  for (var element in routeInfo) {
    if (element.geometry.x != null) {
      final parsedX = element.geometry.x;
      final parsedY = element.geometry.y;

      final startPoint = ArcGISPoint(
        x: parsedX!,
        y: parsedY!,
        spatialReference: SpatialReference.webMercator,
      );

      final routeStartCircleSymbol = SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: const Color.fromARGB(255, 255, 0, 0),
        size: 20.0,
      );

      graphics.add(
        Graphic(
          geometry: startPoint,
          symbol: routeStartCircleSymbol,
          attributes: element.toJson(),
        ), // Add attributes to the graphic
      );
    }
  }
  return graphics;
}

Future<List<Graphic>> generateLinesAndPoints(RouteLayerData routeID) async {
  // Generate Lines
  List<Graphic> graphics = [];
  for (var element in routeID.layers[1].featureSet.features) {
    late final SimpleLineSymbol polylineSymbol = SimpleLineSymbol(
      style: SimpleLineSymbolStyle.solid,
      color: Color(
        (0xFF000000 + (0x00FFFFFF * (element.hashCode % 1000) / 1000)).toInt(),
      ).withOpacity(1.0),
      width: 4,
    );

    final polylineJson = '''
            {"paths": ${element.geometry.paths},
            "spatialReference":${element.geometry.spatialReference.toString()}}''';

    final routePart = Geometry.fromJsonString(polylineJson);
    graphics.add(Graphic(geometry: routePart, symbol: polylineSymbol));
  }

  // Generate Points
  List<Graphic> pointGraphics = generatePointGraphics(routeID);
  for (var i = 0; i < pointGraphics.length; i++) {
    graphics.addAll([pointGraphics[i]]);
  }

  // Return a list of graphics for each geometry type.
  return graphics;
}
