import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/main.dart';

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
            startRoute(routeContent.routeLayer);
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
