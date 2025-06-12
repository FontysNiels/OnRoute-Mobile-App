import 'dart:convert';
import 'dart:io';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/single_route.dart';
import 'package:onroute_app/Components/BottomSheet/Widgets/no_internet_dialog.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/fetch_routes.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/Functions/generate_route_components.dart';
import 'package:onroute_app/main.dart';

class RoutePreviewButton extends StatelessWidget {
  const RoutePreviewButton({super.key, required this.widget});

  final SingleRoute widget;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        if (widget.routeContent.locally) {
          // Read the local route file
          var storedFile = jsonDecode(
            await readFile(
              File(widget.routeContent.availableRoute[0].routeID),
            ),
          );
          // Turn it into RouteLayerData
          RouteLayerData routeInfo = RouteLayerData.fromJson(storedFile);
          // Set the viewpoint
          mapViewController.setViewpoint(
            Viewpoint.fromJson(routeInfo.viewpoint),
          );
          // Add the generated Route lines
          graphicsOverlay.graphics.addAll(
            await generateLinesAndPoints(routeInfo),
          );
          // Add the generated POI points
          graphicsOverlay.graphics.addAll(
            await generatePoiGraphics(widget.routeContent.pointsOfInterest),
          );
          // Enable the preview overlay
          preview();
        } else {
          final List<ConnectivityResult> connectivityResult =
              await (Connectivity().checkConnectivity());
          if (connectivityResult.contains(ConnectivityResult.none)) {
            noInternetDialog(context);
          } else {
            //  set viewpoint to the viewpoint
            mapViewController.setViewpoint(
              Viewpoint.fromJson(widget.routeContent.viewpoint),
            );
            // get route-layer JSON
            var routeResponse = await getArcgisItemData(
              widget.routeContent.availableRoute[0].routeID,
            );
            // Clean it up
            RouteLayerData routeInfo = await filterRouteInfo(
              routeResponse,
              widget.routeContent,
              false,
            );
            // Add the generated POI points
            graphicsOverlay.graphics.addAll(
              await generatePoiGraphics(widget.routeContent.pointsOfInterest),
            );
            // create Lines
            graphicsOverlay.graphics.addAll(
              await generateLinesAndPoints(routeInfo),
            );
            // Enable the preview overlay
            preview();
          }
        }
      },
      icon: const Icon(Icons.map),
      label: Text(
        'Route Bekijken',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      iconAlignment: IconAlignment.start,
    );
  }
}
