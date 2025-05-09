import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';

// Fetches local ROUTES ONLY, NO PACKAGES that are already downloaded
Future<List<WebMapCollection>> fetchLocalItems(List<File> localFiles) async {
  List<dynamic> localFilesWithFolders = await getRouteFolders();

  // TODO: make it so when a package is downlaoded it doesnt show the package, but all the seperate routes.
  // Possibly already doing so....

  List<File> localRouteFiles =
      localFilesWithFolders
          .whereType<Map<String, dynamic>>()
          .expand((package) => package['package']['files'])
          .whereType<File>()
          .where((file) => file.path.contains('route-'))
          .where((file) => file.path.endsWith('.json'))
          .toList();

  List<WebMapCollection> webMapCollectionList = [];
  // Add all the local files to the list
  for (var file in localRouteFiles) {
    var storedFile = jsonDecode(await readFile(file));
    RouteLayerData routeInfo = RouteLayerData.fromJson(storedFile);
    var webMapId = file.path.split('/')[file.path.split('/').length - 2];
    var poiPath = file.path.replaceAll(
      RegExp(r'route-[a-f0-9]{32}\.json$'),
      'pois-$webMapId.json',
    );

    var poiJSON = jsonDecode(await readFile(File(poiPath)));
    List<Poi> featureLayerPois = [];
    for (var element in poiJSON['points']) {
      featureLayerPois.add(Poi.fromJsonLocal(element));
    }

    WebMapCollection webMapCollection = WebMapCollection(
      pointsOfInterest: featureLayerPois,
      availableRoute: [
        AvailableRoutes(
          routeID: file.path,
          title: routeInfo.title,
          description: routeInfo.description,
          locally: true,
          thumbnail: routeInfo.thumbnail,
          tags: routeInfo.tags,
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

// Fetches online routes that are not already downloaded
Future<List<WebMapCollection>> fetchOnlineItems(
  List<File> localFiles,
  BuildContext context,
) async {
  // Get all items from the OnRoute folder
  var responseAll = await getAllFromFolder();
  var content = jsonDecode(responseAll.body);
  // Turn it into a list
  List filteredRouteIDs = content['items'];

  //TODO: (IDFK what I meant with this) it now always gets and converts the routes, even if they are already downloaded
  // denk dat hij alles ophaalt, en dan alsnog de data bekijkt (zoals titel enzo) (ookal als die offline beschikbaaar is)

  List<WebMapCollection> webMapCollectionList = [];

  // Create and fill a list with all the POIs (from 1 POI file)
  List<Poi> allPoisList = [];
  await getAllPoi(filteredRouteIDs, allPoisList);

  // Fill the list of WebMapCollections
  for (var webMap in filteredRouteIDs.where((r) => r['type'] == 'Web Map')) {
    // Get data from Web Map
    var publishedRoute = await getArcgisItemData(webMap['id']);
    var responseBodyPublished =
        jsonDecode(publishedRoute.body)['operationalLayers'];

    // Create the WebMapCollection, and set the already available values
    WebMapCollection webMapCollection = WebMapCollection(
      pointsOfInterest: [],
      availableRoute: [],
      locally: false,
      title: webMap['title'],
      description: webMap['description'] ?? '...',
      webmapId: webMap['id'],
      viewpoint: jsonDecode(publishedRoute.body)['initialState']['viewpoint'],
    );

    // Loop through the layers of the webmap to find the route(s)
    for (var layer in responseBodyPublished.where(
      (l) => l["featureCollectionType"] == "route",
    )) {
      // Looks at all the POIs and the routes they are linked to
      var matchingPois =
          allPoisList
              .where((poi) => poi.routes?.contains(layer['itemId']) ?? false)
              .toList();
      // Add the linked POIs
      webMapCollection.pointsOfInterest.addAll(matchingPois);

      // Checks if the route is the same as the one from the OnRoute Folder
      var matchingRoute = filteredRouteIDs.firstWhere(
        (r) => r['id'] == layer['itemId'],
      );

      // Add the data into the route (matchingRoute, is the info from the OnRoute folder since that contains more info)
      webMapCollection.availableRoute.add(
        AvailableRoutes(
          routeID: layer['itemId'],
          title: layer['title'],
          description: matchingRoute['description'] ?? '...',
          locally: false,
          // thumbnail: matchingRoute['thumbnail'],
          thumbnail:
              '${webMap['thumbnail']}--ONROUTE--${matchingRoute['thumbnail']}',
          tags:
              (matchingRoute['tags'] as List<dynamic>)
                  .map((tag) => tag.toString())
                  .toList(),
          viewpoint: webMapCollection.viewpoint,
        ),
      );
    }
    // Add the WebMapCollection to the list
    webMapCollectionList.add(webMapCollection);
  }
  return webMapCollectionList;
}

Future<void> getAllPoi(
  List<dynamic> filteredRouteIDs,
  List<Poi> allPoisList,
) async {
  // TODO: make this work for any poi bestand
  // ID omdat momenteel er meerdere bestaan (is TEMP)
  var specificRoute = filteredRouteIDs.firstWhere(
    (route) => route['id'] == '1c049e864f1643bda530ae45fd1591cf',
    orElse: () => null,
  );

  if (specificRoute != null &&
      specificRoute['url'] != null &&
      specificRoute['type'] == "Feature Service") {
    var poiResponse = await getServiceContent('${specificRoute['url']}/0');
    var poiResponseBody = jsonDecode(poiResponse.body)['features'];

    // create POIs per feature-layer
    for (var poi in poiResponseBody) {
      var image = await getServiceAssets(
        '${specificRoute['url']}/0',
        poi['attributes']['OBJECTID'],
      );
      poi['attributes']['asset'] = image;

      Poi parsedPoi = Poi.fromJsonOnline(poi);
      allPoisList.add(parsedPoi);
    }
  }
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
  modifiedResponse['thumbnail'] = layerInfo.thumbnail;
  modifiedResponse['tags'] = layerInfo.tags!;
  modifiedResponse['viewpoint'] = layerInfo.viewpoint;

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
