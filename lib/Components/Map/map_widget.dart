import 'dart:async';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/description_point.dart';
import 'package:onroute_app/main.dart';

class MapWidget extends StatefulWidget {
  final Function selectPoi;
  const MapWidget({super.key, required this.selectPoi});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  // Create a GlobalKey for the ArcGISMapView to persist its state.
  final GlobalKey _mapViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // create a controller for the map view
  late final _mapViewController = mapViewController;
  late ArcGISMap _webMap;
  // Create a graphics overlay.
  late final _graphicsOverlay = graphicsOverlay;
  // A flag for when the map view is ready and controls can be used.
  var _ready = false;
  // A flag for when the settings bottom sheet is visible.
  // var _settingsVisible = false;
  // Create the system location data source.
  final _locationDataSource = SystemLocationDataSource();
  // A subscription to receive status changes of the location data source.
  // StreamSubscription? _statusSubscription;
  // var _status = LocationDataSourceStatus.stopped;
  // A subscription to receive changes to the auto-pan mode.
  // StreamSubscription? _autoPanModeSubscription;
  // var _autoPanMode = LocationDisplayAutoPanMode.compassNavigation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  // Add a map view to the widget tree and set a controller.
                  child: ArcGISMapView(
                    key: _mapViewKey, // Use the GlobalKey here
                    controllerProvider: () => _mapViewController,
                    onMapViewReady: onMapViewReady,
                    onTap: (Offset screenPoint) async {
                      final result = await _mapViewController
                          .identifyGraphicsOverlay(
                            _graphicsOverlay,
                            screenPoint: screenPoint,
                            tolerance: 10.0, // tolerance in screen points
                          );

                      if (result.graphics.isNotEmpty) {
                        final tappedGraphic = result.graphics.first;
                        if (tappedGraphic.attributes['objectId'] != null) {
                          selectPoi(tappedGraphic.attributes['objectId']);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            // navigate button
            // Padding(
            //   padding: EdgeInsets.only(
            //     top: MediaQuery.of(context).padding.top,
            //     left: 6,
            //     right: 6,
            //   ),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.end,
            //     spacing: 12,
            //     children: [
            //       FloatingActionButton(
            //         heroTag: UniqueKey(),
            //         onPressed:
            //             () => {
            //               _mapViewController.locationDisplay.autoPanMode =
            //                   LocationDisplayAutoPanMode.recenter,
            //             },
            //         child: Icon(Icons.gps_fixed),
            //       ),
            //       FloatingActionButton(
            //         heroTag: UniqueKey(),
            //         onPressed:
            //             () => {
            //               _mapViewController.locationDisplay.autoPanMode =
            //                   // LocationDisplayAutoPanMode.compassNavigation,
            //                   LocationDisplayAutoPanMode.navigation,
            //             },
            //         child: Icon(Icons.compass_calibration),
            //       ),
            //       FloatingActionButton(
            //         heroTag: UniqueKey(),
            //         onPressed:
            //             () => {
            //               _mapViewController.locationDisplay.autoPanMode =
            //                   LocationDisplayAutoPanMode.recenter,
            //             },
            //         child: Icon(Icons.notifications),
            //       ),
            //     ],
            //   ),
            // ),

            // Display a progress indicator and prevent interaction until state is ready.
            Visibility(
              visible: !_ready,
              child: SizedBox.expand(
                child: Container(
                  color: Colors.white30,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onMapViewReady() async {
    // print("onMapViewReady called");
    try {
      // set the map to the map view controller
      _mapViewController.setViewpoint(
        Viewpoint.withLatLongScale(
          latitude: 51.598289,
          longitude: 5.528469,
          scale: 25000,
        ),
      );

      PortalConnection connection = PortalConnection.anonymous;
      final portalItem = PortalItem.withPortalAndItemId(
        // portal: portal,
        portal: Portal(
          Uri.parse('https://gisportal.bragis.nl/arcgis'),
          connection: connection,
        ),
        itemId: '50dd5ef186644d91902c2e77ddd7c414',
      );

      _webMap = ArcGISMap.withItem(portalItem);
      _mapViewController.arcGISMap = _webMap;

      // await downloadSampleData(['5f52e970830a4140bec9d69317d1399f']);
      // // await downloadSampleData(['b75f95c720204d78b1eed8f98ccbe0d9']);
      // final appDir = await getApplicationDocumentsDirectory();

      // // Load the local mobile map package.
      // final mmpkFile = File('${appDir.absolute.path}/offlinemap.mmpk');
      // // final mmpkFile = File('${appDir.absolute.path}/MMP.mmpk');
      // final mmpk = MobileMapPackage.withFileUri(mmpkFile.uri);
      // await mmpk.load();

      // if (mmpk.maps.isNotEmpty) {
      //   // Get the first map in the mobile map package and set to the map view.

      //   _mapViewController.arcGISMap = mmpk.maps.first;
      // }

      // _mapViewController.onScaleChanged.listen((scale) {
      //   _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.navigation;

      // });

      // Add the graphics overlay to the map view.
      _mapViewController.graphicsOverlays.add(_graphicsOverlay);

      _mapViewController.locationDisplay.initialZoomScale = 5000;
      // Set the initial system location data source and auto-pan mode.
      _mapViewController.locationDisplay.dataSource = _locationDataSource;
      _mapViewController.locationDisplay.autoPanMode =
          LocationDisplayAutoPanMode.navigation;
      // _mapViewController.locationDisplay.onAutoPanModeChanged.listen((mode) {
      //   if (mounted) {
      //     setState(() => _autoPanMode = mode);
      //   }
      // });

      // Setting the location type, probably don't need this later on
      //////////////////////////////////////////////////////////////////////////////////////////
      // Subscribe to status changes and changes to the auto-pan mode.
      // _statusSubscription = _locationDataSource.onStatusChanged.listen((
      //   status,
      // ) {
      //   if (mounted) {
      //     setState(() => _status = status);
      //   }
      // });
      // if (mounted) {
      //   setState(() => _status = _locationDataSource.status);
      //   _autoPanModeSubscription = _mapViewController
      //       .locationDisplay
      //       .onAutoPanModeChanged
      //       .listen((mode) {
      //         if (mounted) {
      //           setState(() => _autoPanMode = mode);
      //         }
      //       });
      // }
      // if (mounted) {
      //   setState(
      //     () => _autoPanMode = _mapViewController.locationDisplay.autoPanMode,
      //   );
      // }
      //////////////////////////////////////////////////////////////////////////////////////////

      // Attempt to start the location data source (this will prompt the user for permission).
      try {
        await _locationDataSource.start();
      } on ArcGISException catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(content: Text(e.message)),
          );
        }
      }

      // Set the ready state variable to true to enable the UI.
      if (mounted) {
        setState(() {
          _ready = true;
          // print("_ready set to true");
        });
      }
    } catch (e) {
      print("Error in onMapViewReady: $e");
    }
  }
}

class locationsettings extends StatelessWidget {
  const locationsettings({
    super.key,
    required LocationDisplayAutoPanMode autoPanMode,
    required ArcGISMapViewController mapViewController,
  }) : _autoPanMode = autoPanMode,
       _mapViewController = mapViewController;

  final LocationDisplayAutoPanMode _autoPanMode;
  final ArcGISMapViewController _mapViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Auto-Pan Mode'),
        const Spacer(),
        // A dropdown button to select the auto-pan mode.
        DropdownButton(
          value: _autoPanMode,
          onChanged: (value) {
            _mapViewController.locationDisplay.autoPanMode = value!;
          },
          items: const [
            DropdownMenuItem(
              value: LocationDisplayAutoPanMode.off,
              child: Text('Off'),
            ),
            DropdownMenuItem(
              value: LocationDisplayAutoPanMode.recenter,
              child: Text('Recenter'),
            ),
            DropdownMenuItem(
              value: LocationDisplayAutoPanMode.navigation,
              child: Text('Navigation'),
            ),
            DropdownMenuItem(
              value: LocationDisplayAutoPanMode.compassNavigation,
              child: Text('Compass'),
            ),
          ],
        ),
      ],
    );
  }
}
