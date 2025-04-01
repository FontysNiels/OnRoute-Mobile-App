import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/Map/BottomSheet/bottom_sheet_handle.dart';
import 'package:onroute_app/Map/BottomSheet/list_divider.dart';
import 'package:onroute_app/Routes/Widgets/Cards/package_card.dart';
import 'package:onroute_app/Routes/Widgets/Cards/route_card.dart';

class RoutesListView extends StatelessWidget {
  final ScrollController scrollController;
  final Function setRouteGraphics;

  const RoutesListView({
    super.key,
    required this.scrollController,
    required this.setRouteGraphics,
  });

  Future<List<AvailableRoutes>> fetchItems() async {
    // List of all files on device
    List<File> localFiles = await getRouteFiles();
    print(localFiles);

    // TEMP list of routeIDs
    List routeIDs = [
      '4f4cea7adeb0463c9ccb4a92d2c62dbf',
      'd7c2638c697d415584c84166e04565b5',
    ];

    // List of available routes
    List<AvailableRoutes> allAvailableRoutes = [];

    // Insert all online routes into the list
    for (var i = 0; i < routeIDs.length; i++) {
      // Get route info (title, description) based on routeID
      var response = await getRouteInfo(routeIDs[i]);
      var layerInfo = jsonDecode(response.body);

      // Add info of online route to list
      AvailableRoutes onlineRoute = AvailableRoutes(
        routeID: layerInfo['id'],
        routeData: RouteData(
          title: layerInfo['title'],
          description: layerInfo['description'],
        ),
        locally: false,
      );
      allAvailableRoutes.add(onlineRoute);
    }

    // Add all the local files to the list
    for (var file in localFiles) {
      allAvailableRoutes.add(
        AvailableRoutes(
          routeID: file.path,
          routeData: RouteData(
            title: 'NOG ERGENS DE TITEL OPSLAAN',
            description: 'NOG ERGENS DE DESCRIPTION OPSLAAN',
          ),
          locally: true,
        ),
      );
    }

    return allAvailableRoutes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AvailableRoutes>>(
      future: fetchItems(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No items available'));
        } else {
          // Sets snashot.data as a list of AvailableRoutes
          List<AvailableRoutes> allItems =
              snapshot.data! as List<AvailableRoutes>;

          // Sorts the items into locally saved and online ones
          List localItems =
              allItems.where((item) => item.locally == true).toList();
          List onlineItems =
              allItems.where((item) => item.locally == false).toList();

          // List of widgets that will be displayed
          List<Widget> listItems = [];

          // Add the "Start een route" section
          listItems.add(BottomSheetHandle(context: context));

          // Add the local items section
          listItems.add(const ListDivider(text: 'Gedownloade Routes'));
          if (localItems.isNotEmpty) {
            listItems.addAll(
              localItems.map((item) {
                // return const PackageCard();
                return RouteCard(
                  routeID: item,
                  // startRoute: setRouteGraphics,
                );
              }).toList(),
            );
          } else {
            listItems.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    // const Icon(Icons.wifi_off),
                    Text(
                      "Download routes om deze te gebruiken zonder internetverbinding",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          //////////////////////////////////////////////////////////////////////////////////////////////////////////
          // Add the online items section
          listItems.add(const ListDivider(text: 'Niet Gedownloade Routes'));

          // listItems.add(
          //   // return const PackageCard();
          //   RouteCard(
          //     startRoute: setRouteGraphics,
          //     routeID: '',
          //   ),
          // );

          if (onlineItems.isNotEmpty) {
            listItems.addAll(
              onlineItems.map((item) {
                // print(item);
                if (localItems.any(
                  (localItem) =>
                      localItem.routeID.toString().contains(item.routeID),
                )) {
                  return Container();
                } else {
                  return RouteCard(
                    routeID: item,
                    // startRoute: () {},
                  );
                  // return const PackageCard();
                }
              }).toList(),
            );
          } else {
            listItems.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    const Icon(Icons.wifi_off),
                    Text(
                      "Verbind met het internet om alle routes te zien",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(5),
            controller: scrollController,
            children: listItems,
          );
        }
      },
    );
  }
}
