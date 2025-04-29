import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Components/BottomSheet/TripContent/description_poi.dart';
import 'package:onroute_app/Components/BottomSheet/TripContent/image_poi.dart';
import 'package:onroute_app/Components/BottomSheet/TripContent/title_poi.dart';

class POI extends StatelessWidget {
  final Poi routeContent;
  // final ScrollController scroller;

  const POI({
    super.key,
    required this.routeContent,
    // required this.scroller
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ImagePOI(poiList: routeContent),

        // Content
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              TitlePOI(pointOfInterest: routeContent),

              // FUNCTION TO SHOW BUTTONS OF AVAILABLE CONATCT TYPES
              PoiButtons(routeContent: routeContent),

              // description
              DescriptionPOI(description: routeContent.description!),
            ],
          ),
        ),
      ],
    );
  }
}

class PoiButtons extends StatelessWidget {
  final Poi routeContent;
  const PoiButtons({super.key, required this.routeContent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 10,
        children: [
          if (routeContent.website != null)
            ElevatedButton.icon(
              onPressed: () async {
                // Handle website button press
              },
              icon: const Icon(Icons.language),
              label: Text(
                'Website',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          if (routeContent.mail != null)
            ElevatedButton.icon(
              onPressed: () async {
                // Handle email button press
              },
              icon: const Icon(Icons.mail),
              label: Text(
                'Email',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          if (routeContent.phone != null)
            ElevatedButton.icon(
              onPressed: () async {
                // Handle phone button press
              },
              icon: const Icon(Icons.phone),
              label: Text(
                'Telefoon',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
