import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Components/BottomSheet/Tabs/Content/tabs_description_block.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/main.dart';

// Fetches local ROUTES ONLY, NO PACKAGES that are already downloaded
Future<List<WebMapCollection>> fetchLocalItems() async {
  List<dynamic> localFilesWithFolders = await getRouteFolders();

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
          thumbnail: routeInfo.titleImage,
          tags: routeInfo.tags,
        ),
      ],
      locally: true,
      title: routeInfo.title,
      description: routeInfo.description,
      thumbnail: routeInfo.thumbnail,
      webmapId: webMapId,
    );
    webMapCollectionList.add(webMapCollection);
  }

  return webMapCollectionList;
}

// Fetches online routes that are not already downloaded
Future<List<WebMapCollection>> fetchOnlineItems(BuildContext context) async {
  // Get all items from the OnRoute folder
  var responseAll = await getAllFromFolder();
  var content = jsonDecode(responseAll.body);
  // Turn it into a list
  List filteredRouteIDs = content['items'];
  List<WebMapCollection> webMapCollectionList = [];
  List<Poi> allPoisList = await getAllPoi(filteredRouteIDs);


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
      thumbnail: webMap['thumbnail'],
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
          title: matchingRoute['title'] ?? layer['title'],
          description: matchingRoute['description'] ?? '...',
          locally: false,
          // thumbnail: matchingRoute['thumbnail'],
          thumbnail: matchingRoute['thumbnail'] ?? '',
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

Future<List<Poi>> getAllPoi(List<dynamic> filteredRouteIDs) async {
  List<Poi> allPoisList = [];
  // ...
  var specificRoute = filteredRouteIDs.firstWhere(
    (route) => route['id'] == poiItemId,
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
  return allPoisList;
}

// Filters the route-JSON so that only the necessary data is returned (mainly used in download function)
Future<RouteLayerData> filterRouteInfo(
  Response routeResponse,
  WebMapCollection layerInfo,
  bool isRouteRefresh,
) async {
  var lastding =
      (jsonDecode(routeResponse.body)['layers'][2]['featureSet']['features']
              as List)
          .last;

  var modifiedResponse = jsonDecode(routeResponse.body);
  modifiedResponse['title'] = layerInfo.availableRoute[0].title;
  modifiedResponse['tags'] = layerInfo.availableRoute[0].tags!;
  modifiedResponse['viewpoint'] = layerInfo.availableRoute[0].viewpoint;

  // Only do this when the route is downloaded or refresh
  if (isRouteRefresh) {
    String description = layerInfo.availableRoute[0].description;

    List<String> parts = stripHtmlTags(
      replaceImageDivs(description),
    ).split('\n');

    int descriptionImageNum = 0;
    List<String> editedList = [];
    for (var part in parts) {
      // Check if the part is a URL by simple pattern matching
      if (part.startsWith('https://') || part.startsWith('http://')) {
        part =
            "IMAGE/${await saveImageFromUrl(part, layerInfo.webmapId + layerInfo.availableRoute[0].routeID + descriptionImageNum.toString(), layerInfo.webmapId)}";
        descriptionImageNum++;
      }
      editedList.add(part);
    }

    modifiedResponse['description'] = editedList.join('\n');
    modifiedResponse['titleImage'] = await saveImageFromUrl(
      layerInfo.availableRoute[0].thumbnail,
      "${layerInfo.webmapId}${layerInfo.availableRoute[0].routeID}thumbnail",
      layerInfo.webmapId,
    );

    modifiedResponse['thumbnail'] = await saveImageFromUrl(
      layerInfo.thumbnail,
      layerInfo.webmapId + layerInfo.availableRoute[0].routeID,
      layerInfo.webmapId,
    );
  }

  // Places all the values (ArcGIS and custom) inside of a RouteLayerData
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
