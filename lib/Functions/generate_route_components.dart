import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/main.dart';

Future<List<Graphic>> generatePointGraphics(RouteLayerData routeInfo) async {
  List<Graphic> graphics = [];

  // Load the image once and reuse the symbol
  final image = await ArcGISImage.fromAsset('assets/finish.png');
  final pictureMarkerSymbol =
      PictureMarkerSymbol.withImage(image)
        ..width = 35
        ..height = 35
        ..offsetY = 17.5; // half the height

  for (var element in routeInfo.layers[2].featureSet.features) {
    // Only add graphics for the first and last element
    int index = routeInfo.layers[2].featureSet.features.indexOf(element);
    if ((index == 0 ||
            index == routeInfo.layers[2].featureSet.features.length - 1) &&
        element.geometry.x != null &&
        element.geometry.y != null) {
      final parsedX = element.geometry.x!;
      final parsedY = element.geometry.y!;

      final startPoint = ArcGISPoint(
        x: parsedX,
        y: parsedY,
        spatialReference: SpatialReference.webMercator,
      );

      // Create graphic with picture marker symbol instead of blue dot
      final graphic = Graphic(
        geometry: startPoint,
        symbol: pictureMarkerSymbol,
      );

      graphics.add(graphic);
    }
  }

  return graphics;
}

Future<List<Graphic>> generatePoiGraphics(List<Poi> routeInfo) async {
  List<Graphic> graphics = [];
  final image = await ArcGISImage.fromAsset('assets/pin_circle_red.png');
  final pictureMarkerSymbol =
      PictureMarkerSymbol.withImage(image)
        ..width = 35
        ..height = 35
        ..offsetY = 17.5; // half the height
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
          // symbol: routeStartCircleSymbol,
          symbol: pictureMarkerSymbol,
          attributes: {'objectId': element.objectId},
        ),
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
  List<Graphic> pointGraphics = await generatePointGraphics(routeID);
  for (var i = 0; i < pointGraphics.length; i++) {
    graphics.addAll([pointGraphics[i]]);
  }

  // Return a list of graphics for each geometry type.
  return graphics;
}
