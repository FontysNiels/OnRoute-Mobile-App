import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Components/BottomSheet/POI/Widgets/description_poi.dart';
import 'package:onroute_app/Components/BottomSheet/POI/Widgets/image_poi.dart';
import 'package:onroute_app/Components/BottomSheet/POI/Widgets/poi_buttons.dart';
import 'package:onroute_app/Components/BottomSheet/POI/Widgets/title_poi.dart';

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
              if (routeContent.openingHours != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Opent om: ${routeContent.openingHours!.replaceAll(RegExp(r':00$'), '')}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),

              // description
              DescriptionPOI(description: routeContent.description!),
            ],
          ),
        ),
      ],
    );
  }
}
