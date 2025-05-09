import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/Functions/fetch_routes.dart';

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
    // print(currentRoute.availableRoute);
    currentRoute.availableRoute[0];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: FilledButton.icon(
        onPressed: () async {
          context.loaderOverlay.show();
          // Get ArcGIS route layer data JSON
          var routeResponse = await getArcgisItemData(
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

          var folderContent = await getRouteFolders();
          if (folderContent.isEmpty) {
            var encodeRoute = jsonEncode(routeInfo.toJson());

            await writeFile(
              encodeRoute,
              'route-${currentRoute.availableRoute[0].routeID}.json',
              currentRoute.webmapId,
            );

            var encodePoi = jsonEncode(allPoiJSON);
            await writeFile(
              encodePoi,
              'pois-${currentRoute.webmapId}.json',
              currentRoute.webmapId,
            );
          } else {
            // TODO: iets van check toevoegen of de route al bestaat in een folder (voor als er een route 2x gebruikt wordt of package)
            var encodeRoute = jsonEncode(routeInfo.toJson());
            await writeFile(
              encodeRoute,
              'route-${currentRoute.availableRoute[0].routeID}.json',
              currentRoute.webmapId,
            );

            var encodePoi = jsonEncode(allPoiJSON);
            await writeFile(
              encodePoi,
              'pois-${currentRoute.webmapId}.json',
              currentRoute.webmapId,
            );
          }
          // Loop through folders and check if the route already exists
          // for (var element in folderContent) {
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
          // }

          // var encodeRoute = jsonEncode(routeInfo.toJson());
          // await writeFile(
          //   encodeRoute,
          //   'route-${currentRoute.availableRoute[0].routeID}.json',
          //   currentRoute.webmapId,
          // );

          for (var poi in currentRoute.pointsOfInterest) {
            if (poi.asset != '') {
              final imageProvider = CachedNetworkImageProvider(poi.asset!);
              await precacheImage(imageProvider, context);
            }
          }
          context.loaderOverlay.hide();
          //LOADING INDICATOR
          await moveSheetTo(0.5);

          await setSheetWidget(null, true);
        },
        icon: const Icon(Icons.download),
        label: Text(
          'Download route',
          style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white),
        ),
        iconAlignment: IconAlignment.start,
      ),
    );
  }
}
