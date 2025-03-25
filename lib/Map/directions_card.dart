import 'dart:math';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/description_point.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/math.dart';

class DirectionsCard extends StatefulWidget {
  const DirectionsCard({
    super.key,
    required RouteLayerData routeInfo,
    required List<DescriptionPoint> directionsList,
    required ArcGISMapViewController mapViewController,
  }) : _directionsList = directionsList,
       _routeInfo = routeInfo,
       _mapViewController = mapViewController;

  final List<DescriptionPoint> _directionsList;
  final ArcGISMapViewController _mapViewController;
  final RouteLayerData _routeInfo;

  @override
  State<DirectionsCard> createState() => _DirectionsCardState();
}

class _DirectionsCardState extends State<DirectionsCard> {
  int metersToNextDirection = 0;
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

        // Distance between the user and the next point
        final directionXYnext = convertToLatLng(
          widget._directionsList[i + 1].x,
          widget._directionsList[i + 1].y,
        );
        final directionXnext = directionXYnext[1];
        final directionYnext = directionXYnext[0];

        final distanceNext = sqrt(
          pow(userPosition.y - directionYnext, 2) +
              pow(userPosition.x - directionXnext, 2),
        );

        final distanceInMeterToNext = distanceNext * metersPerDegree;

        // Distance between the current and next point
        final distanceBetweenPoints =
            widget
                ._routeInfo
                .layers[1]
                .featureSet
                .features[i - 1]
                .attributes['Meters']
                .toInt();
        // print("points distance: $distanceBetweenPoints");
        // print('nect distance $distanceInMeterToNext');
        // print('current distance $distanceInMeters');

        // MAKE IT SO IT CHECK IF WALKING AWAY (_mapViewController.locationDisplay.location!.course)
        if (distance < thresholdDistance) {
          if (i < widget._directionsList.length - 1) {
            print("User has passed the current direction's coordinates.");
            setState(() {
              i++;
              skipNextCheck = true; // Skip the next check
              // ^ uit setstate zetten?
            });
          }
        } else if (!skipNextCheck) {
          // if user walks away from point and is getting closer to next point
          if (metersToNextDirection < distanceInMeters.toInt() &&
              distanceBetweenPoints > distanceInMeterToNext &&
              metersToNextDirection != 0) {
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
        // IDK OF DAT WERKT, WANT DELAYED DAN (maybe een if > distanceInMeters meer dan 50 ofzo)

        // Update distance to nect direction
        setState(() {
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
