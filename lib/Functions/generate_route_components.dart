import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/main.dart';

// Generates graphics for the start and finish points of a route
Future<List<Graphic>> generatePointGraphics(RouteLayerData routeInfo) async {
  List<Graphic> graphics = [];

  // Load the image once and reuse the symbol
  final finish = await ArcGISImage.fromAsset('assets/finish.png');
  final start = await ArcGISImage.fromAsset('assets/start.png');

  for (var element in routeInfo.layers[2].featureSet.features) {
    // Only add graphics for the first and last element
    int index = routeInfo.layers[2].featureSet.features.indexOf(element);

    if ((index == 0 ||
            index == routeInfo.layers[2].featureSet.features.length - 1) &&
        element.geometry.x != null &&
        element.geometry.y != null) {
      // Flag to determine if the point is start or finish
      final pictureMarker =
          PictureMarkerSymbol.withImage(index == 0 ? start : finish)
            ..width = 35
            ..height = 35
            ..offsetY = 17.5;
      // Position of the marker
      final parsedX = element.geometry.x!;
      final parsedY = element.geometry.y!;

      final startPoint = ArcGISPoint(
        x: parsedX,
        y: parsedY,
        spatialReference: SpatialReference.webMercator,
      );

      // Create graphic with picture marker symbol instead of blue dot
      final graphic = Graphic(geometry: startPoint, symbol: pictureMarker);
      graphic.zIndex = 100;
      graphics.add(graphic);
    }
  }
  // Return a list of graphics for the start and finish points.
  return graphics;
}

// Generates graphics for POIs along the route
Future<List<Graphic>> generatePoiGraphics(List<Poi> routeInfo) async {
  List<Graphic> graphics = [];
  final image = await ArcGISImage.fromAsset('assets/pin_circle_red.png');
  final pictureMarkerSymbol =
      PictureMarkerSymbol.withImage(image)
        ..width = 35
        ..height = 35
        ..offsetY = 17.5;
  // Loop through each POI in the routeInfo
  for (var element in routeInfo) {
    if (element.geometry.x != null) {
      final parsedX = element.geometry.x;
      final parsedY = element.geometry.y;

      final startPoint = ArcGISPoint(
        x: parsedX!,
        y: parsedY!,
        spatialReference: SpatialReference.webMercator,
      );
      // Create a graphic for the POI with the picture marker symbol
      Graphic poiPoint = Graphic(
        geometry: startPoint,
        // symbol: routeStartCircleSymbol,
        symbol: pictureMarkerSymbol,
        attributes: {'objectId': element.objectId},
      );
      poiPoint.zIndex = 80;
      graphics.add(poiPoint);
    }
  }
  // Return a list of graphics for each POI.
  return graphics;
}

// Generates graphics for lines and points of a route
Future<List<Graphic>> generateLinesAndPoints(RouteLayerData routeID) async {
  // List that will be returned
  List<Graphic> graphics = [];
  // Generate Lines
  for (var element in routeID.layers[1].featureSet.features) {
    late final SimpleLineSymbol polylineSymbol = SimpleLineSymbol(
      style: SimpleLineSymbolStyle.solid,
      color: primaryAppColor,
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
