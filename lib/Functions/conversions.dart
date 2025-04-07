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

List convertToLatLng(double x, double y) {
  // Earth's radius in meters for Web Mercator projection
  const double earthRadius = 6378137.0;

  // Convert from Web Mercator (EPSG:3857) coordinates to latitude and longitude
  double lonRad = x / earthRadius;
  double latRad = 2 * atan(exp(y / earthRadius)) - pi / 2;

  // Convert radians to degrees
  double latitude = latRad * 180.0 / pi;
  double longitude = lonRad * 180.0 / pi;

  // Return the latitude and longitude as a LatLng object
  return [latitude, longitude];
}

List convertToLatLngSpecial(double x, double y, int objectid) {
  // Earth's radius in meters for Web Mercator projection
  const double earthRadius = 6378137.0;

  // Convert from Web Mercator (EPSG:3857) coordinates to latitude and longitude
  double lonRad = x / earthRadius;
  double latRad = 2 * atan(exp(y / earthRadius)) - pi / 2;

  // Convert radians to degrees
  double latitude = latRad * 180.0 / pi;
  double longitude = lonRad * 180.0 / pi;

  // Return the latitude and longitude as a LatLng object
  return [latitude, longitude, objectid];
}
