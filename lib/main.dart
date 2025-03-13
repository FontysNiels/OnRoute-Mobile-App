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
    const Color primaryAccent = Color.fromARGB(255, 255, 0, 0);
    const Color primaryAppColor = Color.fromARGB(255, 254, 190, 190);
    const Color navigationIcons = Color.fromARGB(255, 48, 48, 48);

    return MaterialApp(
      // theme: AppTheme,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryAccent, // Define primaryAccent in color scheme
        ),
        searchBarTheme: SearchBarThemeData(
          backgroundColor: WidgetStateProperty.all(primaryAppColor),
          elevation: WidgetStateProperty.all(0.0),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: primaryAppColor,
          // scrolledUnderElevation: 0
          scrolledUnderElevation: 1,
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: primaryAppColor,
          iconTheme: WidgetStateProperty.all(
            IconThemeData(color: navigationIcons),
          ),
        ),

        cardColor: primaryAppColor,

        cardTheme: CardTheme(
          color: primaryAppColor,
          // elevation: 0,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: primaryAccent,
          unselectedLabelColor: const Color.fromARGB(255, 73, 69, 79),
        ),
        // iconTheme: IconThemeData(color: primaryAccent),

        //Text Theme Changes
        textTheme: TextTheme(
          bodyLarge: const TextStyle(
            // fontSize: 18,
            // fontWeight: FontWeight.normal,
            // color: Color.fromARGB(255, 0, 0, 0),
          ),
          bodyMedium: const TextStyle(color: Color.fromARGB(255, 73, 69, 79)),
          labelLarge: const TextStyle(color: primaryAccent),
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
              Placeholder(),
            ][currentPageIndex],
      ),
    );
  }
}
