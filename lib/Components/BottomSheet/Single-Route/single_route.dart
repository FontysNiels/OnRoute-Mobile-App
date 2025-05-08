import 'dart:convert';
import 'dart:io';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_image_preview.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_tabs.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_download_button.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_start_button.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_title.dart';
import 'package:onroute_app/Components/BottomSheet/Tabs/tabs_body.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_handle.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/fetch_routes.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/Functions/generate_route_components.dart';
import 'package:onroute_app/main.dart';

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
                PackegImagePreview(routeContent: widget.routeContent),

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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (widget.routeContent.locally) {
                        var storedFile = jsonDecode(
                          await readFile(
                            File(widget.routeContent.availableRoute[0].routeID),
                          ),
                        );
                        RouteLayerData routeInfo = RouteLayerData.fromJson(
                          storedFile,
                        );

                        mapViewController.setViewpoint(
                          Viewpoint.fromJson(routeInfo.viewpoint),
                        );

                        graphicsOverlay.graphics.addAll(
                          await generateLinesAndPoints(routeInfo),
                        );

                        // Add the generated POI points
                        graphicsOverlay.graphics.addAll(
                          generatePoiGraphics(
                            widget.routeContent.pointsOfInterest,
                          ),
                        );

                        preview();
                      } else {
                        //  set viewpoint to the viewpoint
                        mapViewController.setViewpoint(
                          Viewpoint.fromJson(widget.routeContent.viewpoint),
                        );
                        // get route-layer JSON
                        var routeResponse = await getArcgisItemData(
                          widget.routeContent.availableRoute[0].routeID,
                        );
                        // Clean it up
                        RouteLayerData routeInfo = filterRouteInfo(
                          routeResponse,
                          widget.routeContent.availableRoute[0],
                        );
                        // create Lines
                        graphicsOverlay.graphics.addAll(
                          await generateLinesAndPoints(routeInfo),
                        );

                        // Add the generated POI points
                        graphicsOverlay.graphics.addAll(
                          generatePoiGraphics(
                            widget.routeContent.pointsOfInterest,
                          ),
                        );

                        preview();
                      }
                    },
                    icon: const Icon(Icons.map),
                    label: Text(
                      'Route Bekijken',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge!.copyWith(color: Colors.white),
                    ),
                    iconAlignment: IconAlignment.start,
                  ),
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
