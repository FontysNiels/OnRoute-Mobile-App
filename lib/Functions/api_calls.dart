import 'dart:convert';

import 'package:http/http.dart' as http;

// Get ArcGIS content from specific file
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

// Get ArcGIS data, like title and description, from specific file
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

// Gets all files in a folder
Future<http.Response> getAllFromFolder() async {
  var tokenResponse = await generateToken();
  // var generatedToken = jsonDecode(tokenResponse.body)['token'];
  final response = await http.get(
    Uri.parse(
      // 'https://gisportal.bragis.nl/arcgis/sharing/rest/content/users/bragis_stagiair/c792879e301c4fdd94dcf6cbf4874bc5?f=pjson&token=$routeID',
      // 'https://bragis-def.maps.arcgis.com/sharing/rest/content/users/bragis99/6589f0d7e389471685a90e98029a4fb2?f=pjson&token=$generatedToken',
      'https://bragis-def.maps.arcgis.com/sharing/rest/content/users/bragis99/6589f0d7e389471685a90e98029a4fb2?f=pjson&token=mzFcMRqhxzPAoRJavp2MJlMrYq1jabTz5r9h3SQq0znTBAlU0eCdHmw5qrJ9SsjDCr4Ft0SzLNZvDH0ErfeLClF45YAxUUz9DmbxVdK_odC4HqQL1TS7X4GqiZgekw6ieCimAG-u-NGbfT9rFzA3l_uVcbYW1z-8gadjpo6mFKQ'
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  // print('https://bragis-def.maps.arcgis.com/sharing/rest/content/users/bragis99/6589f0d7e389471685a90e98029a4fb2?f=pjson&token=$generatedToken');
  return response;
}

//
Future<http.Response> getServiceContent(String url) async {
  String madeUrl = "$url/query?where=1%3D1&outFields=*&f=json";
  final response = await http.get(
    Uri.parse(madeUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  return response;
}

//
Future<String> getServiceAssets(String url, int id) async {
  String madeUrl = "$url/$id/attachments/?f=json";

  final response = await http.get(
    Uri.parse(madeUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  var repsonseAttechments = jsonDecode(response.body);
  var attachments = repsonseAttechments['attachmentInfos'][0]['id'];

  String attechmentUrl = "$url/$id/attechments/$attachments";

  return attechmentUrl;
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
