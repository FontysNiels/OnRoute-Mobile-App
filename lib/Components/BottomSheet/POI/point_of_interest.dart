import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Components/BottomSheet/TripContent/description_poi.dart';
import 'package:onroute_app/Components/BottomSheet/TripContent/image_poi.dart';
import 'package:onroute_app/Components/BottomSheet/TripContent/title_poi.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_handle.dart';

class POI extends StatelessWidget {
  final Poi routeContent;
  final ScrollController scroller;
  const POI({super.key, required this.routeContent, required this.scroller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scroller,
      child: Column(
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {},
                        icon: const Icon(Icons.language),
                        label: Text(
                          'Website',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge!.copyWith(
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
                DescriptionPOI(description: routeContent.description!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
