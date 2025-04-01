import 'package:http/http.dart' as http;

Future<http.Response> getRouteData(String routeID) async {
  // Get Car Id (By License Plate)
  final response = await http.get(
    Uri.parse(
      'https://bragis-def.maps.arcgis.com/sharing/rest/content/items/$routeID/data',
      // 'https://bragis-def.maps.arcgis.com/sharing/rest/content/items/d7c2638c697d415584c84166e04565b5/data',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Authorization': 'Bearer ${_credentials!.accessToken}',
    },
  );
  return response;
}

Future<http.Response> getRouteInfo(String routeID) async {
  final response = await http.get(
    Uri.parse(
      'https://bragis-def.maps.arcgis.com/sharing/rest/content/items/$routeID/?f=json',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  return response;
}
