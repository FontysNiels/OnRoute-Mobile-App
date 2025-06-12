import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';

class cardImageButton extends StatelessWidget {
  const cardImageButton({super.key, required this.routeContent});

  final WebMapCollection routeContent;

  @override
  Widget build(BuildContext context) {
    return routeContent.availableRoute[0].tags!.contains("Fiets")
        ? Positioned(
          bottom: 0,
          right: 0,
          child: DecoratedIcon(
            icon: Icon(
              Icons.directions_bike,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            decoration: IconDecoration(border: IconBorder(color: Colors.white)),
          ),
        )
        : routeContent.availableRoute[0].tags!.contains("Wandel")
        ? Positioned(
          bottom: 0,
          right: 0,
          child: DecoratedIcon(
            icon: Icon(
              Icons.directions_walk,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            decoration: IconDecoration(border: IconBorder(color: Colors.white)),
          ),
        )
        : Container();
  }
}
