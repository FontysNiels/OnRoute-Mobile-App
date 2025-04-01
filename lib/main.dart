import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onroute_app/Map/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Routes/route_list.dart';
import 'package:onroute_app/Map/bottom_sheet_widget.dart';
import 'package:onroute_app/theme.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    // print(details);
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

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    initialize();
    super.initState();
  }

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
        appBarTheme: AppBarTheme(
          backgroundColor: primaryAppColor,
          // scrolledUnderElevation: 0
          scrolledUnderElevation: 1,
        ),

        // SeachBar Theme
        searchBarTheme: SearchBarThemeData(
          backgroundColor: WidgetStateProperty.all(primaryAppColor),
          elevation: WidgetStateProperty.all(0.0),
        ),

        // NavigationBar Theme
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: primaryAppColor,
          iconTheme: WidgetStateProperty.all(
            IconThemeData(color: navigationIcons),
          ),
        ),

        // Card Theme
        cardTheme: CardTheme(
          color: primaryAppColor,
          // elevation: 0,
        ),

        // TabBar Theme
        tabBarTheme: TabBarTheme(
          labelColor: primaryAccent,
          unselectedLabelColor: primaryTextColor,
        ),

        dividerTheme: DividerThemeData(
          color: primaryAppColor
        ),

        //Text Theme's
        textTheme: TextTheme(
          bodyLarge: const TextStyle(),
          bodyMedium: const TextStyle(color: primaryTextColor),
          labelLarge: const TextStyle(color: primaryAccent),
        ),
      ),
      home: Scaffold(
        body: IndexedStack(
          index: currentPageIndex, // Controls which child is displayed
          children: [
            // AsyncMapPage(),
            MapWidget(),
            // RoutesList(),
            // TempMapPage(), // This ensures the map remains loaded in memory
            // BottomSheetWidget(),
          ],
        ),
      ),
    );
  }
}
