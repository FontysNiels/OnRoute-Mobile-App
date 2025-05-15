import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Components/Map/map_widget.dart';
import 'package:onroute_app/main.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationAwareMap extends StatefulWidget {
@override
_LocationAwareMapState createState() => _LocationAwareMapState();
}

enum AppPermissionStatus { denied, granted, permanentlyDenied }

class _LocationAwareMapState extends State<LocationAwareMap>
  with WidgetsBindingObserver {
final GlobalKey _mapViewKey = GlobalKey();
// Create a controller for the map view.
ArcGISMapViewController _mapViewController = mapViewController;

// Create the system location data source.
late final _locationDataSource = SystemLocationDataSource();
// A flag for when the map view is ready and controls can be used.
var _ready = false;
//Track the app’s location permission state.
var _locationPermission = AppPermissionStatus.denied;
var _appSettingOpened = false;

@override
void initState() {
  // Add the app lifecycle observer.
  WidgetsBinding.instance.addObserver(this);
  if (_locationPermission != AppPermissionStatus.granted) {
    initLocationPermissions();
  }

  _mapViewController.locationDisplay.onLocationChanged.listen((mode) async {
    print(_mapViewController.locationDisplay.location!.position);
  });
  super.initState();
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);
  if (state == AppLifecycleState.resumed && _appSettingOpened) {
    // Recheck location permissions only if settings were opened.
    initLocationPermissions();
  }
}

Future<void> initLocationPermissions() async {
  final status = await Permission.location.status;
  switch (status) {
    case PermissionStatus.granted:
      setState(() {
        _locationPermission = AppPermissionStatus.granted;
        _ready = false;
      });
      break;
    case PermissionStatus.permanentlyDenied:
      setState(
        () => _locationPermission = AppPermissionStatus.permanentlyDenied,
      );
      break;
    case PermissionStatus.denied:
    default:
      setState(() => _locationPermission = AppPermissionStatus.denied);
      break;
  }
}

@override
Widget build(BuildContext context) {
  // WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     _mapViewController.locationDisplay.onLocationChanged.listen((mode) async {
  //   print(_mapViewController.locationDisplay.location!.position);
  // });
  // });
  return Scaffold(
    body: SafeArea(
      top: false,
      child: Builder(
        builder: (_) {
          switch (_locationPermission) {
            case AppPermissionStatus.granted:
              return _buildMapView(); // Widget to show map view
            case AppPermissionStatus.denied:
              return _buildRequestLocationButton(); // Widget to request location
            case AppPermissionStatus.permanentlyDenied:
              return _buildSettingsWidget(); // Widget to open app settings
          }
        },
      ),
    ),
  );
}

void _onMapViewReady() async {
  
  // Create a map with the Navigation Night basemap style.
  _mapViewController.arcGISMap = ArcGISMap.withBasemapStyle(
    BasemapStyle.arcGISNavigationNight,
  );

  // Set the initial system location data source.

  _mapViewController.locationDisplay.dataSource = _locationDataSource;

  // Set the initial system location auto-pan mode.
  _mapViewController.locationDisplay.autoPanMode =
      LocationDisplayAutoPanMode.recenter;

  // Attempt to start the location data source (this will prompt the user for permission).
  try {
    await _locationDataSource.start();
    _mapViewController?.locationDisplay.start();
  } on ArcGISException catch (e) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(content: Text(e.message)),
      );
    }
  }
  if (mapViewController.locationDisplay.location!= null) {
    print(mapViewController.locationDisplay.location!.position.y);
  }
  // Set the ready state variable to true to enable the UI.
  setState(() => _ready = true);
}

Widget _buildMapView() => Stack(
  children: [
    ArcGISMapView(
      key: _mapViewKey,
      controllerProvider: () => _mapViewController,
      onMapViewReady: _onMapViewReady,
    ),

    // Display a progress indicator until the map is ready.
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
);

Widget _buildRequestLocationButton() => Center(
  child: ElevatedButton(
    onPressed: requestLocationPermissions, // Requests permission
    child: const Text('Enable Location'),
  ),
);

Future<void> requestLocationPermissions() async {
  final requestPermission = await Permission.location.request();
  if (requestPermission.isGranted) {
    setState(() {
      _locationPermission = AppPermissionStatus.granted;
      _ready = false;
    });
  } else if (requestPermission.isPermanentlyDenied) {
    setState(
      () => _locationPermission = AppPermissionStatus.permanentlyDenied,
    );
  } else {
    setState(() => _locationPermission = AppPermissionStatus.denied);
  }
}

Widget _buildSettingsWidget() => const Center(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'App location permission is denied. Go to settings and enable location to use the app.',
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 15),
      ElevatedButton(
        onPressed: openAppSettings, // Opens app settings to change permission
        child: Text('Open App Settings'),
      ),
    ],
  ),
);

@override
void dispose() {
  // Remove the app lifecycle observer.
  WidgetsBinding.instance.removeObserver(this);
  // Stop location updates when the widget is disposed.
  _locationDataSource.stop();
  _mapViewController.dispose();
  super.dispose();
}
}
