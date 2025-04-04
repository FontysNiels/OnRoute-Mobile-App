import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_image_preview.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_tabs.dart';
import 'package:onroute_app/Routes/Widgets/Single%20Route/route_download_button.dart';
import 'package:onroute_app/Routes/Widgets/Single%20Route/route_start_button.dart';
import 'package:onroute_app/Routes/Widgets/Single%20Route/route_title.dart';
import 'package:onroute_app/Routes/Widgets/Tabs/tabs_body.dart';
import 'package:onroute_app/main.dart';

class SingleRoute extends StatefulWidget {
  // final Function startRoute;
  final AvailableRoutes routeContent;
  // final Function setRouteGraphics;
  const SingleRoute({
    super.key,
    required this.routeContent,
    // required this.setRouteGraphics,
    // required this.startRoute,
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

    // generateLinesAndPoints(widget.routeContent.routeLayer);
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
              : RouteStartButton(routeContent: widget.routeContent),
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
