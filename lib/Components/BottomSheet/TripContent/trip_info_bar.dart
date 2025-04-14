import 'dart:async';
import 'dart:math';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/description_point.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_handle.dart';
import 'package:onroute_app/Functions/conversions.dart';
import 'package:onroute_app/main.dart';

class TripContent extends StatefulWidget {
  final ScrollController scroller;
  const TripContent({super.key, required this.scroller});

  @override
  State<TripContent> createState() => _TripContentState();
}

String distanceToFinish = "0.0";

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
    List<DescriptionPoint> directions = getDirectionList();
    if (directions.isEmpty) {
      Navigator.pop(context, false);
    } else if (directions.isNotEmpty) {
      subscription = controller.locationDisplay.onLocationChanged.listen((
        mode,
      ) {
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

        setState(() {
          distanceToFinish = (distanceInMeters / 1000).toStringAsFixed(1);
        });
      });
    }
    super.initState();
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

                TripInfoBar(distanceToFinish: distanceToFinish),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TripInfoBar extends StatelessWidget {
  const TripInfoBar({super.key, required this.distanceToFinish});
  final String distanceToFinish;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
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
            Text("Tripteller", style: Theme.of(context).textTheme.labelMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "1,8",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
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
            Text("Bestemming", style: Theme.of(context).textTheme.labelMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  distanceToFinish,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text("km", style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
