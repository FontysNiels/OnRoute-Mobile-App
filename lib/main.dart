import 'package:onroute_app/Map/MapWidget.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Routes/route_list.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        // Define the default brightness and colors.
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: const Color.fromARGB(255, 255, 0, 0),
        //   // ···
        //   // brightness: Brightness.dark,
        // ),

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
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
