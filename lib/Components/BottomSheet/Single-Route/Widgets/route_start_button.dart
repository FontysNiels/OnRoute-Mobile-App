import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Components/BottomSheet/TripContent/trip_info_bar.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/main.dart';

class RouteStartButton extends StatelessWidget {
  final WebMapCollection routeContent;
  final Function startRoute;
  final Function setSheetWidget;
  final ScrollController scroller;

  const RouteStartButton({
    super.key,
    required this.routeContent,
    required this.startRoute,
    required this.setSheetWidget,
    required this.scroller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: FilledButton.icon(
        onPressed: () async {
          var storedFile = jsonDecode(
            await readFile(File(routeContent.availableRoute[0].routeID)),
          );
          RouteLayerData routeInfo = RouteLayerData.fromJson(storedFile);
          startRoute(routeInfo, routeContent.pointsOfInterest);

          addMMPK();
          setSheetWidget(
            TripContent(
              key: UniqueKey(),
              scroller: scroller,
              routeContent: routeContent,
              setSheetWidget: setSheetWidget,
            ),
            false,
          );
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
