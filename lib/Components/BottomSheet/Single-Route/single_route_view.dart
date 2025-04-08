import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_image_preview.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_tabs.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_download_button.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_start_button.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_title.dart';
import 'package:onroute_app/Components/BottomSheet/Tabs/tabs_body.dart';

class RouteView extends StatefulWidget {
  final ScrollController scrollController;
  final Function startRoute;
  final AvailableRoutes selectedRoute;

  const RouteView({
    super.key,
    required this.scrollController,
    required this.startRoute,
    required this.selectedRoute,
  });

  @override
  State<RouteView> createState() => _RouteViewState();
}

int _selectedIndex = 0;

class _RouteViewState extends State<RouteView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void setIndex(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          RouteTitle(title: widget.selectedRoute.routeLayer.title),
          // Images (PACKAGE ONLY)
          const PackegImagePreview(),

          // // Download Button
          // !widget.selectedRoute.locally
          //     ? RouteDownloadButton(routeID: widget.selectedRoute)
          //     : RouteStartButton(
          //       routeContent: widget.selectedRoute,
          //       startRoute: widget.startRoute,
          //     ),
          // // Tabs
          // // Make one for Routes, or make it dynamic?
          // PackageTabs(setIndex: setIndex, isPackage: false),
          // // Body of tabs
          // TabsBody(selectedIndex: _selectedIndex),
        ],
      ),
    );
  }
}
