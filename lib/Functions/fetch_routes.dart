import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';

// Fetches local routes that are already downloaded
Future<List<AvailableRoutes>> fetchLocalItems(List<File> localFiles) async {
  List<AvailableRoutes> availableLocalRoutes = [];

  // Add all the local files to the list
  for (var file in localFiles) {
    var storedFile = jsonDecode(await readRouteFile(file));
    RouteLayerData routeInfo = RouteLayerData.fromJson(storedFile);

    availableLocalRoutes.add(
      AvailableRoutes(
        routeID: file.path,
        title: routeInfo.title,
        description: routeInfo.description,
        locally: true,
      ),
    );
  }

  return availableLocalRoutes;
}

// Fetches online routes that are not already downloaded
Future<List<AvailableRoutes>> fetchOnlineItems(List<File> localFiles) async {
  var responseAll = await getAll();
  var content = jsonDecode(responseAll.body);
  List routeIDs = content['items'];

  // Extract file names from files
  final existingIDs =
      localFiles.map((file) {
        final filename = file.path.split('/').last;
        return filename.split('.').first;
      }).toSet();

  // Filter routeIDs that are not in existingIDs
  final filteredRouteIDs =
      routeIDs.where((id) => !existingIDs.contains(id['id'])).toList();

  List<AvailableRoutes> availableOnlineRoutes = [];

  for (var i = 0; i < filteredRouteIDs.length; i++) {
    // Add info of online route to list
    AvailableRoutes onlineRoute = AvailableRoutes(
      routeID: filteredRouteIDs[i]['id'],
      title: filteredRouteIDs[i]['title'],
      description: filteredRouteIDs[i]['description'] ?? '...',
      locally: false,
    );
    availableOnlineRoutes.add(onlineRoute);
  }

  return availableOnlineRoutes;
}

// Filters the route-JSON so that only the necessary data is returned
RouteLayerData filterRouteInfo(
  Response routeResponse,
  AvailableRoutes layerInfo,
) {
  var lastding =
      (jsonDecode(routeResponse.body)['layers'][2]['featureSet']['features']
              as List)
          .last;

  var modifiedResponse = jsonDecode(routeResponse.body);
  modifiedResponse['title'] = layerInfo.title;
  modifiedResponse['description'] = layerInfo.description;

  RouteLayerData routeInfo = RouteLayerData.fromJson(
    (modifiedResponse
        ..['layers'][2]['featureSet']['features'] =
            (modifiedResponse['layers'][2]['featureSet']['features'] as List)
                .where((feature) => feature['attributes']['Azimuth'] != 0.0)
                .toList())
      ..['layers'][2]['featureSet']['features'].add(lastding),
  );
  return routeInfo;
}
