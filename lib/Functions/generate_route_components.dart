import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
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
