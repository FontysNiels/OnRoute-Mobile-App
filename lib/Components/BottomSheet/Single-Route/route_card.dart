import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_card_image_icon.dart';
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
                horizontal: 12.0,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            routeContent.locally
                                ? Image.file(
                                  File(routeContent.thumbnail),
                                  height: 56,
                                  width: 56,
                                  fit: BoxFit.cover,
                                )
                                : Image.network(
                                  routeContent.thumbnail,
                                  height: 56,
                                  width: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return SizedBox(
                                      height: 56,
                                      width: 56,
                                      child: Icon(
                                        Icons.wifi_off,
                                        size: 25,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                      ),

                      //   child: CachedNetworkImage(
                      //     // fit: BoxFit.cover,
                      //     height: 56,
                      //     width: 56,
                      //     imageUrl:
                      //         // "https://bragis.nl/wp-content/uploads/2024/01/bragis_onroute.webp",
                      //         routeContent.availableRoute[0].thumbnail.split(
                      //           "--ONROUTE--",
                      //         )[0],
                      //     // placeholder:
                      //     //     (context, url) => CircularProgressIndicator(),
                      //     errorWidget:
                      //         (context, url, error) => Icon(Icons.error),
                      //   ),
                      // ),
                      RouteCardImageIcon(routeContent: routeContent),
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
                            routeContent.availableRoute[0].title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
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
