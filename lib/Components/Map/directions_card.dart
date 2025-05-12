import 'dart:async';
import 'dart:math';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Functions/conversions.dart';
import 'package:onroute_app/main.dart';

class DirectionsCard extends StatefulWidget {
  const DirectionsCard({super.key});

  @override
  State<DirectionsCard> createState() => _DirectionsCardState();
}

class _DirectionsCardState extends State<DirectionsCard> {
  // Variable that shows the distance in meters to the current direction
  int metersToCurrentDirection = 0;
  // The number description the user is on
  int descriptionNum = 0;
  // Condition that shows if user is away from route
  bool userAwayFromRoute = true;
  // The subscription that subscribes the to user's location
  late StreamSubscription<ArcGISLocation> subscription;

  // Function that initializes the subscription and handles the location updates
  void _initializeLocationSubscription(List lines) {
    subscription = mapViewController.locationDisplay.onLocationChanged.listen((
      mode,
    ) {
      _handleLocationUpdate(lines);
    });
  }

  // Function that handles location updates and check if the user is near a line segment
  void _handleLocationUpdate(List lines) {
    // User's locatoon
    final userPosition = mapViewController.locationDisplay.location!.position;
    // List of distances to direction points
    List closeto = [];
    // List of the closest point and it's distance
    List closestPoint = [];

    // Filling these lists, by looping through all the direction points and calculating the distance to them
    for (int i = 0; i < lines.length - 1; i++) {
      final start = lines[i];
      final end = lines[i + 1];

      final distanceBetweenUserAndLine = sqrt(
        pow(userPosition.y - ((start[0] + end[0]) / 2), 2) +
            pow(userPosition.x - ((start[1] + end[1]) / 2), 2),
      );

      final distanceInMeters = distanceBetweenUserAndLine * 111320;

      if (distanceInMeters < 50) {
        closeto.add([distanceInMeters, start[2]]);
      }
    }

    // If there is a closest one, add it
    if (closeto.isNotEmpty) {
      final closestEntry = closeto.reduce((a, b) => a[0] < b[0] ? a : b);
      closestPoint = closestEntry;
    }

    // Variable that checks if the user is near or on the route
    bool found = _updateCurrentDirection(userPosition, lines, closestPoint);

    // If not the case, and the userAwayFromRoute is still false, change the userAwayFromRoute to true
    if (!found && !userAwayFromRoute) {
      setState(() {
        userAwayFromRoute = true;
      });
    }

    // Handles all updates to the distance numbers
    _updateDistanceToNextPoint(userPosition);
  }

  // Check if the user is between or near the two points and update the direction
  bool _updateCurrentDirection(position, List lines, List closestPoint) {
    for (int i = 0; i < lines.length - 1; i++) {
      final start = lines[i];
      final end = lines[i + 1];

      final isBetweenLat =
          (position.y >= start[0] && position.y <= end[0]) ||
          (position.y <= start[0] && position.y >= end[0]);
      final isBetweenLng =
          (position.x >= start[1] && position.x <= end[1]) ||
          (position.x <= start[1] && position.x >= end[1]);

      if (isBetweenLat && isBetweenLng) {
        // print("inbetween");

        return _setDirectionFromObjectID(start[2]);
      } else if (closestPoint.isNotEmpty && closestPoint[0] < 40) {
        return _setDirectionFromObjectID(closestPoint[1]);
      }
    }
    return false;
  }

  // Set the direction based on the ObjectID of the closest point
  bool _setDirectionFromObjectID(int objectID) {
    if (userAwayFromRoute) {
      setState(() {
        userAwayFromRoute = false;
      });
      return true;
    } else {
      for (var element in routeInfo.layers[2].featureSet.features) {
        if (element.attributes['ObjectID'] == objectID) {
          var testIndex = directionList.indexWhere(
            (direct) => direct.description == element.attributes['DisplayText'],
          );

          if (descriptionNum != testIndex + 1) {
            setState(() {
              descriptionNum = testIndex + 1;
              userAwayFromRoute = false;
            });
            return true;
          }
        }
      }
    }

    return true;
  }

  /// Update the distance to the next point, and all the distance in general
  void _updateDistanceToNextPoint(dynamic userPosition) {
    if (directionList.isNotEmpty) {
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

      const metersPerDegree = 111320;
      final distanceInMeters = distanceToDirectionPoint * metersPerDegree;

      var distanceToEveryDirection =
          routeInfo.layers[1].featureSet.features
              .map((feature) => feature.attributes['Meters'])
              .toList();

      if (descriptionNum == 0) {
        distanceToEveryDirection.insert(0, distanceInMeters.toInt());
      } else {
        // print(distanceToEveryDirection[descriptionNum - 1]);
        distanceToEveryDirection[descriptionNum - 1] = distanceInMeters.toInt();
        distanceToEveryDirection = distanceToEveryDirection.sublist(
          descriptionNum - 1,
        );
      }
      var totalDistance = distanceToEveryDirection.reduce((a, b) => a + b);

      if (disrabceToFinish != totalDistance) {
        disrabceToFinish = totalDistance;
      }

      setState(() {
        metersToCurrentDirection = distanceInMeters.toInt();
      });
    }
  }

  // Return a list of the points with normalized coordinates and the direction point ID
  List _generateLinePoints() {
    List lines = [];
    for (var element in routeInfo.layers[1].featureSet.features) {
      for (var i = 0; i < element.geometry.paths![0].length; i++) {
        lines.add(
          convertToLatLngSpecial(
            element.geometry.paths![0][i][0],
            element.geometry.paths![0][i][1],
            element.attributes['DirectionPointID'],
          ),
        );
      }
    }
    return lines;
  }

  @override
  void dispose() {
    subscription.cancel();
    metersToCurrentDirection = 0;
    descriptionNum = 0;
    userAwayFromRoute = false;
    directionList.clear();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (directionList.isNotEmpty) {
      final lines = _generateLinePoints();
      _initializeLocationSubscription(lines);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 6,
            right: 6,
          ),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                            ? userAwayFromRoute && descriptionNum == 0
                                ? metersToCurrentDirection > 20 ||
                                        metersToCurrentDirection == 0
                                    ? "Ga naar de start van de route"
                                    : directionList[descriptionNum].description
                                : userAwayFromRoute
                                ? "Ga terug naar de route"
                                : directionList[descriptionNum].description
                            : "NIKS",
                      ),
                    ),
                  ),

                  // Text('$metersToNextDirection Meter'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            metersToCurrentDirection > 1000
                                ? '${(metersToCurrentDirection / 1000).toStringAsFixed(1).replaceAll('.', ',')}'
                                : '$metersToCurrentDirection',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(height: 1.0),
                          ),
                          Text(
                            metersToCurrentDirection > 1000 ? 'Km' : 'Meter',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.2),
                          ),
                        ],
                      ),

                      //  child: Column(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     Text(
                      //     '${metersToCurrentDirection}',
                      //     style: Theme.of(
                      //       context,
                      //     ).textTheme.titleLarge?.copyWith(
                      //         height: 1.0,
                      //         color: Theme.of(context).primaryColor.computeLuminance() > 0.5
                      //           ? Colors.black
                      //           : Colors.white,
                      //       ),
                      //     ),
                      //     Text(
                      //     'Meter',
                      //     style: Theme.of(
                      //       context,
                      //     ).textTheme.bodyMedium?.copyWith(
                      //         height: 1.2,
                      //         color: Theme.of(context).primaryColor.computeLuminance() > 0.5
                      //           ? Colors.black
                      //           : Colors.white,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
