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
  int i = 0;
  bool skipNextCheck = false;
  late final List<DescriptionPoint> _directionsList;

  @override
  void initState() {
    // TODO: implement initState
    _directionsList = [];
    for (var i = 0; i < widget._directionsList.length; i++) {
      // _directionsList.add(widget._directionsList[i]);
      if (i > 0) {
        if (i == 1) {
          _directionsList.add(widget._directionsList[i]);
        } else if (widget._directionsList[i].x ==
                widget._directionsList[i - 1].x &&
            widget._directionsList[i].y == widget._directionsList[i - 1].y) {
          _directionsList.add(widget._directionsList[i - 1]);
        } else {
          _directionsList.add(widget._directionsList[i]);
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
          _directionsList[i].x,
          _directionsList[i].y,
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

        // Distance between the user and the next point
        final directionPointXYnext = convertToLatLng(
          _directionsList[i == _directionsList.length - 1 ? i : i + 1].x,

          _directionsList[i == _directionsList.length - 1 ? i : i + 1].y,
        );
        final directionPointXnext = directionPointXYnext[1];
        final directionPointYnext = directionPointXYnext[0];

        final distanceNext = sqrt(
          pow(userPosition.y - directionPointYnext, 2) +
              pow(userPosition.x - directionPointXnext, 2),
        );

        final distanceInMeterToNext = distanceNext * metersPerDegree;

        // Distance between the current and next point
        var distanceBetweenPoints = 0;
        final matchingFeatures = widget._routeInfo.layers[1].featureSet.features
            .where(
              (feature) => feature.attributes['DirectionPointID'] == (i + 1),
            );

        if (matchingFeatures.isNotEmpty) {
          distanceBetweenPoints =
              matchingFeatures.first.attributes['Meters'].toInt();
        } else {
          // distanceBetweenPoints = 0; // Default value if no matching feature is found
        }
        // print("points distance: $distanceBetweenPoints");
        // print('nect distance $distanceInMeterToNext');
        // print('current distance $distanceInMeters');

        // Create a list of descriptions and distances
        List<Map<String, dynamic>> descriptionsAndDistances = [];

        for (int index = 0; index < _directionsList.length; index++) {
          final point = _directionsList[index];
          final pointXY = convertToLatLng(point.x, point.y);
          final pointX = pointXY[1];
          final pointY = pointXY[0];

          final distanceToPoint = sqrt(
            pow(userPosition.y - pointY, 2) + pow(userPosition.x - pointX, 2),
          );

          final distanceInMetersToPoint = distanceToPoint * metersPerDegree;

          int distanceBetweenPoints = 0;
          final matchingFeatures = widget
              ._routeInfo
              .layers[1]
              .featureSet
              .features
              .where(
                (feature) =>
                    feature.attributes['DirectionPointID'] == (index + 1),
              );

          if (matchingFeatures.isNotEmpty) {
            distanceBetweenPoints =
                matchingFeatures.first.attributes['Meters'].toInt();
          }
          descriptionsAndDistances.add({
            // 'description': point.description,
            'userDistanceFromPoint': distanceInMetersToPoint.toInt(),
            'distanceToNext': distanceBetweenPoints,
          });
        }

        // Print the list for debugging
        print(descriptionsAndDistances.length);
        print(_directionsList.length);

        // MAKE IT SO IT CHECK IF WALKING AWAY (_mapViewController.locationDisplay.location!.course)
        if (distanceToDirectionPoint < thresholdDistance) {
          if (i < widget._directionsList.length - 1) {
            print("User has passed the current direction's coordinates.");
            setState(() {
              i++;
              skipNextCheck = true; // Skip the next check
              // ^ uit setstate zetten?
            });
          }
        } else if (!skipNextCheck) {
          if (metersToNextDirection < distanceInMeters.toInt() &&
              metersToNextDirection != 0) {
            print('distance increasing');
            for (
              var iLoop = 0;
              iLoop < descriptionsAndDistances.length;
              iLoop++
            ) {
              if (iLoop != descriptionsAndDistances.length - 1) {
                //
                // if (iLoop <= i) {
                //   continue;
                // }

                if (descriptionsAndDistances[iLoop +
                        1]['userDistanceFromPoint'] <
                    descriptionsAndDistances[iLoop]['distanceToNext']) {
                  if (i > iLoop) {
                    continue;
                  }
                  print('closer to next point');
                  // print(descriptionsAndDistances[iLoop]);

                  // descriptionsAndDistances[iLoop]['distanceToNext'] =
                  //     descriptionsAndDistances[iLoop + 1]['distanceToNext'];
                  // descriptionsAndDistances[iLoop + 1]['distanceToNext'] = 0;
                  // }

                  // print(widget._directionsList[i].description);
                  // print(descriptionsAndDistances[iLoop]['distanceToNext']);
                  // print(metersToNextDirection);
                  // print(distanceInMeters.toInt());

                  i++;
                  break;
                }
              }
            }
          }
          // if user walks away from point and is getting closer to next point (start point test only, so if you start halfway it doesnt work)
          // if (metersToNextDirection < distanceInMeters.toInt() &&
          //     distanceBetweenPoints > distanceInMeterToNext &&
          //     metersToNextDirection != 0 &&
          //     distanceBetweenPoints != 0) {
          //   if (i < widget._directionsList.length - 1) {
          //     i++;
          //     print(
          //       "${widget._directionsList[i].description} : Significant decrease in distance detected.",
          //     );
          //   }
          // }
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
                    _directionsList.isNotEmpty
                        ? _directionsList[i].description
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
