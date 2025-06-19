import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Components/BottomSheet/Widgets/no_internet_dialog.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
import 'package:onroute_app/Functions/fetch_routes.dart';
import 'package:onroute_app/Functions/file_storage.dart';

class RouteEditButtons extends StatelessWidget {
  const RouteEditButtons({
    super.key,
    required this.currentRoute,
    required this.setSheetWidget,
  });

  final WebMapCollection currentRoute;
  final Function setSheetWidget;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        FilledButton.icon(
          onPressed: () async {
            final List<ConnectivityResult> connectivityResult =
                await (Connectivity().checkConnectivity());
    
            if (connectivityResult.contains(ConnectivityResult.mobile) ||
                connectivityResult.contains(ConnectivityResult.wifi) ||
                connectivityResult.contains(ConnectivityResult.ethernet)) {
              context.loaderOverlay.show();
              // Fetch online items and add them to receivedRoutes, avoiding duplicates
              List<WebMapCollection> receivedRoutes =
                  await fetchOnlineItems(context);
    
              // Check if the route still exists
              if (receivedRoutes.any(
                (test) => test.webmapId == currentRoute.webmapId,
              )) {
                // If so, start the loading
    
                // Get the online version of the route (only one in there...)
                var route = receivedRoutes.firstWhere(
                  (test) =>
                      test.webmapId == currentRoute.webmapId &&
                      test.locally == false,
                );
    
                receivedRoutes.removeWhere(
                  (test) =>
                      test.webmapId == currentRoute.webmapId &&
                      test.locally == true,
                );
    
                // Get ArcGIS route layer data JSON
                await downloadRouteLayer(route, context);
    
                List<WebMapCollection> receivedRoutes2 = await futureRoutes;
                // Fetch online items and add them to receivedRoutes, avoiding duplicates
                receivedRoutes2.removeWhere(
                  (localItem) => localItem.webmapId == route.webmapId,
                );
                receivedRoutes2.add(route);
    
                context.loaderOverlay.hide();
                //LOADING INDICATOR
                await moveSheetTo(0.5);
    
                await setSheetWidget(null, true);
              }
            }
            else{
             noInternetDialog(context);
            }
          },
          icon: const Icon(Icons.update),
          label: Text(
            'Bijwerken Route',
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: Colors.white),
          ),
          iconAlignment: IconAlignment.start,
        ),
    
        TextButton.icon(
          onPressed: () async {
            await deleteRouteInfo(currentRoute.webmapId);
            await moveSheetTo(0.5);
    
            await setSheetWidget(null, true);
          },
          icon: const Icon(Icons.delete),
          label: Text(
            'Verwijder Route',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          iconAlignment: IconAlignment.start,
        ),
      ],
    );
  }
}
