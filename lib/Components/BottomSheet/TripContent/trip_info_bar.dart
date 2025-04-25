import 'dart:async';
import 'dart:math';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/TESTCLASS.dart';
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

String distanceToFinish = "0.0";
Poi? currentPoi;
int currentPoiInt = 0;

class _TripContentState extends State<TripContent> {
  ArcGISMapViewController controller = getMapViewController();
  late StreamSubscription<ArcGISLocation> subscription;

  @override
  void dispose() {
    // controller.locationDisplay.onLocationChanged.drain();
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    calculateDistances();
    super.initState();
  }

  void calculateDistances() {
    List<DescriptionPoint> directions = getDirectionList();
    if (directions.isEmpty) {
      // This is just a check for the start, it shouldn't happen, but just in case
      widget.setSheetWidget(null, false);
    } else if (directions.isNotEmpty) {
      // TODO: Make this calculate (totaldistance - distance traveled (points length) & distance traveled to current point = bestemming)
      subscription = controller.locationDisplay.onLocationChanged.listen((
        mode,
      ) {
        directions = getDirectionList();
        if (directions.isEmpty) {
          widget.setSheetWidget(null, false);
        } else {
          final userPosition = controller.locationDisplay.location!.position;

          final directionPointXY = convertToLatLng(
            directions.last.x,
            directions.last.y,
          );
          final directionPointX = directionPointXY[1];
          final directionPointY = directionPointXY[0];

          final distanceToDirectionPoint = sqrt(
            pow(userPosition.y - directionPointY, 2) +
                pow(userPosition.x - directionPointX, 2),
          );

          const metersPerDegree = 111320; // Approximation for latitude
          final distanceInMeters = distanceToDirectionPoint * metersPerDegree;
          // print(distanceInMeters);
          if (distanceToFinish !=
                  (distanceInMeters / 1000).toStringAsFixed(1) ||
              distanceToFinish != distanceInMeters.toStringAsFixed(0)) {
            setState(() {
              if (distanceInMeters >= 1000) {
                distanceToFinish = (distanceInMeters / 1000).toStringAsFixed(1);
              } else {
                distanceToFinish = distanceInMeters.toStringAsFixed(0);
              }
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int newCurrentPoiInt = getcurrentPOI();
    
    if (newCurrentPoiInt != currentPoiInt) {
      currentPoiInt = newCurrentPoiInt;

      var poiFromList = widget.routeContent.pointsOfInterest.where(
        (element) => element.objectId == currentPoiInt,
      );

      if (newCurrentPoiInt == 0) {
        currentPoi = null;
      } else {
        currentPoi = poiFromList.isNotEmpty ? poiFromList.first : null;
      }
    }

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

                TripInfoBar(
                  distanceToFinish: distanceToFinish,
                  setSheetWidget: widget.setSheetWidget,
                ),

                // TODO: link POIs to map and how close user is to them
                currentPoi != null
                    ? POI(routeContent: currentPoi!, scroller: widget.scroller)
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
    required this.distanceToFinish,
    required this.setSheetWidget,
  });
  final String distanceToFinish;
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
          Column(
            spacing: 4,
            children: [
              Text(
                "Volgende POI",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "120",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("m", style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ],
          ),
          // Tripteller
          Column(
            spacing: 4,
            children: [
              Text(
                "Tripteller",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "1,8",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("km", style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ],
          ),
          // Bestemming Distance
          Column(
            spacing: 4,
            children: [
              Text(
                "Bestemming",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.distanceToFinish,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    double.parse(widget.distanceToFinish) > 999 ? "km" : "m",
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
