import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Components/BottomSheet/Widgets/no_internet_dialog.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
import 'package:onroute_app/Functions/file_storage.dart';

class RouteDownloadButton extends StatelessWidget {
  final WebMapCollection currentRoute;
  final Function setSheetWidget;

  const RouteDownloadButton({
    super.key,
    required this.currentRoute,
    required this.setSheetWidget,
  });

  @override
  Widget build(BuildContext context) {
    // print(currentRoute.availableRoute);
    currentRoute.availableRoute[0];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: FilledButton.icon(
        onPressed: () async {
          final List<ConnectivityResult> connectivityResult =
              await (Connectivity().checkConnectivity());

          if (connectivityResult.contains(ConnectivityResult.none)) {
           noInternetDialog(context);
          } else {
            context.loaderOverlay.show();

            // (als package) check of route al eerder is gedownload
            await downloadRouteLayer(currentRoute, context);

            context.loaderOverlay.hide();
            //LOADING INDICATOR
            await moveSheetTo(0.5);

            await setSheetWidget(null, true);
          }
        },
        icon: const Icon(Icons.download),
        label: Text(
          'Download route',
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: Colors.white),
        ),
        iconAlignment: IconAlignment.start,
      ),
    );
  }
}
