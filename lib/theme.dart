import 'package:flutter/material.dart';

ThemeData AppTheme = ThemeData(
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
);


