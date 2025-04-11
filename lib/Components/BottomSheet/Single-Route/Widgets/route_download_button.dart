import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/Functions/route_functions.dart';

class RouteDownloadButton extends StatelessWidget {
  final AvailableRoutes currentRoute;
  const RouteDownloadButton({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton.icon(
        onPressed: () async {
          var routeResponse = await getRouteLayerJSON(currentRoute.routeID);

          RouteLayerData routeInfo = filterRouteInfo(
            routeResponse,
            currentRoute,
          );

          var EncodeRoute = jsonEncode(routeInfo.toJson());
          await writeFile(EncodeRoute, '${currentRoute.routeID}.json');
          //LOADING INDICATOR
          Navigator.pop(context, true);
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
