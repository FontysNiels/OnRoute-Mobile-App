import 'dart:async';
import 'dart:math';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/TESTCLASS.dart';
import 'package:onroute_app/Classes/description_point.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_handle.dart';
import 'package:onroute_app/Functions/conversions.dart';
import 'package:onroute_app/main.dart';

class TripContent extends StatefulWidget {
  final ScrollController scroller;
  final WebMapCollection routeContent;
  const TripContent({
    super.key,
    required this.scroller,
    required this.routeContent,
  });

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
    calculateDistances();
    super.initState();
  }

  void calculateDistances() {
    List<DescriptionPoint> directions = getDirectionList();
    if (directions.isEmpty) {
      Navigator.pop(context, false);
    } else if (directions.isNotEmpty) {
      // TODO: Make this calculate (totaldistance - distance traveled (points length) & distance traveled to current point = bestemming)
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
        // print(distanceInMeters);
        setState(() {
          if (distanceInMeters >= 1000) {
            distanceToFinish = (distanceInMeters / 1000).toStringAsFixed(1);
          } else {
            distanceToFinish = distanceInMeters.toStringAsFixed(0);
          }
        });
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

                TripInfoBar(distanceToFinish: distanceToFinish),


                // TODO: get this out of the same thing as tripInfo, since it loops shit
                // TODO: make it receive the current POI
                // TODO: link POIs to map and how close user is to them
                POI(routeContent: widget.routeContent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class POI extends StatelessWidget {
  final WebMapCollection routeContent;
  const POI({super.key, required this.routeContent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image
        ImagePOI(poiList: routeContent.pointsOfInterest),
        // Content
        BodyPOI(poiList: routeContent.pointsOfInterest),
      ],
    );
  }
}

class ImagePOI extends StatelessWidget {
  final List<Poi> poiList;
  const ImagePOI({super.key, required this.poiList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 197, 197, 197),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              'assets/temp.png',
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ),
        ),
        SizedBox(height: 20),
        Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 197, 197, 197),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              'assets/temp-vertical.png',
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class BodyPOI extends StatelessWidget {
  final List<Poi> poiList;
  const BodyPOI({super.key, required this.poiList});
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          TitlePOI(),

          // FUNCTION TO SHOW BUTTONS OF AVAILABLE CONATCT TYPES
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {},
                  icon: const Icon(Icons.language),
                  label: Text(
                    'Website',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      //TODO: set ElevatedButtonTheme so it works instantly
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  iconAlignment: IconAlignment.start,
                  style: ButtonStyle(
                    // iconColor: WidgetStateProperty.all(const Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ],
            ),
          ),

          // description
          DescriptionPOI(),
        ],
      ),
    );
  }
}

class DescriptionPOI extends StatelessWidget {
  const DescriptionPOI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'POI beschrijving',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),

        // Beschrijving
        Text(
          "BeschrijvingBeschrijvingBeschrijvingBeschrijvingBeschrijvingBeschrijving BeschrijvingBeschrijvingBeschrijving Beschrijving",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class TitlePOI extends StatelessWidget {
  const TitlePOI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          "TITLE",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        // type
        Text(
          "TYPE",
          style: Theme.of(context).textTheme.bodySmall,
          // style: Theme.of(context).textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
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
                Text(
                  double.parse(distanceToFinish) > 999 ? "km" : "m",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
