import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/poi.dart';

class TitlePOI extends StatelessWidget {
  final Poi pointOfInterest;
  const TitlePOI({super.key, required this.pointOfInterest});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          pointOfInterest.title,
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
