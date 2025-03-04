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
      home: RoutesList(),
    );
  }
}
