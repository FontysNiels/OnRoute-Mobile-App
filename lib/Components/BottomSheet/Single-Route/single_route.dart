import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_image_preview.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_tabs.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_download_button.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_start_button.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_title.dart';
import 'package:onroute_app/Components/BottomSheet/Tabs/tabs_body.dart';

class SingleRoute extends StatefulWidget {
  final AvailableRoutes routeContent;
  final Function startRoute;
  const SingleRoute({
    super.key,
    required this.routeContent,
    required this.startRoute,
  });

  @override
  State<SingleRoute> createState() => _SingleRouteState();
}

int _selectedIndex = 0;

class _SingleRouteState extends State<SingleRoute> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void setIndex(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 26,
          children: [Icon(Icons.info_outline), Icon(Icons.more_vert)],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          RouteTitle(title: widget.routeContent.routeLayer.title),
          // Images (PACKAGE ONLY)
          PackegImagePreview(),

          // Download Button
          !widget.routeContent.locally
              ? RouteDownloadButton(routeID: widget.routeContent)
              : RouteStartButton(
                routeContent: widget.routeContent,
                startRoute: widget.startRoute,
              ),
          // Tabs
          // Make one for Routes, or make it dynamic?
          PackageTabs(setIndex: setIndex, isPackage: false),
          // Body of tabs
          TabsBody(selectedIndex: _selectedIndex),
        ],
      ),
    );
  }
}
