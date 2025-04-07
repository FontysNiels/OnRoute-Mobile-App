import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Functions/file_storage.dart';

class RouteDownloadButton extends StatelessWidget {
  final AvailableRoutes routeID;
  const RouteDownloadButton({super.key, required this.routeID});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton.icon(
        onPressed: () async {
          var EncodeRoute = jsonEncode(routeID.routeLayer.toJson());
          await writeFile(EncodeRoute, '${routeID.routeID}.json');
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
