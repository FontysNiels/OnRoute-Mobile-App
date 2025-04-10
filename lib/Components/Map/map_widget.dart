import 'dart:async';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/description_point.dart';

class MapWidget extends StatefulWidget {
  final ArcGISMapViewController mapViewController;
  final GraphicsOverlay graphicsOverlay;
    final List<DescriptionPoint> directionsList;
  const MapWidget({
    super.key,
    required this.mapViewController,
    required this.graphicsOverlay,
    required this.directionsList, 
  });

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
  late final _mapViewController = widget.mapViewController;
  late ArcGISMap _webMap;
  // Create a graphics overlay.
  late final _graphicsOverlay = widget.graphicsOverlay;
  // A flag for when the map view is ready and controls can be used.
  var _ready = false;
  // A flag for when the settings bottom sheet is visible.
  var _settingsVisible = false;
  // Create the system location data source.
  final _locationDataSource = SystemLocationDataSource();
  // A subscription to receive status changes of the location data source.
  StreamSubscription? _statusSubscription;
  var _status = LocationDataSourceStatus.stopped;
  // A subscription to receive changes to the auto-pan mode.
  StreamSubscription? _autoPanModeSubscription;
  var _autoPanMode = LocationDisplayAutoPanMode.compassNavigation;


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
                  ),
                ),
              ],
            ),
            // navigate button
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                heroTag: 'uniqueTagForFAB3',
                onPressed:
                    () => {
                      _mapViewController.locationDisplay.autoPanMode =
                          LocationDisplayAutoPanMode.recenter,
                    },
                child: Icon(Icons.gps_fixed),
              ),
            ),
            // Direction card
            // _directionsList.isNotEmpty
            //     ? DirectionsCard(
            //       directionsList: _directionsList,
            //       routeInfo: _routeInfo,
            //       mapViewController: _mapViewController,
            //     )
            //     : Container(),
            // route buttons
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.end,
            //     children: [
            //       TextButton(
            //         child: Text("Route Toevoegen"),
            //         onPressed: () async {
            //           _graphicsOverlay.graphics.addAll(await initialGraphics());
            //         },
            //       ),
            //       TextButton(
            //         child: Text("Route Verwijderen"),
            //         onPressed: () async {
            //           setState(() {
            //             _directionsList.clear();
            //             _graphicsOverlay.graphics.clear();
            //             _directionsGraphicsOverlay.graphics.clear();
            //           });
            //         },
            //       ),
            //     ],
            //   ),
            // ),

            // Bottomsheet
            // BottomSheetWidget(setRouteGraphics: test),

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
      // The Settings bottom sheet.
      // bottomSheet: _settingsVisible ? buildSettings(context) : null,
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
      // _mapViewController.onScaleChanged.listen((scale) {
      //   _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.navigation;

      // });

      // Add the graphics overlay to the map view.
      _mapViewController.graphicsOverlays.add(_graphicsOverlay);

      // Set an initial viewpoint over the graphics.
      // _mapViewController.graphicsOverlays.add(_directionsGraphicsOverlay);

      _mapViewController.locationDisplay.initialZoomScale = 5000;
      // Set the initial system location data source and auto-pan mode.
      _mapViewController.locationDisplay.dataSource = _locationDataSource;
      _mapViewController.locationDisplay.autoPanMode =
          LocationDisplayAutoPanMode.navigation;
      _mapViewController.locationDisplay.onAutoPanModeChanged.listen((mode) {
        if (mounted) {
          setState(() => _autoPanMode = mode);
        }
      });

      // Setting the location type, probably don't need this later on
      //////////////////////////////////////////////////////////////////////////////////////////
      // Subscribe to status changes and changes to the auto-pan mode.
      _statusSubscription = _locationDataSource.onStatusChanged.listen((
        status,
      ) {
        if (mounted) {
          setState(() => _status = status);
        }
      });
      if (mounted) {
        setState(() => _status = _locationDataSource.status);
        _autoPanModeSubscription = _mapViewController
            .locationDisplay
            .onAutoPanModeChanged
            .listen((mode) {
              if (mounted) {
                setState(() => _autoPanMode = mode);
              }
            });
      }
      if (mounted) {
        setState(
          () => _autoPanMode = _mapViewController.locationDisplay.autoPanMode,
        );
      }
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
