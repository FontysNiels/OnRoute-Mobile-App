import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Routes/single_route.dart';

class RouteCard extends StatelessWidget {
  final AvailableRoutes routeContent;
  final VoidCallback onRouteUpdated; // New callback functionF

  const RouteCard({
    super.key,
    required this.routeContent,
    required this.onRouteUpdated, // Pass the callback
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Navigate to ROUTE
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    SingleRoute(key: UniqueKey(), routeContent: routeContent),
          ),
        );

        // Trigger the callback if result is true
        if (result == true) {
          onRouteUpdated();
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
                    child: Image.asset(
                      'assets/temp.png',
                      height: 56,
                      width: 56,
                      fit: BoxFit.cover,
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
                            routeContent.routeLayer.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${(routeContent.routeLayer.layers[0].featureSet.features[0].attributes['TotalMeters'] / 1000).toStringAsFixed(1).toString()} km",
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
                  // IconButton(
                  //   icon: const Icon(Icons.more_vert),
                  //   onPressed: () {
                  //   showPopover(context: context, bodyBuilder: (context)=> PopupMenuItem(child: Text('Download'), value: Text('yes'),));
                  //   },
                  // ),
                  // PopupMenuButton(
                  //   itemBuilder:
                  //       (BuildContext context) => <PopupMenuEntry>[
                  //         const PopupMenuItem(
                  //           // value: SampleItem.itemOne,
                  //           child: Padding(
                  //             padding: EdgeInsets.all(0),
                  //             child: Text('Download'),
                  //           ),
                  //         ),
                  //       ],
                  // ),
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
