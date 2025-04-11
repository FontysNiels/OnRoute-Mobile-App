import 'dart:convert';

import 'package:http/http.dart' as http;

Future<http.Response> getRouteLayerJSON(String routeID) async {
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

Future<http.Response> getAll() async {
  var tokenResponse = await generateToken();
  var generatedToken = jsonDecode(tokenResponse.body)['token'];
  final response = await http.get(
    Uri.parse(
      // 'https://gisportal.bragis.nl/arcgis/sharing/rest/content/users/bragis_stagiair/c792879e301c4fdd94dcf6cbf4874bc5?f=pjson&token=$routeID',
      'https://bragis-def.maps.arcgis.com/sharing/rest/content/users/bragis99/6589f0d7e389471685a90e98029a4fb2?f=pjson&token=$generatedToken',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  return response;
}

Future<http.Response> generateToken() async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://bpwa.eu/appmobile/gettoken.php'),
  );
  request.fields['name'] = 'apptest';
  request.fields['pass'] = 'dOOrnhOEk#823';
  request.fields['server'] = '0';

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    // print('Success: ${response.body}');
    return response;
  } else {
    // print('Failed with status: ${response.statusCode}');
    return response;
  }
}


// Future<http.Response> postRequest() async {
//   var url = Uri.parse('https://bpwa.eu/appmobile/gettoken.php');

//   var request = http.MultipartRequest('POST', url);
//   request.fields['name'] = 'apptest';
//   request.fields['pass'] = 'dOOrnhOEk#823';
//   request.fields['server'] = '0';

//   try {
//     var streamedResponse = await request.send();
//     var response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode == 200) {
//       print('Success: ${response.body}');
//       var rest = await getAll(jsonDecode(response.body)['token']);
//       print(jsonDecode(rest.body));
//       return response;
//     } else {
//       print('Failed with status: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error: $e');
//   }

//   return http.post(
//     Uri.parse('https://bpwa.eu/appmobile/gettoken.php'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//       // 'Authorization': 'Bearer ${credentials.accessToken}',
//     },
//     body: jsonEncode(<String, String>{
//       'name': '',
//       'pass': '',
//       'server': "user",
//     }),
//   );
// }