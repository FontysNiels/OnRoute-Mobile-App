import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Get ArcGIS content from specific file
Future<http.Response> getArcgisItemData(String routeID) async {
  final response = await http.get(
    Uri.parse(
      'https://bragis-def.maps.arcgis.com/sharing/rest/content/items/$routeID/data?f=json',
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
// Momenteel (28/04) niet in gebruik, doordat titel en description ook in de getall zitten
Future<http.Response> getArcgisItemInfo(String routeID) async {
  print('object');
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
  var tokenResponse = await _handleToken();
  final response = await http.get(
    Uri.parse(
      // 'https://gisportal.bragis.nl/arcgis/sharing/rest/content/users/bragis_stagiair/c792879e301c4fdd94dcf6cbf4874bc5?f=pjson&token=$routeID',
      'https://bragis-def.maps.arcgis.com/sharing/rest/content/users/bragis99/6589f0d7e389471685a90e98029a4fb2?f=pjson&token=$tokenResponse',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  var tempDecodedResponse = jsonDecode(response.body);
  for (var item in tempDecodedResponse['items']) {
    if (item['thumbnail'] != null) {
      item['thumbnail'] =
          "https://bragis-def.maps.arcgis.com/sharing/rest/content/items/${item['id']}/info/${item['thumbnail']}?token=$tokenResponse";
    }
  }
  var enresponse = jsonEncode(tempDecodedResponse);
  // print('https://bragis-def.maps.arcgis.com/sharing/rest/content/users/bragis99/6589f0d7e389471685a90e98029a4fb2?f=pjson&token=$generatedToken');
  return http.Response(
    enresponse,
    response.statusCode,
    headers: response.headers,
  );
  // return response;
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

  if (repsonseAttechments['attachmentInfos'].isEmpty) {
    return '';
  }
  var attachments = repsonseAttechments['attachmentInfos'][0]['id'];

  String attechmentUrl = "$url/$id/attechments/$attachments";

  return attechmentUrl;
}

Future<String> generateToken() async {
  final prefs = await SharedPreferences.getInstance();
  DateTime timenow = DateTime.now();

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
    await prefs.setString('API_TOKEN', jsonDecode(response.body)['token']);
    await prefs.setString('TOKEN_DATE', timenow.toString());

    return jsonDecode(response.body)['token'];
  } else {
    // print('Failed with status: ${response.statusCode}');
    return jsonDecode(response.body)['token'];
  }
}

Future<String> _handleToken() async {
  // Local Storage initialize
  final prefs = await SharedPreferences.getInstance();
  // Current time
  DateTime timeNow = DateTime.now();
  // Set API_TOKEN if it isn't set yet
  if (prefs.getString('API_TOKEN') == null) {
    return await generateToken();
  } else {
    // Convert TOKEN_DATE back to DateTime
    DateTime tokenDate = DateTime.parse(prefs.getString('TOKEN_DATE')!);
    // Check if it's set in the last 12 hours, if not generate again
    if (timeNow.difference(tokenDate).inHours < 12) {
      return prefs.getString('API_TOKEN')!;
    } else {
      return await generateToken();
    }
  }
}
