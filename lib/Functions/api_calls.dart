import 'package:http/http.dart' as http;

Future<http.Response> getRouteData() async {
  // Get Car Id (By License Plate)
  final response = await http.get(
    Uri.parse(
      'https://bragis-def.maps.arcgis.com/sharing/rest/content/items/4f4cea7adeb0463c9ccb4a92d2c62dbf/data',
      // 'https://bragis-def.maps.arcgis.com/sharing/rest/content/items/d7c2638c697d415584c84166e04565b5/data',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Authorization': 'Bearer ${_credentials!.accessToken}',
    },
  );
  return response;
}
