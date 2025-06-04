import 'dart:async';
import 'dart:io';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:onroute_app/Classes/description_point.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Components/navigation_buttons.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/Functions/generate_route_components.dart';
import 'package:onroute_app/Components/Map/directions_card.dart';
import 'package:onroute_app/Components/Map/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
// import 'package:onroute_app/theme.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    print("COOLE SHIT: ${details}");
  };
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

const Color primaryAppColor = Color.fromARGB(255, 255, 154, 154);
const Color primaryAccent = Color.fromARGB(255, 255, 0, 0);
const Color primaryTextColor = Color.fromARGB(255, 73, 69, 79);

/// Global Variables ///
///  --------------- ///
// Graphics which go on the map
final graphicsOverlay = GraphicsOverlay();
// Controller that controlls the map
final mapViewController = ArcGISMapView.createController();
// List of directions (only filled when route is started)
List<DescriptionPoint> directionList = [];
// Route-Layer (ArcGIS) JSON data as a class, along with some other data
late RouteLayerData routeInfo;
// Distance to finish
double disrabceToFinish = 0.0;
// Setting for notification sound
bool enabledNotifiation = true;
// The POI that the user has selected (used by: TripInfoBar)
int selectedPOI = 0;
// Condition showing if the user changed the selected POI
bool currenPOIChanged = false;
// Condition to show appbar (to close preview)
bool previewEnabled = false;
// Value used to check update in POI faster, need to remove 'currenPOIChanged' variable
ValueNotifier<bool> currentPOIChanged = ValueNotifier<bool>(false);
// ItemID of ArcGIS map
const mapItemId = '50dd5ef186644d91902c2e77ddd7c414';
// ItemID of POI file
const poiItemId = '1c049e864f1643bda530ae45fd1591cf';



/// Global Functions ///
///  --------------- ///

// Initialzes the ArcGIS API key
Future<void> initialize() async {
  await dotenv.load(fileName: ".env");
  // gets and sets API key from .env file
  String apiKey = dotenv.env['API_KEY'] ?? 'default_api_key';
  // sets the API key for the ArcGIS environment
  ArcGISEnvironment.apiKey = apiKey;

  ArcGISEnvironment.setLicenseUsingKey(
    'runtimelite,1000,rud8789963649,none,KGE60RFLTFK2J9HSX228',
  );
}

// Set the selectedPOI and its changed condition
void selectPoi(int selectedPoiObjectId) {
  selectedPOI = selectedPoiObjectId;
  currenPOIChanged = true;
  currentPOIChanged.value = currenPOIChanged;
}

// Function to copy the asset to a file and use it as map
Future<void> addMMPK() async {
  File file = await copyAssetToFile('assets/MMP.mmpk', 'MMP.mmpk');
  // Load the local mobile map package File.
  final mmpk = MobileMapPackage.withFileUri(file.uri);
  // Load the mobile map package.
  await mmpk.load();
  // Check if the mobile map package has loaded successfully.
  if (mmpk.maps.isNotEmpty) {
    // Use only MMPK, this is used when there is no map set (aka when offline)
    if (mapViewController.arcGISMap == null) {
      mapViewController.arcGISMap = mmpk.maps.first;
      mapViewController
          .arcGISMap
          ?.initialViewpoint = Viewpoint.withLatLongScale(
        latitude: 51.598289,
        longitude: 5.528469,
        scale: 10000,
      );
    }
    // Overlay the MMPK on the map view
    else if (mapViewController.arcGISMap?.item?.itemId !=
        mmpk.maps.first.item?.itemId) {
      final map = mmpk.maps.first;
      mapViewController.arcGISMap?.operationalLayers.addAll(
        map.operationalLayers,
      );
    }
  }
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    // Initialize the ArcGIS API key
    initialize();
    // Clears the MMPK in case it is still loaded
    clearMMPKStorage();
    // Locks Orientation
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.initState();
  }

  /// Function which starts a route
  Future<void> _startRoute(RouteLayerData route, List<Poi> pois) async {
    // Add the generated route lines
    graphicsOverlay.graphics.addAll(await generateLinesAndPoints(route));
    // Add the generated POI points
    graphicsOverlay.graphics.addAll(await generatePoiGraphics(pois));
    // The list which will be filled with descriptionPoints
    List<DescriptionPoint> routeDirections = [];
    // Loop that loops through all the descriptions
    for (var element in route.layers[2].featureSet.features) {
      // Null check
      if (element.geometry.x == null) {
        continue;
      }
      // X of the description point
      final parsedX = element.geometry.x;
      // Y of the description point
      final parsedY = element.geometry.y;

      // Adding the descriptionPoint to the list
      routeDirections.add(
        DescriptionPoint(
          description: element.attributes['DisplayText'],
          x: parsedX!,
          y: parsedY!,
          angle: element.attributes['Azimuth'].toDouble(),
        ),
      );
      mapViewController.locationDisplay.autoPanMode =
          LocationDisplayAutoPanMode.compassNavigation;
    }

    // Setting the routeInfo and directionPoints (refreshing the state)
    setState(() {
      routeInfo = route;
      directionList = routeDirections;
    });
  }

  /// Function that cancels the route
  void _cancelRoute() {
    // Setting the state and clearing every important variable (refreshing the state)
    setState(() {
      directionList.clear();
      graphicsOverlay.graphics.clear();
      selectedPOI = 0;
    });
  }

  void _enablePreview() {
    // Setting the state and clearing every important variable (refreshing the state)
    setState(() {
      if (previewEnabled) {
        graphicsOverlay.graphics.clear();
        mapViewController.setViewpointRotation(angleDegrees: 0.0);
        mapViewController.locationDisplay.autoPanMode =
            LocationDisplayAutoPanMode.recenter;
      }
      previewEnabled = !previewEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Color variables, you can add more if needed (makes things easier to control, not necessary though)

    return MaterialApp(
      // theme: AppTheme,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Makes the app use Material Design 3
        useMaterial3: true,

        // Color Scheme Changes
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryAccent, // Define primaryAccent in color scheme
        ),

        // Appbar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryAppColor,
          scrolledUnderElevation: 1,
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryAppColor,
          // foregroundColor:
        ),

        // SeachBar Theme
        searchBarTheme: SearchBarThemeData(
          backgroundColor: WidgetStateProperty.all(primaryAppColor),
          elevation: WidgetStateProperty.all(0.0),
        ),

        // Elevated Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 248, 248, 248),
            // foregroundColor: Colors.white,
            iconColor: primaryAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          ),
        ),

        // Card Theme
        cardTheme: const CardTheme(
          color: primaryAppColor,
          // elevation: 0,
        ),

        // TabBar Theme
        tabBarTheme: const TabBarTheme(
          labelColor: primaryAccent,
          unselectedLabelColor: primaryTextColor,
        ),

        // Devider Theme
        dividerTheme: const DividerThemeData(color: primaryAppColor),

        //Text Theme's (variables inside are the default Material Design text varaibles)
        textTheme: TextTheme(
          bodyLarge: const TextStyle(),
          bodyMedium: const TextStyle(color: primaryTextColor),
          labelLarge: const TextStyle(color: primaryAccent),
        ),
      ),
      home: Scaffold(
        appBar:
            previewEnabled
                ? AppBar(
                  title: Text("Terug naar informatie"),
                  leading: IconButton(
                    onPressed: _enablePreview,
                    icon: Icon(Icons.arrow_back),
                  ),
                )
                : null,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // The Map
            MapWidget(selectPoi: selectPoi),
            // Direction card (if the directionsList isn't empty)
            Column(
              children: [
                directionList.isNotEmpty ? DirectionsCard() : Container(),

                NavigationButtons(),
              ],
            ),
            // Bottomsheet, with loader wrapped over it (so when it downloads a route the user can't fuck it up)
            LoaderOverlay(
              child: BottomSheetWidget(
                startRoute: _startRoute,
                cancelRoute: _cancelRoute,
                enablePreview: _enablePreview,
              ),
            ),

            // OfflineMapDownloadExample(),
          ],
        ),
      ),
    );
  }
}
