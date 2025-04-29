import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:onroute_app/Classes/description_point.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/Functions/generate_route_components.dart';
import 'package:onroute_app/Components/Map/directions_card.dart';
import 'package:onroute_app/Components/Map/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
// import 'package:onroute_app/theme.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    // print("COOLE SHIT: ${details}");
    // Log or handle the error details
  };
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

Future<void> initialize() async {
  await dotenv.load(fileName: ".env");
  // gets and sets API key from .env file
  String apiKey = dotenv.env['API_KEY'] ?? 'default_api_key';
  // sets the API key for the ArcGIS environment
  ArcGISEnvironment.apiKey = apiKey;
}

final _graphicsOverlay = GraphicsOverlay();

final _mapViewController = ArcGISMapView.createController();
ArcGISMapViewController getMapViewController() {
  return _mapViewController;
}

List<DescriptionPoint> _directionsList = [];
List<DescriptionPoint> getDirectionList() {
  return _directionsList;
}

late RouteLayerData _routeInfo;
RouteLayerData getRouteInfo() {
  return _routeInfo;
}

// currentPOI is the current point of interest (POI) that is selected by the user
// This is purely used for the POI that the user clicked on, so it can be passed from MapWidget to TripInfoBar
int currenPOI = 0;
bool currenPOIChanged = false;

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    initialize();
    super.initState();
  }

  void selectPoi(int selectedPoiObjectId) {
    setState(() {
      currenPOI = selectedPoiObjectId;
      currenPOIChanged = true;
    });
  }

  Future<void> _startRoute(RouteLayerData route, List<Poi> pois) async {
    _graphicsOverlay.graphics.addAll(await generateLinesAndPoints(route));
    _graphicsOverlay.graphics.addAll(generatePoiGraphics(pois));

    List<DescriptionPoint> routeDirections = [];

    for (var element in route.layers[2].featureSet.features) {
      if (element.geometry.x == null) {
        continue;
      }
      final parsedX = element.geometry.x;
      final parsedY = element.geometry.y;

      routeDirections.add(
        DescriptionPoint(
          description: element.attributes['DisplayText'],
          x: parsedX!,
          y: parsedY!,
          angle: element.attributes['Azimuth'].toDouble(),
        ),
      );
    }

    setState(() {
      _routeInfo = route;
      _directionsList = routeDirections;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryAccent = Color.fromARGB(255, 255, 0, 0);
    const Color primaryAppColor = Color.fromARGB(255, 255, 154, 154);
    const Color navigationIcons = Color.fromARGB(255, 48, 48, 48);
    const Color primaryTextColor = Color.fromARGB(255, 73, 69, 79);

    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;

    // print('Screen width: $screenWidth, Screen height: $screenHeight');

    return MaterialApp(
      // theme: AppTheme,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Color Scheme Changes
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryAccent, // Define primaryAccent in color scheme
          // primaryContainer: navigationIcons // FAB
          // onPrimaryContainer: primaryAppColor // FAB Icons
        ),

        // Appbar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryAppColor,
          // scrolledUnderElevation: 0
          scrolledUnderElevation: 1,
        ),

        // SeachBar Theme
        searchBarTheme: SearchBarThemeData(
          backgroundColor: WidgetStateProperty.all(primaryAppColor),
          elevation: WidgetStateProperty.all(0.0),
        ),

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
        // NavigationBar Theme
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: primaryAppColor,
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(color: navigationIcons),
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

        dividerTheme: const DividerThemeData(color: primaryAppColor),

        //Text Theme's
        textTheme: TextTheme(
          bodyLarge: const TextStyle(),
          bodyMedium: const TextStyle(color: primaryTextColor),
          labelLarge: const TextStyle(color: primaryAccent),
        ),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            MapWidget(
              mapViewController: _mapViewController,
              graphicsOverlay: _graphicsOverlay,
              directionsList: _directionsList,
              selectPoi: selectPoi,
            ),
            _directionsList.isNotEmpty
                ? DirectionsCard(
                  directionsList: _directionsList,
                  routeInfo: _routeInfo,
                  mapViewController: _mapViewController,
                )
                : Container(),

            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text("Route Verwijderen"),
                    onPressed: () async {
                
                      setState(() {
                        _directionsList.clear();
                        _graphicsOverlay.graphics.clear();
                        currenPOI = 0;
                      });
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(128.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text("Files Deleten"),
                      onPressed: () {
                        deleteAllSavedFiles();
                      },
                    ),
                  ],
                ),
              ),
            ),

            LoaderOverlay(child: BottomSheetWidget(startRoute: _startRoute)),

            // OfflineMapDownloadExample(),
          ],
        ),
      ),
    );
  }
}
