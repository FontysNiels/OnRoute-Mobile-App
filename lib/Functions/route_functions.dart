import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';

// Filters the route-JSON so that only the necessary data is returned
RouteLayerData filterRouteInfo(Response routeResponse, layerInfo) {
  var lastding =
      (jsonDecode(routeResponse.body)['layers'][2]['featureSet']['features']
              as List)
          .last;

  var modifiedResponse = jsonDecode(routeResponse.body);
  modifiedResponse['title'] = layerInfo['title'];
  modifiedResponse['description'] = layerInfo['description'];

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

// Fetches local routes that are already downloaded
Future<List<AvailableRoutes>> fetchLocalItems(List<File> localFiles) async {
  List<AvailableRoutes> availableLocalRoutes = [];

  // Add all the local files to the list
  for (var file in localFiles) {
    var storedFile = jsonDecode(await readRouteFile(file));
    RouteLayerData routeInfo = RouteLayerData.fromJson(storedFile);

    availableLocalRoutes.add(
      AvailableRoutes(routeID: file.path, locally: true, routeLayer: routeInfo),
    );
  }

  return availableLocalRoutes;
}

// Fetches online routes that are not already downloaded
Future<List<AvailableRoutes>> fetchOnlineItems(List<File> localFiles) async {
  // List of all files on device
  // TEMP list of routeIDs
  List routeIDs = [
    '4f4cea7adeb0463c9ccb4a92d2c62dbf',
    'd7c2638c697d415584c84166e04565b5',
    'c79d6d7746d145deaf842bd7602f70b4',
  ];

  // Extract file names from files
  final existingIDs =
      localFiles.map((file) {
        final filename = file.path.split('/').last;
        return filename.split('.').first;
      }).toSet();

  // Filter routeIDs that are not in existingIDs
  final filteredRouteIDs =
      routeIDs.where((id) => !existingIDs.contains(id)).toList();

  List<AvailableRoutes> availableOnlineRoutes = [];

  for (var i = 0; i < filteredRouteIDs.length; i++) {
    // Get route info (title, description) based on routeID
    var response = await getRouteInfo(filteredRouteIDs[i]);
    var layerInfo = jsonDecode(response.body);
    var routeResponse = await getRouteData(layerInfo['id']);

    RouteLayerData routeInfo = filterRouteInfo(routeResponse, layerInfo);

    // Add info of online route to list
    AvailableRoutes onlineRoute = AvailableRoutes(
      routeID: layerInfo['id'],
      locally: false,
      routeLayer: routeInfo,
    );
    availableOnlineRoutes.add(onlineRoute);
  }

  // var routes = await fetchLocalItems(localFiles);
  // if (routes.isNotEmpty) {
  //   allAvailableRoutes.addAll(routes);
  // }

  return availableOnlineRoutes;
}
