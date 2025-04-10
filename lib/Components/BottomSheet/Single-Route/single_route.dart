import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_image_preview.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_tabs.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_download_button.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_start_button.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_title.dart';
import 'package:onroute_app/Components/BottomSheet/Tabs/tabs_body.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_handle.dart';

class SingleRoute extends StatefulWidget {
  final AvailableRoutes routeContent;
  final Function startRoute;
  final ScrollController scroller;
  const SingleRoute({
    super.key,
    required this.routeContent,
    required this.startRoute,
    required this.scroller,
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
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   automaticallyImplyLeading: false,
        //   // leading: RouteTitle(title: widget.routeContent.routeLayer.title),
        //   // leading: IconButton(
        //   //   icon: const Icon(Icons.assist_walker),
        //   //   onPressed: () {
        //   //     Navigator.pop(context, true);
        //   //   },
        //   // ),
        //   title: SingleChildScrollView(
        //     controller: widget.scroller,

        //     // child: const Row(
        //     //   mainAxisAlignment: MainAxisAlignment.end,
        //     //   spacing: 26,
        //     //   children: [Icon(Icons.info_outline), Icon(Icons.more_vert)],
        //     // ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.start,
        //       // spacing: 6,
        //       children: [
        //         Text(widget.routeContent.routeLayer.title + "sssssdds d sdsdsd", overflow: textove,),
        //         IconButton.filled(
        //           icon: Icon(Icons.close),
        //           onPressed: () {
        //             Navigator.pop(context, true);
        //           },
        //           style: ButtonStyle(
        //             backgroundColor: WidgetStateProperty.all(
        //               Theme.of(context).primaryColor.withValues(alpha: 0.5),
        //             ),
        //             // foregroundColor: WidgetStateProperty.all(
        //             //   Colors.white,
        //             // ), // Adjust the icon color if needed
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: widget.scroller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BottomSheetHandle(context: context),
                // Title
                Row(
                  spacing: 6,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: RouteTitle(
                          title: widget.routeContent.routeLayer.title,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 6,
                      ),
                      child: IconButton.filled(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Images (PACKAGE ONLY)
                const PackegImagePreview(),

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
                // // Body of tabs
                TabsBody(
                  selectedIndex: _selectedIndex,
                  routeInfo: widget.routeContent.routeLayer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
