import 'dart:math';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/description_point.dart';
import 'package:onroute_app/Functions/math.dart';

class DirectionsCard extends StatefulWidget {
  const DirectionsCard({
    super.key,
    required List<DescriptionPoint> directionsList,
    required ArcGISMapViewController mapViewController,
  }) : _directionsList = directionsList,
       _mapViewController = mapViewController;

  final List<DescriptionPoint> _directionsList;
  final ArcGISMapViewController _mapViewController;

  @override
  State<DirectionsCard> createState() => _DirectionsCardState();
}

class _DirectionsCardState extends State<DirectionsCard> {
  int metersToNextDirection = 0;
  // Maak een functie die check of de user bij de start weg loopt
  int i = 1;

  @override
  Widget build(BuildContext context) {
    widget._mapViewController.locationDisplay.onLocationChanged.listen((mode) {
      if (widget._directionsList.isNotEmpty) {
        // Calculate the distance between the user's current position and the direction's coordinates
        final userPosition =
            widget._mapViewController.locationDisplay.location!.position;
        final directionXY = convertToLatLng(
          widget._directionsList[i].x,
          widget._directionsList[i].y,
        );
        final directionX = directionXY[1];
        final directionY = directionXY[0];

        // print('direction X: ${directionX} direction Y ${directionY}');
        // print('User X: ${userPosition.x} User Y ${userPosition.y}');

        final distance = sqrt(
          pow(userPosition.y - directionY, 2) +
              pow(userPosition.x - directionX, 2),
        );

        // Define a threshold distance (e.g., 10 meters)
        const thresholdDistance =
            0.0001; // Approx. 10 meters in lat/long degrees

        const metersPerDegree = 111320; // Approximation for latitude
        final distanceInMeters = distance * metersPerDegree;

        // Print the distance in meters
        // print(
        //   'Distance to next point: ${distanceInMeters.toStringAsFixed(2)} meters',
        // );

        // Update distance to nect direction
        setState(() {
          metersToNextDirection = distanceInMeters.toInt();
        });

        // MAKE IT SO IT CHECK IF WALKING AWAY (_mapViewController.locationDisplay.location!.course)
        // If distance to next direction < 10m next direction
        if (distance < thresholdDistance) {
          print("User has passed the current direction's coordinates.");
          // Move to the next direction if available
          if (i < widget._directionsList.length - 1) {
            setState(() {
              i++;
            });
          }
        }
      }
    });

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/temp.png',
                  height: 56,
                  width: 56,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    widget._directionsList.isNotEmpty
                        ? widget._directionsList[i].description
                        : "NIKS",
                  ),
                ),
              ),
              // Text('$metersToNextDirection Meter'),
              Text('${metersToNextDirection} m'),
            ],
          ),
        ),
      ),
    );
  }
}
