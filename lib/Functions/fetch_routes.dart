import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';
import 'package:onroute_app/Classes/TESTCLASS.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';

// Fetches local routes that are already downloaded
Future<List<WebMapCollection>> fetchLocalItems(List<File> localFiles) async {
  // WebMapCollection

  List<dynamic> localFilesWithFolders = await getRouteFolders();

  List<File> localFiles =
      localFilesWithFolders
          .whereType<Map<String, dynamic>>()
          .expand((package) => package['package']['files'])
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .where((file) => file.path.contains('route-'))
          .toList();

  // print(localFiles);

  List<WebMapCollection> webMapCollectionList = [];
  // Add all the local files to the list
  for (var file in localFiles) {
    var storedFile = jsonDecode(await readRouteFile(file));
    RouteLayerData routeInfo = RouteLayerData.fromJson(storedFile);
    var webMapId = file.path.split('/')[file.path.split('/').length - 2];

    WebMapCollection webMapCollection = WebMapCollection(
      pointsOfInterest: [],
      availableRoute: [
        AvailableRoutes(
          routeID: file.path,
          title: routeInfo.title,
          description: routeInfo.description,
          locally: true,
        ),
      ],
      locally: true,
      title: routeInfo.title,
      description: routeInfo.description,
      webmapId: webMapId,
    );
    webMapCollectionList.add(webMapCollection);
  }

  return webMapCollectionList;
}

// TODO: Rewrite this, so it gets WebMaps, goes trhough the layers and gets the routes and POIs seperatly (maybe make different functions for getting the actial route info, but idk yet)
// Fetches online routes that are not already downloaded
Future<List<WebMapCollection>> fetchOnlineItems(List<File> localFiles) async {
  var responseAll = await getAllFromFolder();
  var content = jsonDecode(responseAll.body);
  // List routeIDs = content['items'];
  //temp
  List filteredRouteIDs = content['items'];

  //TODO: remake filter already downloaded routes, for new format

  // // Extract file names from files
  // final existingIDs =
  //     localFiles.map((file) {
  //       final filename = file.path.split('/').last;
  //       return filename.split('.').first;
  //     }).toSet();

  // // Filter routeIDs that are not in existingIDs
  // final filteredRouteIDs =
  //     routeIDs.where((id) => !existingIDs.contains(id['id'])).toList();

  // List<AvailableRoutes> availableOnlineRoutes = [];
  List<WebMapCollection> webMapCollectionList = [];

  for (var i = 0; i < filteredRouteIDs.length; i++) {
    WebMapCollection webMapCollection = WebMapCollection(
      pointsOfInterest: [],
      availableRoute: [],
      locally: false,
      title: '',
      description: '',
      webmapId: '',
    );
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Get Web Map collection
    if (filteredRouteIDs[i]['type'] == 'Web Map') {
      var publishedRoute = await getRouteLayerJSON(filteredRouteIDs[i]['id']);
      var responseBodyPublished =
          jsonDecode(publishedRoute.body)['operationalLayers'];
      webMapCollection.title = filteredRouteIDs[i]['title'];
      webMapCollection.webmapId = filteredRouteIDs[i]['id'];
      webMapCollection.description =
          filteredRouteIDs[i]['description'] ?? '...';
      // Loop through all the layers
      for (var element in responseBodyPublished) {
        // Get POIs (feature-layer)
        if (element['url'] != null &&
            element['url'].isNotEmpty &&
            element['title'] != "puntenlaag test") {
          var poiResponse = await getServiceContent(element['url']);
          var poiResponseBody = jsonDecode(poiResponse.body)['features'];
          List<Poi> featureLayerPois = [];
          // create POIs per feature-layer
          for (var poi in poiResponseBody) {
            var image = await getServiceAssets(
              element['url'],
              poi['attributes']['OBJECTID'],
            );
            poi['attributes']['asset'] = image;

            Poi parsedPoi = Poi.fromJson(poi);
            featureLayerPois.add(parsedPoi);
          }
          webMapCollection.pointsOfInterest.addAll(featureLayerPois);
        }
        // GET ROUTE
        else if (element["featureCollectionType"] == "route") {
          AvailableRoutes onlineRoute = AvailableRoutes(
            routeID: element['itemId'],
            title: element['title'],
            description:
                filteredRouteIDs
                    .where((route) => route['id'] == element['itemId'])
                    .first['description'] ??
                '...',
            locally: false,
          );
          webMapCollection.availableRoute.add(onlineRoute);
        }
      }
      // print(webMapCollection.toJson());
      webMapCollectionList.add(webMapCollection);
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Add info of online route to list
    // if (filteredRouteIDs[i]['type'] != 'Feature Collection') {
    //   continue;
    // }
    // // print(filteredRouteIDs[i]);
    // AvailableRoutes onlineRoute = AvailableRoutes(
    //   routeID: filteredRouteIDs[i]['id'],
    //   title: filteredRouteIDs[i]['title'],
    //   description: filteredRouteIDs[i]['description'] ?? '...',
    //   locally: false,
    // );
    // availableOnlineRoutes.add(onlineRoute);
  }

  // return availableOnlineRoutes;
  return webMapCollectionList;
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
