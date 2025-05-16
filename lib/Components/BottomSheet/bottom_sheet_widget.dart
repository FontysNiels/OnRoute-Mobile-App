import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Components/BottomSheet/Routes-List/routes_list_view.dart';
import 'package:onroute_app/Functions/fetch_routes.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/main.dart';

class BottomSheetWidget extends StatefulWidget {
  final Function startRoute;
  final Function cancelRoute;
  final Function enablePreview;
  const BottomSheetWidget({
    super.key,
    required this.startRoute,
    required this.cancelRoute,
    required this.enablePreview,
  });

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

// Function to cancel the route (made global, so the received setstate function can be used globally)
late Function cancel;
// Function to enable the preview
late Function preview;

/// Scroll controller for the bottom sheet
final ScrollController scrollController = ScrollController();

// List of available routes
late Future<List<WebMapCollection>> futureRoutes;

// Sheet controller
late final DraggableScrollableController _controller;

// Sheet size
double sheetSize = 0.4;

double sheetMinSize = 0.15;

// Global setState function
late Function globalSetState;

// Sheet size animator

// TODO: vaste maten maken, ipv variable double
// Function that animates the sheet to a certain size
Future<void> moveSheetTo(double size) async {
  while (!_controller.isAttached) {
    await Future.delayed(Duration(milliseconds: 50));
  }
  _controller.animateTo(
    size,
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
  await Future.delayed(Duration(milliseconds: 300));
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  void setMinheight(double size) {
    setState(() {
      sheetMinSize = size;
    });
  }

  // List of all the widgets in the bottom sheet
  final List<Widget> _bottomSheetWidgets = [];

  // Function that gets and sets the future routeList
  Future<List<WebMapCollection>> getRouteList() async {
    List<File> localFiles = await getRouteFiles();

    List<WebMapCollection> allAvailableRoutes = [];

    allAvailableRoutes.addAll(await fetchLocalItems(localFiles));

    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet)) {
      allAvailableRoutes.addAll(await fetchOnlineItems(localFiles, context));
    }

    return allAvailableRoutes;
  }

  // Changes the current widget, and has the ability to reload the list of routes
  Future<void> setSheetWidget(Widget? widget, bool? reload) async {
    List<File> localFiles = await getRouteFiles();
    List<WebMapCollection> receivedRoutes = await futureRoutes;
    List<WebMapCollection> localItems = await fetchLocalItems(localFiles);

    setState(() {
      if (widget != null) {
        _bottomSheetWidgets.add(widget);
      } else {
        if (reload == true) {
          receivedRoutes.addAll(
            localItems.where(
              (localItem) =>
                  !receivedRoutes.any(
                    (route) =>
                        route.webmapId == localItem.webmapId &&
                        route.locally == localItem.locally,
                  ),
            ),
          );
          // Remove routes from receivedRoutes where .locally == true and not present in localItems
          receivedRoutes.removeWhere(
            (route) =>
                route.locally == true &&
                !localItems.any(
                  (localItem) => localItem.webmapId == route.webmapId,
                ),
          );
        }
        _bottomSheetWidgets.removeLast();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    globalSetState = setMinheight;
    _controller = DraggableScrollableController();
    cancel = widget.cancelRoute;
    preview = widget.enablePreview;
    futureRoutes = getRouteList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (sheetMinSize != 0.15) {
        await moveSheetTo(sheetMinSize);
      }
    });
    return Stack(
      children: [
        // Persistent bottom sheet
        DraggableScrollableSheet(
          controller: _controller,
          initialChildSize: sheetSize,
          snap: true,
          // TODO: bespreken hoe of wat
          // snapSizes: [0.2, 0.4, 0.6, 0.9],
          // minChildSize: 0.2,
          // During route:
          // snapSizes: [0.15, 0.5, 0.9],
          snapSizes:
              directionList.isNotEmpty
                  ? [sheetMinSize, 0.5, 0.9]
                  : [0.3, 0.5, 0.9],
          minChildSize: directionList.isNotEmpty ? sheetMinSize : 0.3,
          // minChildSize: _bottomSheetWidgets.length > 1 ? 0.15 : 0,
          maxChildSize: 0.9,
          builder: (BuildContext context, scrollController) {
            if (_bottomSheetWidgets.isEmpty) {
              _bottomSheetWidgets.add(
                RoutesListView(
                  scrollController: scrollController,
                  startRoute: widget.startRoute,
                  setSheetWidget: setSheetWidget,
                ),
              );
            }

            return !previewEnabled
                ? Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _bottomSheetWidgets.last,
                  ),
                )
                : Container();
          },
        ),
      ],
    );
  }
}
