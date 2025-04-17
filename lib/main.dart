import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onroute_app/Classes/description_point.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/generate_route_components.dart';
import 'package:onroute_app/Components/Map/directions_card.dart';
import 'package:onroute_app/Components/Map/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
import 'package:onroute_app/tesmap.dart';
import 'package:onroute_app/theme.dart';

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

final _mapViewController = ArcGISMapView.createController();
final _graphicsOverlay = GraphicsOverlay();
List<DescriptionPoint> _directionsList = [];
late RouteLayerData _routeInfo;
int change = 0;

List<DescriptionPoint> getDirectionList() {
  return _directionsList;
}

RouteLayerData getRouteInfo() {
  return _routeInfo;
}

ArcGISMapViewController getMapViewController() {
  return _mapViewController;
}

// Future<void> addGraphics(RouteLayerData route) async {
//   _graphicsOverlay.graphics.addAll(await generateLinesAndPoints(route));
// }

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> _startRoute(RouteLayerData route) async {
    _graphicsOverlay.graphics.addAll(await generateLinesAndPoints(route));

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

  void setRouteInfo(RouteLayerData route) {}

  // int currentPageIndex = 1;
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    const Color primaryAccent = Color.fromARGB(255, 255, 0, 0);
    const Color primaryAppColor = Color.fromARGB(255, 255, 154, 154);
    const Color navigationIcons = Color.fromARGB(255, 48, 48, 48);
    const Color primaryTextColor = Color.fromARGB(255, 73, 69, 79);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    print('Screen width: $screenWidth, Screen height: $screenHeight');

    return MaterialApp(
      // theme: AppTheme,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Color Scheme Changes
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryAccent, // Define primaryAccent in color scheme
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
                      });
                    },
                  ),
                ],
              ),
            ),
            BottomSheetWidget(startRoute: _startRoute),
            // OfflineMapDownloadExample(),
          ],
        ),
      ),
    );
  }
}
