import 'dart:async';
import 'dart:math';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/description_point.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/conversions.dart';
import 'package:onroute_app/main.dart';

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
  // int amountOfDirections = 0;
  // bool skipNextCheck = false;

  bool userAwayFromRoute = false;
  // Create a list of descriptions and distances
  // List<Map<String, dynamic>> descriptionDistanceList = [];
  late final List<DescriptionPoint> directionList;
  late StreamSubscription<ArcGISLocation> subscription;

  void _initializeLocationSubscription(List lines) {
    subscription = widget._mapViewController.locationDisplay.onLocationChanged
        .listen((mode) {
          _handleLocationUpdate(lines);
        });
  }

  // Handle location updates and check if the user is near a line segment
  void _handleLocationUpdate(List lines) {
    final userPosition =
        widget._mapViewController.locationDisplay.location!.position;
    List closeto = [];
    var closestPoint = [];

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

    if (closeto.isNotEmpty) {
      final closestEntry = closeto.reduce((a, b) => a[0] < b[0] ? a : b);
      closestPoint = closestEntry;
    }

    bool found = _updateCurrentDirection(userPosition, lines, closestPoint);

    if (!found && !userAwayFromRoute) {
      setState(() {
        userAwayFromRoute = true;
      });
    }

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
        print("inbetween");

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
      for (var element in widget._routeInfo.layers[2].featureSet.features) {
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

  /// Update the distance to the next point
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
          widget._routeInfo.layers[1].featureSet.features
              .map((feature) => feature.attributes['Meters'])
              .toList();

      if (descriptionNum == 0) {
        distanceToEveryDirection[descriptionNum] = distanceInMeters.toInt();
      } else {
        // print(distanceToEveryDirection[descriptionNum - 1]);

        distanceToEveryDirection[descriptionNum - 1] = distanceInMeters.toInt();
        // print(distanceToEveryDirection[descriptionNum - 1]);
        distanceToEveryDirection = distanceToEveryDirection.sublist(
          descriptionNum - 1,
        );
        var totalDistance = distanceToEveryDirection.reduce((a, b) => a + b);

        if (disrabceToFinish != totalDistance) {
          disrabceToFinish = totalDistance;
        }
      }

      setState(() {
        metersToCurrentDirection = distanceInMeters.toInt();

        // if (descriptionNum == 0) {
        //   metersToCurrentDirection = distanceInMeters.toInt();
        // } else {
        //   metersToCurrentDirection = int.parse(distanceToEveryDirection[descriptionNum -1]);
        // }
      });
    }
  }

  // Return a list of the points with normalized coordinates and the direction point ID
  List _generateLinePoints() {
    List lines = [];
    for (var element in widget._routeInfo.layers[1].featureSet.features) {
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
    // routing();
    directionList = widget._directionsList;

    if (widget._directionsList.isNotEmpty) {
      final lines = _generateLinePoints();
      _initializeLocationSubscription(lines);
    }

    // void routing() {
    //   // amountOfDirections = widget._directionsList.length;
    //   directionList = widget._directionsList;

    //   // print(directionList);
    //   List lines = [];
    //   if (widget._directionsList.isNotEmpty) {
    //     for (var element in widget._routeInfo.layers[1].featureSet.features) {
    //       // print(routeInfo.layers[2].featureSet.features.where((item)=> item.attributes['ObjectID'] == ));
    //       for (var i = 0; i < element.geometry.paths![0].length; i++) {
    //         lines.add(
    //           convertToLatLngSpecial(
    //             element.geometry.paths![0][i][0],
    //             element.geometry.paths![0][i][1],
    //             element.attributes['DirectionPointID'],
    //           ),
    //         );
    //       }
    //     }

    //     subscription = widget._mapViewController.locationDisplay.onLocationChanged.listen((
    //       mode,
    //     ) {
    //       if (widget._directionsList.isNotEmpty) {
    //         final userPosition =
    //             widget._mapViewController.locationDisplay.location!.position;
    //         List closeto = [];
    //         var closestPoint = [];
    //         for (int i = 0; i < lines.length - 1; i++) {
    //           final start = lines[i];
    //           final end = lines[i + 1];

    //           // print(lines);
    //           final distanceBetweenUserAndLine = sqrt(
    //             pow(userPosition.y - ((start[0] + end[0]) / 2), 2) +
    //                 pow(userPosition.x - ((start[1] + end[1]) / 2), 2),
    //           );

    //           final distanceInMeters = distanceBetweenUserAndLine * 111320;

    //           if (distanceInMeters < 50) {
    //             closeto.add([distanceInMeters, start[2]]);
    //             // print("Distance to line segment: ${distanceInMeters} meters");
    //           }
    //         }
    //         if (closeto.isNotEmpty) {
    //           final closestEntry = closeto.reduce((a, b) => a[0] < b[0] ? a : b);
    //           // print(closestEntry);
    //           closestPoint = closestEntry;
    //           // setState(() {
    //           //   metersToCurrentDirection = closestEntry[0].toInt();
    //           // });
    //         }

    //         for (int i = 0; i < lines.length - 1; i++) {
    //           final start = lines[i];
    //           final end = lines[i + 1];

    //           // Check if the user is between the two points
    //           final isBetweenLat =
    //               (userPosition.y >= start[0] && userPosition.y <= end[0]) ||
    //               (userPosition.y <= start[0] && userPosition.y >= end[0]);
    //           final isBetweenLng =
    //               (userPosition.x >= start[1] && userPosition.x <= end[1]) ||
    //               (userPosition.x <= start[1] && userPosition.x >= end[1]);

    //           if (isBetweenLat && isBetweenLng) {
    //             // print("User is between coordinates: $start and $end");
    //             for (var element
    //                 in widget._routeInfo.layers[2].featureSet.features) {
    //               if (element.attributes['ObjectID'] == start[2]) {
    //                 // print(element.attributes['DisplayText']);
    //                 var testIndex = directionList.indexWhere(
    //                   (direct) =>
    //                       direct.description == element.attributes['DisplayText'],
    //                 );
    //                 // print(directionList[testIndex]);
    //                 descriptionNum = testIndex + 1;
    //               }
    //             }
    //             if (userAwayFromRoute) {
    //               userAwayFromRoute = !userAwayFromRoute;
    //             }
    //             // print("Distance to line segment: ${distanceInMeters} meters");
    //             break;
    //           } else if (closestPoint.length != 0) {
    //             if (closestPoint[0] < 40) {
    //               for (var element
    //                   in widget._routeInfo.layers[2].featureSet.features) {
    //                 if (element.attributes['ObjectID'] == closestPoint[1]) {
    //                   // print(element.attributes['DisplayText']);
    //                   var testIndex = directionList.indexWhere(
    //                     (direct) =>
    //                         direct.description ==
    //                         element.attributes['DisplayText'],
    //                   );

    //                   // print(directionList[testIndex]);
    //                   if (descriptionNum != testIndex + 1) {
    //                     descriptionNum = testIndex + 1;
    //                   }
    //                 }
    //               }

    //               if (userAwayFromRoute) {
    //                 userAwayFromRoute = !userAwayFromRoute;
    //               }
    //               // print("Distance to line segment: ${distanceInMeters} meters");
    //               break;
    //             }
    //           } else if (i == lines.length - 2) {
    //             if (!userAwayFromRoute) {
    //               setState(() {
    //                 userAwayFromRoute = !userAwayFromRoute;
    //               });

    //               print("nergens");
    //             }
    //           }
    //         }
    //       }
    //       // check that checks if user is facing a point and moving towards it?

    //       if (widget._directionsList.isNotEmpty) {
    //         // Calculate the distance between the user's current position and the direction's coordinates
    //         final userPosition =
    //             widget._mapViewController.locationDisplay.location!.position;

    //         final directionPointXY = convertToLatLng(
    //           directionList[descriptionNum].x,
    //           directionList[descriptionNum].y,
    //         );
    //         final directionPointX = directionPointXY[1];
    //         final directionPointY = directionPointXY[0];

    //         final distanceToDirectionPoint = sqrt(
    //           pow(userPosition.y - directionPointY, 2) +
    //               pow(userPosition.x - directionPointX, 2),
    //         );

    //         // Define a threshold distance (e.g., 10 meters)
    //         // Approx. 10 meters in lat/long degrees
    //         const thresholdDistance = 0.0001;
    //         const metersPerDegree = 111320; // Approximation for latitude
    //         final distanceInMeters = distanceToDirectionPoint * metersPerDegree;
    //         // List<Map<String, dynamic>> descriptionDistanceListTemp = [];
    //         // for (int index = 0; index < directionList.length; index++) {
    //         //   final point = directionList[index];
    //         //   final pointXY = convertToLatLng(point.x, point.y);
    //         //   final pointX = pointXY[1];
    //         //   final pointY = pointXY[0];

    //         //   final distanceToPoint = sqrt(
    //         //     pow(userPosition.y - pointY, 2) + pow(userPosition.x - pointX, 2),
    //         //   );

    //         //   final distanceInMetersToPoint = distanceToPoint * metersPerDegree;

    //         //   int distanceBetweenPoints = 0;
    //         //   // Get distance between points

    //         //   final matchingFeatures = widget
    //         //       ._routeInfo
    //         //       .layers[1]
    //         //       .featureSet
    //         //       .features
    //         //       .where(
    //         //         (feature) =>
    //         //             feature.attributes['DirectionPointID'] ==
    //         //             (widget
    //         //                 ._routeInfo
    //         //                 .layers[2]
    //         //                 .featureSet
    //         //                 .features[index]
    //         //                 .attributes["ObjectID"]),
    //         //       );

    //         //   // Set distance between points
    //         //   if (matchingFeatures.isNotEmpty) {
    //         //     distanceBetweenPoints =
    //         //         matchingFeatures.first.attributes['Meters'].toInt();
    //         //   }
    //         //   descriptionDistanceListTemp.add({
    //         //     'desc': point.description,
    //         //     'userDistanceFromPoint': distanceInMetersToPoint.toInt(),
    //         //     'distanceBetweenPoints': distanceBetweenPoints,
    //         //   });
    //         // }

    //         // MAKE IT SO IT CHECK IF WALKING AWAY (_mapViewController.locationDisplay.location!.course)
    //         // print(descriptionDistanceList);
    //         // if (distanceToDirectionPoint < thresholdDistance) {
    //         //   if (descriptionNum < amountOfDirections - 1) {
    //         //     print("User has passed the current direction's coordinates.");
    //         //     setState(() {
    //         //       descriptionNum++;
    //         //       skipNextCheck = true; // Skip the next check
    //         //       // ^ uit setstate zetten?
    //         //     });
    //         //   }
    //         // } else if (!skipNextCheck) {
    //         //   // Check if the distance to current direction is increasing
    //         //   if (metersToCurrentDirection < distanceInMeters.toInt() &&
    //         //       metersToCurrentDirection != 0) {
    //         //     // If so, check if user is getting closer to a different point
    //         //     for (
    //         //       var iLoop = 0;
    //         //       iLoop < descriptionDistanceList.length;
    //         //       iLoop++
    //         //     ) {
    //         //       // Can't check the one after the last
    //         //       if (iLoop != descriptionDistanceList.length - 1) {
    //         //         // print('tempdistance ${descriptionDistanceListTemp[1]['userDistanceFromPoint']}');
    //         //         // print('main distance ${descriptionDistanceList[1]['userDistanceFromPoint']}');
    //         //         // print('0--------0');

    //         //         // Check if user is closer than the set distance to it

    //         //         // if (descriptionDistanceList[iLoop +
    //         //         //         1]['userDistanceFromPoint'] <
    //         //         //     descriptionDistanceList[iLoop]['distanceBetweenPoints']) {
    //         //         if (descriptionDistanceListTemp[iLoop]['userDistanceFromPoint'] >
    //         //                 descriptionDistanceList[iLoop]['userDistanceFromPoint'] &&
    //         //             descriptionDistanceListTemp[iLoop +
    //         //                     1]['userDistanceFromPoint'] <
    //         //                 descriptionDistanceList[iLoop +
    //         //                     1]['userDistanceFromPoint']) {
    //         //           // Skip if the user is getting closer to one that they already passed

    //         //           if (descriptionNum > iLoop) {
    //         //             continue;
    //         //           }

    //         //           // Change to the next description and stop the loop
    //         //           descriptionNum++;
    //         //           break;
    //         //         }
    //         //       }
    //         //     }
    //         //   }
    //         // } else {
    //         //   skipNextCheck = false; // Reset the flag after skipping
    //         // }

    //         // Update distance to nect direction
    //         setState(() {
    //           metersToCurrentDirection = distanceInMeters.toInt();
    //           // descriptionDistanceList = descriptionDistanceListTemp;
    //         });
    //       }
    //     });
    //   }
    // }
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
                                ? metersToCurrentDirection > 20
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

        Padding(
          padding: EdgeInsets.only(left: 14, right: 8, top: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 12,
            children: [
              FloatingActionButton(
                heroTag: UniqueKey(),
                onPressed:
                    () => {
                      mapViewController.locationDisplay.autoPanMode =
                          LocationDisplayAutoPanMode.recenter,
                    },
                child: Icon(Icons.gps_fixed),
              ),
              FloatingActionButton(
                heroTag: UniqueKey(),
                onPressed:
                    () => {
                      mapViewController.locationDisplay.autoPanMode =
                          // LocationDisplayAutoPanMode.compassNavigation,
                          LocationDisplayAutoPanMode.navigation,
                    },
                child: Icon(Icons.compass_calibration),
              ),
              FloatingActionButton(
                heroTag: UniqueKey(),
                onPressed:
                    () => {
                      enabledNotifiation = !enabledNotifiation,

                      mapViewController.locationDisplay.autoPanMode =
                          LocationDisplayAutoPanMode.compassNavigation,
                    },
                child: Icon(enabledNotifiation ? Icons.notifications: Icons.notifications_off),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
