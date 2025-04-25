import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/TESTCLASS.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_image_preview.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_tabs.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_download_button.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_start_button.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_title.dart';
import 'package:onroute_app/Components/BottomSheet/Tabs/tabs_body.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_handle.dart';

class SingleRoute extends StatefulWidget {
  final WebMapCollection routeContent;
  final Function startRoute;
  final ScrollController scroller;
  final Function setSheetWidget;
  const SingleRoute({
    super.key,
    required this.routeContent,
    required this.startRoute,
    required this.scroller,
    required this.setSheetWidget,
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

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            controller: widget.scroller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: BottomSheetHandle(context: context),
                ),
                // Title
                RouteTitle(
                  title: widget.routeContent.availableRoute[0].title,
                  setSheetWidget: widget.setSheetWidget,
                ),

                // Images (PACKAGE ONLY)
                PackegImagePreview(
                  description:
                      widget.routeContent.availableRoute[0].description,
                ),

                // Download Button
                !widget.routeContent.locally
                    ? RouteDownloadButton(
                      currentRoute: widget.routeContent,
                      setSheetWidget: widget.setSheetWidget,
                      
                    )
                    : RouteStartButton(
                      routeContent: widget.routeContent,
                      startRoute: widget.startRoute,
                      setSheetWidget: widget.setSheetWidget,
                      scroller: widget.scroller,
                    ),
                // Tabs
                // Make one for Routes, or make it dynamic?
                PackageTabs(setIndex: setIndex, isPackage: false),
                // // Body of tabs
                TabsBody(
                  selectedIndex: _selectedIndex,
                  routeDescription:
                      widget.routeContent.availableRoute[0].description,
                  currentRoute: widget.routeContent,
                  scroller: widget.scroller,
                  setSheetWidget: widget.setSheetWidget,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
