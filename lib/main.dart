import 'package:onroute_app/Map/MapWidget.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Routes/route_list.dart';
import 'package:onroute_app/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int currentPageIndex = 1;
  @override
  Widget build(BuildContext context) {
    // return MaterialApp(home: MapWidget());
    return MaterialApp(
      // theme: AppTheme,
      theme: ThemeData(
        useMaterial3: true,

        // Define the default brightness and colors.
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: const Color.fromARGB(255, 255, 0, 0),
        //   // ···
        //   // brightness: Brightness.dark,
        // ),
        searchBarTheme: SearchBarThemeData(
          backgroundColor: WidgetStateProperty.all(
            Color.fromARGB(255, 254, 190, 190),
          ),
          elevation: WidgetStateProperty.all(0.0),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 254, 190, 190),
          // scrolledUnderElevation: 0
          scrolledUnderElevation: 1,
        ),

        // bottomNavigationBarTheme: BottomNavigationBarThemeData(
        //   backgroundColor: Color.fromARGB(255, 254, 190, 190),
        // ),

        // navigationRailTheme: NavigationRailThemeData(
        //   backgroundColor: Color.fromARGB(255, 254, 190, 190),
        // ),

        // navigationDrawerTheme: NavigationDrawerThemeData(
        //   backgroundColor: Color.fromARGB(255, 254, 190, 190),
        // ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 254, 190, 190),
        ),

        cardColor: Color.fromARGB(255, 254, 190, 190),

        cardTheme: CardTheme(
          color: const Color.fromARGB(255, 254, 190, 190),
          // elevation: 0,
        ),
        // bottomNavigationBarTheme: BottomNavigationBarThemeData(
        //   backgroundColor: Color.fromARGB(255, 254, 190, 190),
        // ),

        //Text Theme Changes
        textTheme: TextTheme(
          bodyLarge: const TextStyle(
            // fontSize: 18,
            // fontWeight: FontWeight.normal,
            // color: Color.fromARGB(255, 0, 0, 0),
          ),
          bodyMedium: const TextStyle(color: Color.fromARGB(255, 73, 69, 79)),

          // ···
        ),
      ),
      home: Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: const Color.fromARGB(255, 235, 138, 138),
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.map),
              label: 'Kaart',
            ),
            NavigationDestination(
              icon: Badge(child: Icon(Icons.explore)),
              label: 'Routes',
            ),
            NavigationDestination(
              icon: Badge(label: Text('2'), child: Icon(Icons.question_mark)),
              label: 't.b.d.',
            ),
          ],
        ),
        body:
            <Widget>[
              MapWidget(),
              RoutesList(),
              Placeholder(),
            ][currentPageIndex],
      ),
    );
  }
}
