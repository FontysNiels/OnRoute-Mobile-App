import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/TESTCLASS.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/file_storage.dart';

class RouteStartButton extends StatelessWidget {
  final WebMapCollection routeContent;
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
          var storedFile = jsonDecode(await readFile(File(routeContent.availableRoute[0].routeID)));
          RouteLayerData routeInfo = RouteLayerData.fromJson(storedFile);
          startRoute(routeInfo, routeContent.pointsOfInterest);
          // await addGraphics(routeContent.routeLayer);
          Navigator.pop(context, false);
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
