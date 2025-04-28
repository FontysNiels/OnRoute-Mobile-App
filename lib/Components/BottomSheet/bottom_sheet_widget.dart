import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/TESTCLASS.dart';
import 'package:onroute_app/Components/BottomSheet/Routes-List/routes_list_view.dart';
import 'package:onroute_app/Functions/fetch_routes.dart';
import 'package:onroute_app/Functions/file_storage.dart';


class BottomSheetWidget extends StatefulWidget {
  final Function startRoute;
  const BottomSheetWidget({super.key, required this.startRoute});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

/// Scroll controller for the bottom sheet
final ScrollController scrollController = ScrollController();

// List of available routes
late Future<List<WebMapCollection>> _futureRoutes;
Future<List<WebMapCollection>> getRoutes() {
  return _futureRoutes;
}

// Sheet controller
late final DraggableScrollableController _controller;
// Sheet size
double sheetSize = 0.4;
// Sheet size animator
// TODO: vaste maten maken, ipv variable double
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
  // List of all the widgets in the bottom sheet
  List<Widget> bottomSheetWidgets = [];

  // Changes the current widget, and has the ability to reload the list of routes
  Future<void> setSheetWidget(Widget? widget, bool? reload) async {
    List<File> localFiles = await getRouteFiles();
    List<WebMapCollection> futureRoutes = await _futureRoutes;
    List<WebMapCollection> localItems = await fetchLocalItems(localFiles);

    setState(() {
      if (widget != null) {
        bottomSheetWidgets.add(widget);
      } else {
        if (reload == true) {
          futureRoutes.addAll(
            localItems.where(
              (localItem) =>
                  !futureRoutes.any(
                    (route) =>
                        route.webmapId == localItem.webmapId &&
                        route.locally == localItem.locally,
                  ),
            ),
          );
        }
        bottomSheetWidgets.removeLast();
      }
    });
  }

  Future<List<WebMapCollection>> getRouteList() async {
    List<File> localFiles = await getRouteFiles();

    List<WebMapCollection> allAvailableRoutes = [];

    allAvailableRoutes.addAll(await fetchLocalItems(localFiles));

    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      allAvailableRoutes.addAll(await fetchOnlineItems(localFiles, context));
    }

    return allAvailableRoutes;
  }

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
    _futureRoutes = getRouteList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              bottomSheetWidgets.length > 1
                  ? [0.15, 0.5, 0.9]
                  : [0.3, 0.5, 0.9],
          minChildSize: bottomSheetWidgets.length > 1 ? 0.15 : 0.3,
          maxChildSize: 0.9,
          builder: (BuildContext context, scrollController) {
            if (bottomSheetWidgets.isEmpty) {
              bottomSheetWidgets.add(
                RoutesListView(
                  scrollController: scrollController,
                  startRoute: widget.startRoute,
                  changesheetsize: moveSheetTo,
                  setSheetWidget: setSheetWidget,
                ),
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
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
                child: bottomSheetWidgets.last,
              ),
            );
          },
        ),
      ],
    );
  }
}
