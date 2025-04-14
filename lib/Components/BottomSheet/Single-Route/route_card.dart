import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/single_route.dart';
import 'package:onroute_app/Components/BottomSheet/TripContent/trip_info_bar.dart';

class RouteCard extends StatelessWidget {
  final AvailableRoutes routeContent;
  final VoidCallback onRouteUpdated; // New callback functionF
  final Function startRoute;
  final ScrollController scrollController;

  const RouteCard({
    super.key,
    required this.routeContent,
    required this.onRouteUpdated, // Pass the callback
    required this.startRoute,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Navigate to ROUTE
        final result = Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => SingleRoute(
                  key: UniqueKey(),
                  routeContent: routeContent,
                  startRoute: startRoute,
                  scroller: scrollController,
                ),
          ),
        );

        // Trigger the callback if result is true
        if (await result == true) {
          onRouteUpdated();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => TripContent(
                    key: UniqueKey(),
                    scroller: scrollController,
                  ),
            ),
          );
        }
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      height: 56,
                      width: 56,
                      imageUrl:
                          "https://bragis.nl/wp-content/uploads/2024/01/bragis_onroute.webp",
                      // placeholder:
                      //     (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
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
                            routeContent.title,
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
            // Divider()
          ],
        ),
      ),
    );
  }
}
