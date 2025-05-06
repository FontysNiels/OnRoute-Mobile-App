import 'dart:async';
import 'dart:math';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Classes/description_point.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Components/BottomSheet/POI/point_of_interest.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_handle.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
import 'package:onroute_app/Functions/conversions.dart';
import 'package:onroute_app/main.dart';

class TripContent extends StatefulWidget {
  final ScrollController scroller;
  final WebMapCollection routeContent;
  final Function setSheetWidget;
  const TripContent({
    super.key,
    required this.scroller,
    required this.routeContent,
    required this.setSheetWidget,
  });

  @override
  State<TripContent> createState() => _TripContentState();
}

// String distanceToFinish = "0.0";
double _distanceToNextPoi = 0.0;
double _traveledDistance = 0.0;
ArcGISPoint? userPosition;
Poi? _nearestPoi;
bool _userNearPoi = false;

class _TripContentState extends State<TripContent> {
  ArcGISMapViewController controller = mapViewController;
  late StreamSubscription<ArcGISLocation> subscription;
  // late StreamSubscription<ArcGISLocation> locationSubscription;
  @override
  void dispose() {
    // controller.locationDisplay.onLocationChanged.drain();
    subscription.cancel();
    _nearestPoi = null;
    _traveledDistance = 0.0;
    _distanceToNextPoi = 0.0;
    _userNearPoi = false;
    super.dispose();
  }

  @override
  void initState() {
    // selectedPoi = widget.routeContent.pointsOfInterest.first;
    calculateDistances();
    super.initState();
  }

  void calculateDistances() {
    List<DescriptionPoint> directions = directionsList;
    if (directions.isEmpty) {
      // This is just a check for the start, it shouldn't happen, but just in case

      widget.setSheetWidget(null, false);
    } else if (directions.isNotEmpty) {
      subscription = controller.locationDisplay.onLocationChanged.listen((
        mode,
      ) async {
        // directions = directionsList;
        if (directions.isEmpty) {
          widget.setSheetWidget(null, false);
        } else {
          double distance = 0.0;
          if (userPosition != null) {
            final userLat = userPosition!.y;
            final userLng = userPosition!.x;
            final currentLat = controller.locationDisplay.location!.position.y;
            final currentLng = controller.locationDisplay.location!.position.x;

            const metersPerDegree = 111320; // Approximation for latitude
            distance =
                sqrt(
                  pow(currentLat - userLat, 2) + pow(currentLng - userLng, 2),
                ) *
                metersPerDegree;

            // print(distance);
          }
          userPosition = controller.locationDisplay.location!.position;

          // Distance to POI
          double closestDistance = double.infinity;
          Poi? closestPoi;

          // Sets the closest POI and distance to it

          //This just overwrites itself over and over, untill reaching the closests
          // make a list of poi + distance, update that, so we can see which one is getting closer and which one isnt
          // or just make a check that says, already visited, so it wont open again....
          for (var poi in widget.routeContent.pointsOfInterest) {
            final poiPosition = convertToLatLng(
              poi.geometry.x!,
              poi.geometry.y!,
            );
            final poiX = poiPosition[1];
            final poiY = poiPosition[0];

            final distanceToPOI = sqrt(
              pow(userPosition!.y - poiY, 2) + pow(userPosition!.x - poiX, 2),
            );

            const metersPerDegree = 111320; // Approximation for latitude
            final distanceInMeters = distanceToPOI * metersPerDegree;

            if (distanceInMeters < closestDistance) {
              closestDistance = distanceInMeters;
              closestPoi = poi;
            }
          }

          // basically checks if distance has been calculated
          if (closestPoi != null) {
            int latestPoi = currenPOI;

            // Distance based
            await _distanceBasedPoiSetter(closestDistance, closestPoi);

            // User selection based
            await _inputBasedPoiSetter(latestPoi);
          }

          if (_distanceToNextPoi != closestDistance) {
            // List with alreadypassed?
            // or
            // check which one user is walking away from and which oen is getting closer

            setState(() {
              _distanceToNextPoi = closestDistance;
              _traveledDistance += distance;
            });
          }
        }
      });
    }
  }

  Future<void> _inputBasedPoiSetter(int latestPoi) async {
    // User selection based
    if (currenPOIChanged) {
      var poiFromList = widget.routeContent.pointsOfInterest.where(
        (element) => element.objectId == latestPoi,
      );
      await moveSheetTo(0.9);
      setState(() {
        currenPOIChanged = false;
        _nearestPoi = poiFromList.first;
      });
    }
  }

  Future<void> _distanceBasedPoiSetter(
    double closestDistance,
    Poi? closestPoi,
  ) async {
    // Distance based
    if (closestDistance <= 20 && !_userNearPoi) {
      //changes sheet height
      await moveSheetTo(0.9);
      //sets poi to the POI user is near
      setState(() {
        _nearestPoi = closestPoi;
        _userNearPoi = true;
      });
    }
    //resets userNearPei, so it can get triggered again
    else if (closestDistance > 20 && _userNearPoi) {
      setState(() {
        _userNearPoi = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            controller: widget.scroller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: BottomSheetHandle(context: context),
                ),

                TripInfoBar(setSheetWidget: widget.setSheetWidget),

                _nearestPoi != null
                    ? POI(routeContent: _nearestPoi!)
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TripInfoBar extends StatefulWidget {
  const TripInfoBar({
    super.key,
    // required this.distanceToFinish,
    required this.setSheetWidget,
  });
  // final String distanceToFinish;
  final Function setSheetWidget;
  @override
  State<TripInfoBar> createState() => _TripInfoBarState();
}

class _TripInfoBarState extends State<TripInfoBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 28,
        children: [
          // Next POI
          // Column(
          //   spacing: 4,
          //   children: [
          //     Text(
          //       "Volgende POI",
          //       style: Theme.of(context).textTheme.labelMedium,
          //     ),
          //     Row(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           _distanceToNextPoi >= 1000
          //               ? (_distanceToNextPoi / 1000).toStringAsFixed(1)
          //               : _distanceToNextPoi.toStringAsFixed(0),

          //           style: Theme.of(context).textTheme.titleLarge!.copyWith(
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         Text(
          //           _distanceToNextPoi > 999 ? "km" : "m",
          //           style: Theme.of(context).textTheme.labelMedium,
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          // Tripteller
          Column(
            spacing: 4,
            children: [
              Text("Voltooid", style: Theme.of(context).textTheme.labelMedium),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _traveledDistance >= 1000
                        ? (_traveledDistance / 1000).toStringAsFixed(1)
                        : _traveledDistance.toStringAsFixed(0),

                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _traveledDistance > 999 ? "km" : "m",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),

          //...
          ElevatedButton.icon(
            onPressed: () async {
              cancel();
              // directionsList.clear();
              // graphicsOverlay.graphics.clear();
              // currenPOI = 0;
            },
            icon: const Icon(Icons.highlight_off),
            label: Text(
              'Stoppen',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),

          // Bestemming Distance
          Column(
            spacing: 4,
            children: [
              Text("Resterend", style: Theme.of(context).textTheme.labelMedium),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // widget.distanceToFinish,
                    disrabceToFinish >= 1000
                        ? (disrabceToFinish / 1000).toStringAsFixed(1)
                        : disrabceToFinish.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    disrabceToFinish > 999 ? "km" : "m",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
