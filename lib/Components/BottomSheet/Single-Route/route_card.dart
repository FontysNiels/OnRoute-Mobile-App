import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/single_route.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';

class RouteCard extends StatelessWidget {
  final WebMapCollection routeContent;
  // final VoidCallback onRouteUpdated; // New callback functionF
  final Function startRoute;
  final ScrollController scrollController;
  final Function setSheetWidget;

  const RouteCard({
    super.key,
    required this.routeContent,
    // required this.onRouteUpdated, // Pass the callback
    required this.startRoute,
    required this.scrollController,
    required this.setSheetWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Navigate to ROUTE
        // await changesheetsize(0.9);

        await moveSheetTo(0.9);
        setSheetWidget(
          SingleRoute(
            key: UniqueKey(),
            routeContent: routeContent,
            startRoute: startRoute,
            scroller: scrollController,
            setSheetWidget: setSheetWidget,
          ),
          false,
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          height: 56,
                          width: 56,
                          imageUrl:
                              // "https://bragis.nl/wp-content/uploads/2024/01/bragis_onroute.webp",
                              routeContent.availableRoute[0].thumbnail.split("--ONROUTE--")[0],
                          // placeholder:
                          //     (context, url) => CircularProgressIndicator(),
                          errorWidget:
                              (context, url, error) => Icon(Icons.error),
                        ),
                      ),

                      cardImageButton(routeContent: routeContent),
                    ],
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: Theme.of(context).textTheme.bodyLarge,
                            // "Bergsebosfietsen - Genieten over heuvelrug en kromme rijn gebied",
                            routeContent.availableRoute[0].title,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            // "${(routeContent.routeLayer.layers[0].featureSet.features[0].attributes['TotalMeters'] / 1000).toStringAsFixed(1).toString()} km",
                            "GEEN KM MEER",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                          Text(
                            routeContent.locally
                                ? "Gedownload"
                                : "Niet Gedownload",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
