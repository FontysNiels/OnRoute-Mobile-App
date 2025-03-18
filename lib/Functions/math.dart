import 'dart:math';

import 'package:arcgis_maps/arcgis_maps.dart';

ArcGISPoint convertToArcGISPoint(double latitude, double longitude) {
  // Earth's radius in meters for Web Mercator projection
  const double earthRadius = 6378137.0;

  // Convert latitude and longitude to radians
  double latRad = latitude * pi / 180.0;
  double lonRad = longitude * pi / 180.0;

  // Convert to Web Mercator (EPSG:3857) coordinates
  double x = earthRadius * lonRad;
  double y = earthRadius * log(tan(pi / 4 + latRad / 2));

  // Create and return the ArcGISPoint
  return ArcGISPoint(
    x: x,
    y: y,
    spatialReference: SpatialReference.webMercator,
  );
}
