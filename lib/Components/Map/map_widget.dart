import 'dart:async';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/main.dart';

class MapWidget extends StatefulWidget {
  final Function selectPoi;
  const MapWidget({super.key, required this.selectPoi});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkLocation();
      if (_locationDataSource.status == LocationDataSourceStatus.started && dialogActive == true) { 
        Navigator.of(context, rootNavigator: true).pop();
        dialogActive = false;
      }
    }
  }

  // Create a GlobalKey for the ArcGISMapView to persist its state.
  final GlobalKey _mapViewKey = GlobalKey();
  // Create a local controller for the map view
  late final _mapViewController = mapViewController;
  // Create a ArcGISMap variable
  late ArcGISMap _webMap;
  // Create a graphics overlay.
  late final _graphicsOverlay = graphicsOverlay;
  // A flag for when the map view is ready and controls can be used.
  var _ready = false;
  // Create the system location data source.
  final _locationDataSource = SystemLocationDataSource();
  // Bool to check if the dialog is active.
  bool dialogActive = false;

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
                            tolerance:
                                10.0, // tolerance in screen points TODO: test for optimal size
                          );

                      if (result.graphics.isNotEmpty) {
                        final tappedGraphic = result.graphics.first;
                        if (tappedGraphic.attributes['objectId'] != null && !previewEnabled) {
                          selectPoi(tappedGraphic.attributes['objectId']);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),

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

      // Attempt to start the location data source (this will prompt the user for permission).
      await checkLocation();

      // Set the ready state variable to true to enable the UI.
      if (mounted) {
        setState(() {
          _ready = true;
        });
      }
    } catch (e) {
      print("Error in onMapViewReady: $e");
    }
  }

  Future<void> checkLocation() async {
    try {
      await _locationDataSource.start();
      print(_locationDataSource.status);
    } on ArcGISException catch (e) {
      if (mounted) {
        if (!dialogActive) {
          showDialog(
            barrierDismissible: false,
            context: context,
            // builder: (_) => AlertDialog(content: Text(e.message)),
            builder:
                (_) => PopScope(
                  canPop: false, // 🔒 Prevents back button to close
                  child: AlertDialog(
                    content: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Use as much height as needed
                      children: [
                        Text(
                          'Geef OnRoute toegang tot uw locatie...',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'De app heeft toegang nodig tot uw locatie.\n\nGa naar de instellingen van uw telefoon om de app toegang te geven tot uw locatie.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
          );
        }
        dialogActive = true;
      }
    }
  }
}
