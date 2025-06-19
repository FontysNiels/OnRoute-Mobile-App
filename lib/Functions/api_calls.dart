import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Get ArcGIS content from specific file
Future<http.Response> getArcgisItemData(String routeID) async {
  // Get or Generate token
  var tokenResponse = await _handleToken();
  // Make call
  final response = await http
      .get(
        Uri.parse(
          'https://bragis-def.maps.arcgis.com/sharing/rest/content/items/$routeID/data?f=json&token=$tokenResponse',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      )
      .catchError((e) {
        return http.Response(
          jsonEncode({
            'error': 'An exception occurred',
            'details': e.toString(),
          }),
          500,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );
      });
  
  // Return the response
  return response;
}

// Get ArcGIS data, like title and description, from specific file
// Momenteel (28/04) niet in gebruik, doordat titel en description ook in de getall zitten
Future<http.Response> getArcgisItemInfo(String routeID) async {
  // Get or Generate token
  var tokenResponse = await _handleToken();
  // Make call
  final response = await http.get(
    Uri.parse(
      'https://bragis-def.maps.arcgis.com/sharing/rest/content/items/$routeID/?f=json&token=$tokenResponse',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  // Return the response
  return response;
}

// Gets all files in a folder
Future<http.Response> getAllFromFolder() async {
  // Get or Generate token
  var tokenResponse = await _handleToken();
  // Make call
  final response = await http
      .get(
        Uri.parse(
          // Enterprise URL
          // 'https://gisportal.bragis.nl/arcgis/sharing/rest/content/users/bragis_stagiair/c792879e301c4fdd94dcf6cbf4874bc5?f=pjson&token=$routeID',
          'https://bragis-def.maps.arcgis.com/sharing/rest/content/users/bragis99/6589f0d7e389471685a90e98029a4fb2?f=pjson&token=$tokenResponse',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      )
      .catchError((e) {
        return http.Response(
          jsonEncode({
            'error': 'An exception occurred',
            'details': e.toString(),
          }),
          500,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );
      });

  if (response.statusCode == 200) {
    // Temporarily decode the response to modify the thumbnail URLs
    var tempDecodedResponse = jsonDecode(response.body);
    for (var item in tempDecodedResponse['items']) {
      if (item['thumbnail'] != null) {
        item['thumbnail'] =
            "https://bragis-def.maps.arcgis.com/sharing/rest/content/items/${item['id']}/info/${item['thumbnail']}?token=$tokenResponse";
      }
    }
    // Encode the modified response back to JSON
    var enresponse = jsonEncode(tempDecodedResponse);
    // Return the modified response
    return http.Response(
      enresponse,
      response.statusCode,
      headers: response.headers,
    );
  } else {
    // Return the original response if status code is not 200
    return response;
  }
}

// Gets POI data from service
Future<http.Response> getServiceContent(String url) async {
  // Get or Generate token
  var tokenResponse = await _handleToken();
  // Make call
  try {
    final response = await http.get(
      Uri.parse(
        "$url/query?where=1%3D1&outFields=*&f=json&token=$tokenResponse",
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  } catch (e) {
    return http.Response(
      jsonEncode({'error': 'An exception occurred', 'details': e.toString()}),
      500,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
  }
  // Return the response
}

//
Future<String> getServiceAssets(String url, int id) async {
  // Get or Generate token
  var tokenResponse = await _handleToken();
  // Make call to get attachments
  final response = await http.get(
    Uri.parse("$url/$id/attachments/?f=json&token=$tokenResponse"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  // Decode the response
  var repsonseAttechments = jsonDecode(response.body);
  // Check if there are attachments
  if (repsonseAttechments['attachmentInfos'].isEmpty) {
    return '';
  }
  // Get the attachment ID
  var attachments = repsonseAttechments['attachmentInfos'][0]['id'];
  // Use id to generate the attachment URL
  String attechmentUrl =
      "$url/$id/attechments/$attachments?token=$tokenResponse";
  // Return the attachment URL
  return attechmentUrl;
}

Future<String> generateToken() async {
  // Local Storage initialize
  final prefs = await SharedPreferences.getInstance();
  // Current time
  DateTime timenow = DateTime.now();
  // Generate a new token
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://bpwa.eu/appmobile/gettoken.php'),
  );
  request.fields['name'] = 'apptest';
  request.fields['pass'] = 'dOOrnhOEk#823';
  // 0 = Online, 1 = Enterprise
  request.fields['server'] = '0';

  // Send the request
  var streamedResponse = await request.send();
  // Check if the request was successful
  var response = await http.Response.fromStream(streamedResponse);
  // Check the status code of the response
  if (response.statusCode == 200) {
    // If the response is successful, save the token and time to local storage
    await prefs.setString('API_TOKEN', jsonDecode(response.body)['token']);
    await prefs.setString('TOKEN_DATE', timenow.toString());
    // Return the token
    return jsonDecode(response.body)['token'];
  } else {
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
