import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/TESTCLASS.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/Functions/fetch_routes.dart';
import 'package:onroute_app/main.dart';

class RouteDownloadButton extends StatelessWidget {
  final WebMapCollection currentRoute;
  final Function setSheetWidget;

  const RouteDownloadButton({
    super.key,
    required this.currentRoute,
    required this.setSheetWidget,
  });

  @override
  Widget build(BuildContext context) {
    // print(currentRoute.pointsOfInterest);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton.icon(
        onPressed: () async {
          // Get ArcGIS route layer data JSON
          var routeResponse = await getRouteLayerJSON(
            currentRoute.availableRoute[0].routeID,
          );

          // Clean it up
          RouteLayerData routeInfo = filterRouteInfo(
            routeResponse,
            currentRoute.availableRoute[0],
          );

          Map<String, dynamic> allPoiJSON = {'points': []};
          for (Poi point in currentRoute.pointsOfInterest) {
            var poiAsJSON = point.toJson();
            (allPoiJSON['points'] as List).add(poiAsJSON);
          }

          var encodePoi = jsonEncode(allPoiJSON);
          await writeFile(
            encodePoi,
            'pois-${currentRoute.webmapId}.json',
            currentRoute.webmapId,
          );

          //
          var folderContent = await getRouteFolders();
          if (folderContent.isEmpty) {
            var encodeRoute = jsonEncode(routeInfo.toJson());
            await writeFile(
              encodeRoute,
              'route-${currentRoute.availableRoute[0].routeID}.json',
              currentRoute.webmapId,
            );
          } else {
            // TODO: iets van check toevoegen of de route al bestaat in een folder
            var encodeRoute = jsonEncode(routeInfo.toJson());
            await writeFile(
              encodeRoute,
              'route-${currentRoute.availableRoute[0].routeID}.json',
              currentRoute.webmapId,
            );
          }
          // Loop through folders and check if the route already exists
          for (var element in folderContent) {
            // print(
            //   'Route: ${element['package']['files'].where((e) => e.path.contains(currentRoute.availableRoute[0].routeID) == true)}',
            // );
            // if (element['package']['files']
            //     .where(
            //       (e) =>
            //           e.path.contains(currentRoute.availableRoute[0].routeID) ==
            //           true,
            //     )
            //     .isNotEmpty) {
            //   //true naar false zetten voor niet opnieuw downloaden
            //   print("BESTAAT AL IN EEN MAP!!");
            //   var encodeRoute = jsonEncode(routeInfo.toJson());
            //   await writeFile(
            //     encodeRoute,
            //     'route-${currentRoute.availableRoute[0].routeID}.json',
            //     currentRoute.webmapId,
            //   );
            // }
          }

          // var encodeRoute = jsonEncode(routeInfo.toJson());
          // await writeFile(
          //   encodeRoute,
          //   'route-${currentRoute.availableRoute[0].routeID}.json',
          //   currentRoute.webmapId,
          // );

          //LOADING INDICATOR
          // updateSavedRoutes(context);
          await moveSheetTo(0.5);

          await setSheetWidget(null, true);
        },
        icon: const Icon(Icons.download),
        label: Text(
          'Download route',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        iconAlignment: IconAlignment.start,
      ),
    );
  }
}
