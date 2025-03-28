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
  int metersToCurrentDirection = 0;
  int descriptionNum = 0;
  int amountOfDirections = 0;
  bool skipNextCheck = false;
  late final List<DescriptionPoint> directionList;

  @override
  void initState() {
    // TODO: implement initState
    amountOfDirections = widget._directionsList.length;
    directionList = [];
    for (var i = 0; i < amountOfDirections; i++) {
      // _directionsList.add(widget._directionsList[i]);
      if (i > 0) {
        if (i == 1) {
          directionList.add(widget._directionsList[i]);
        } else if (widget._directionsList[i].x ==
                widget._directionsList[i - 1].x &&
            widget._directionsList[i].y == widget._directionsList[i - 1].y) {
          directionList.add(widget._directionsList[i - 1]);
        } else {
          directionList.add(widget._directionsList[i]);
        }
      }
    }
    super.initState();

    widget._mapViewController.locationDisplay.onLocationChanged.listen((mode) {
      // check that checks if user is facing a point and moving towards it?

      if (widget._directionsList.isNotEmpty) {
        // Calculate the distance between the user's current position and the direction's coordinates
        final userPosition =
            widget._mapViewController.locationDisplay.location!.position;

        final directionPointXY = convertToLatLng(
          directionList[descriptionNum].x,
          directionList[descriptionNum].y,
        );
        final directionPointX = directionPointXY[1];
        final directionPointY = directionPointXY[0];

        final distanceToDirectionPoint = sqrt(
          pow(userPosition.y - directionPointY, 2) +
              pow(userPosition.x - directionPointX, 2),
        );

        // Define a threshold distance (e.g., 10 meters)
        // Approx. 10 meters in lat/long degrees
        const thresholdDistance = 0.0001;
        const metersPerDegree = 111320; // Approximation for latitude
        final distanceInMeters = distanceToDirectionPoint * metersPerDegree;

        // Create a list of descriptions and distances
        List<Map<String, dynamic>> descriptionDistanceList = [];
        for (int index = 0; index < directionList.length; index++) {
          final point = directionList[index];
          final pointXY = convertToLatLng(point.x, point.y);
          final pointX = pointXY[1];
          final pointY = pointXY[0];

          final distanceToPoint = sqrt(
            pow(userPosition.y - pointY, 2) + pow(userPosition.x - pointX, 2),
          );

          final distanceInMetersToPoint = distanceToPoint * metersPerDegree;

          int distanceBetweenPoints = 0;
          // Get distance between points
          final matchingFeatures = widget
              ._routeInfo
              .layers[1]
              .featureSet
              .features
              .where(
                (feature) =>
                    feature.attributes['DirectionPointID'] == (index + 1),
              );

          // Set distance between points
          if (matchingFeatures.isNotEmpty) {
            distanceBetweenPoints =
                matchingFeatures.first.attributes['Meters'].toInt();
          }
          descriptionDistanceList.add({
            'userDistanceFromPoint': distanceInMetersToPoint.toInt(),
            'distanceBetweenPoints': distanceBetweenPoints,
          });
        }

        // MAKE IT SO IT CHECK IF WALKING AWAY (_mapViewController.locationDisplay.location!.course)
        if (distanceToDirectionPoint < thresholdDistance) {
          if (descriptionNum < amountOfDirections - 1) {
            print("User has passed the current direction's coordinates.");
            setState(() {
              descriptionNum++;
              skipNextCheck = true; // Skip the next check
              // ^ uit setstate zetten?
            });
          }
        } else if (!skipNextCheck) {
          // Check if the distance to current direction is increasing
          if (metersToCurrentDirection < distanceInMeters.toInt() &&
              metersToCurrentDirection != 0) {
            // If so, check if user is getting closer to a different point
            for (
              var iLoop = 0;
              iLoop < descriptionDistanceList.length;
              iLoop++
            ) {
              // Can't check the one after the last
              if (iLoop != descriptionDistanceList.length - 1) {
                // Check if user is closer than the set distance to it
                if (descriptionDistanceList[iLoop +
                        1]['userDistanceFromPoint'] <
                    descriptionDistanceList[iLoop]['distanceBetweenPoints']) {
                  // Skip if the user is getting closer to one that they already passed
                  if (descriptionNum > iLoop) {
                    continue;
                  }
                  // Change to the next description and stop the loop
                  descriptionNum++;
                  break;
                }
              }
            }
          }
        } else {
          skipNextCheck = false; // Reset the flag after skipping
        }

        // Update distance to nect direction
        setState(() {
          metersToCurrentDirection = distanceInMeters.toInt();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    directionList.isNotEmpty
                        ? directionList[descriptionNum].description
                        : "NIKS",
                  ),
                ),
              ),
              // Text('$metersToNextDirection Meter'),
              Text('${metersToCurrentDirection} m'),
            ],
          ),
        ),
      ),
    );
  }
}
