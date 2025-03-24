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
  // int metersToNextDirectionOld = 0;
  // Maak een functie die check of de user bij de start weg loopt
  int i = 1;
  bool skipNextCheck = false;

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

        // MAKE IT SO IT CHECK IF WALKING AWAY (_mapViewController.locationDisplay.location!.course)
        if (distance < thresholdDistance) {
          // Move to the next direction if available
          if (i < widget._directionsList.length - 1) {
            print("User has passed the current direction's coordinates.");
            setState(() {
              i++;
              // metersToNextDirection = distanceInMeters.toInt();
              skipNextCheck = true; // Skip the next check
              // ^ uit setstate zetten?
            });
          }
        } else if (!skipNextCheck) {
          // if user walks away from point
          if (metersToNextDirection < distanceInMeters.toInt() &&
              metersToNextDirection != 0) {
            // checken of het verschil groter is dan 5-10 meter
            if (i < widget._directionsList.length - 1) {
              i++;
              print(
                "${widget._directionsList[i].description} : Significant decrease in distance detected.",
              );
            }
          }
        } else {
          skipNextCheck = false; // Reset the flag after skipping
        }

        // DEZE IN DE UITLOOPCHECK ZETTEN, ALS HET BLIJFT UITLOPEN ZAL HIJ DIE OLD UPDATEN EN DUS IS EEN MINIMAAL LASTIG TE ZETTEN
        // DUS ALLEEN OLD AANPASSEN ALS HET NIET WEGLOOPT (ALS IK EEN MARGIN WIL HEBBEN VAN EEN BEPAALDE AFSTAND)
        // Update distance to nect direction
        setState(() {
          // metersToNextDirectionOld = metersToNextDirection;
          metersToNextDirection = distanceInMeters.toInt();
        });
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
