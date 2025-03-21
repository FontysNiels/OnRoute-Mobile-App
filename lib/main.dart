import 'package:onroute_app/Map/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Routes/route_list.dart';
import 'package:onroute_app/temp.dart';
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
    const Color primaryAccent = Color.fromARGB(255, 255, 0, 0);
    const Color primaryAppColor = Color.fromARGB(255, 255, 154, 154);
    const Color navigationIcons = Color.fromARGB(255, 48, 48, 48);
    const Color primaryTextColor = Color.fromARGB(255, 73, 69, 79);

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

        //Text Theme's
        textTheme: TextTheme(
          bodyLarge: const TextStyle(),
          bodyMedium: const TextStyle(color: primaryTextColor),
          labelLarge: const TextStyle(color: primaryAccent),
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
              selectedIcon: Icon(Icons.map),
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
              OfflineMapPage(),
            ][currentPageIndex],
      ),
    );
  }
}
