import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/file_storage.dart';

class RouteStartButton extends StatelessWidget {
  final AvailableRoutes routeContent;
  final Function startRoute;
  const RouteStartButton({
    super.key,
    required this.routeContent,
    required this.startRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: FilledButton.icon(
        onPressed: () async {
          var storedFile = jsonDecode(await readRouteFile(File(routeContent.routeID)));
          RouteLayerData routeInfo = RouteLayerData.fromJson(storedFile);
          startRoute(routeInfo);
          // await addGraphics(routeContent.routeLayer);
        },
        icon: const Icon(Icons.directions),
        label: Text(
          'Start Route',
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: Colors.white),
        ),
        iconAlignment: IconAlignment.start,
      ),
    );
  }
}
