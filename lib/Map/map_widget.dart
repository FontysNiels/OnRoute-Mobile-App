import 'dart:async';
import 'dart:math';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> initialize() async {
  await dotenv.load(fileName: ".env");
  // gets and sets API key from .env file
  String apiKey = dotenv.env['API_KEY'] ?? 'default_api_key';
  // sets the API key for the ArcGIS environment
  ArcGISEnvironment.apiKey = apiKey;
}

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  void initState() {
    super.initState();
    // requestLocationPermission();
    initialize();
  }

  // create a controller for the map view
  final _mapViewController = ArcGISMapView.createController();

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
  // A flag for when the map view is ready and controls can be used.
  var _ready = false;

  @override
  void dispose() {
    // When exiting, stop the location data source and cancel subscriptions.
    _locationDataSource.stop();
    _statusSubscription?.cancel();
    _autoPanModeSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(_ready);
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
                    controllerProvider: () => _mapViewController,
                    onMapViewReady: onMapViewReady,
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        _status == LocationDataSourceStatus.failedToStart
                            ? null
                            : () => setState(() => _settingsVisible = true),
                    child: const Text('Location Settings'),
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

            Align(
              alignment: Alignment.topRight,
              child: FloatingActionButton(
                onPressed:
                    () => {
                      _mapViewController.locationDisplay.autoPanMode =
                          LocationDisplayAutoPanMode.recenter,
                    },
                child: Icon(Icons.gps_fixed),
              ),
            ),
          ],
        ),
      ),
      // The Settings bottom sheet.
      bottomSheet: _settingsVisible ? buildSettings(context) : null,
    );
  }

  Widget buildSettings(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.0,
        20.0,
        20.0,
        max(
          20.0,
          View.of(context).viewPadding.bottom /
              View.of(context).devicePixelRatio,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Location Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _settingsVisible = false),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Show Location'),
              const Spacer(),
              // A switch to start and stop the location data source.
              Switch(
                value: _status == LocationDataSourceStatus.started,
                onChanged: (_) {
                  if (_status == LocationDataSourceStatus.started) {
                    _mapViewController.locationDisplay.stop();
                  } else {
                    _mapViewController.locationDisplay.start();
                  }
                },
              ),
            ],
          ),
          Row(
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
          ),
        ],
      ),
    );
  }

  Future<void> onMapViewReady() async {
    // print("onMapViewReady called");
    try {
      // set the map to the map view controller

      final map = ArcGISMap.withBasemapStyle(
        BasemapStyle.arcGISChartedTerritory,
      );
      _mapViewController.arcGISMap = map;
      // print("Map set to map view controller");
      // set the viewpoint of the map view controller (BraGIS, HEEL ver uitgezoomed, dus je start op nederland)
      _mapViewController.setViewpoint(
        Viewpoint.withLatLongScale(
          latitude: 51.598289,
          longitude: 5.528469,
          scale: 25000,
        ),
      );

      // _mapViewController.onScaleChanged.listen((scale) {
      //   _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.navigation;

      // });

      // Create a map with the Navigation Night basemap style.
      // _mapViewController.arcGISMap = ArcGISMap.withBasemapStyle(
      //   BasemapStyle.arcGISNavigationNight,
      // );

      _mapViewController.locationDisplay.initialZoomScale = 5000;
      // Set the initial system location data source and auto-pan mode.
      _mapViewController.locationDisplay.dataSource = _locationDataSource;
      _mapViewController.locationDisplay.autoPanMode =
          LocationDisplayAutoPanMode.navigation;
      _mapViewController.locationDisplay.onAutoPanModeChanged.listen((mode) {
        setState(() => _autoPanMode = mode);
      });

      // Subscribe to status changes and changes to the auto-pan mode.
      _statusSubscription = _locationDataSource.onStatusChanged.listen((
        status,
      ) {
        setState(() => _status = status);
      });
      setState(() => _status = _locationDataSource.status);
      _autoPanModeSubscription = _mapViewController
          .locationDisplay
          .onAutoPanModeChanged
          .listen((mode) {
            setState(() => _autoPanMode = mode);
          });
      setState(
        () => _autoPanMode = _mapViewController.locationDisplay.autoPanMode,
      );

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
      setState(() {
        _ready = true;
        // print("_ready set to true");
      });
    } catch (e) {
      print("Error in onMapViewReady: $e");
    }
  }
}
