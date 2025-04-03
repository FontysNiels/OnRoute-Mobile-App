import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/Map/BottomSheet/bottom_sheet_handle.dart';
import 'package:onroute_app/Map/BottomSheet/list_divider.dart';
import 'package:onroute_app/Routes/Widgets/Cards/package_card.dart';
import 'package:onroute_app/Routes/Widgets/Cards/route_card.dart';

class RoutesListView extends StatefulWidget {
  final ScrollController scrollController;
  final Function setRouteGraphics;

  const RoutesListView({
    super.key,
    required this.scrollController,
    required this.setRouteGraphics,
  });

  @override
  State<RoutesListView> createState() => _RoutesListViewState();
}
late Future<List<AvailableRoutes>> _futureRoutes; // Store the future
class _RoutesListViewState extends State<RoutesListView> {
  

  @override
  void initState() {
    super.initState();
    _futureRoutes = fetchItems(); // Initialize the future
  }

  void _refreshRoutes() {
    setState(() {
      _futureRoutes = fetchItems(); // Refresh the future
    });
  }

  Future<List<AvailableRoutes>> fetchItems() async {
    // List of all files on device
    List<File> localFiles = await getRouteFiles();

    // Remove localFiles.filename from routeIDs, instead of if = container()

    // TEMP list of routeIDs
    List routeIDs = [
      '4f4cea7adeb0463c9ccb4a92d2c62dbf',
      'd7c2638c697d415584c84166e04565b5',
      'c79d6d7746d145deaf842bd7602f70b4',
    ];

    // List of available routes
    List<AvailableRoutes> allAvailableRoutes = [];

    // Insert all online routes into the list
    for (var i = 0; i < routeIDs.length; i++) {
      // Get route info (title, description) based on routeID
      var response = await getRouteInfo(routeIDs[i]);
      var layerInfo = jsonDecode(response.body);

      var routeResponse = await getRouteData(layerInfo['id']);
      var modifiedResponse = jsonDecode(routeResponse.body);
      modifiedResponse['title'] = layerInfo['title'];
      modifiedResponse['description'] = layerInfo['description'];

      RouteLayerData routeInfo = RouteLayerData.fromJson(modifiedResponse);

      // Add info of online route to list
      AvailableRoutes onlineRoute = AvailableRoutes(
        routeID: layerInfo['id'],
        locally: false,
        routeLayer: routeInfo,
      );
      allAvailableRoutes.add(onlineRoute);
    }

    // Add all the local files to the list
    for (var file in localFiles) {
      var storedFile = jsonDecode(await readRouteFile(file));
      RouteLayerData routeInfo = RouteLayerData.fromJson(storedFile);

      allAvailableRoutes.add(
        AvailableRoutes(
          routeID: file.path,
          locally: true,
          routeLayer: routeInfo,
        ),
      );
    }

    return allAvailableRoutes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AvailableRoutes>>(
      future: _futureRoutes, // Use the stored future
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
                return RouteCard(key: UniqueKey(),
                  routeContent: item,
                  onRouteUpdated: _refreshRoutes, // Pass the callback
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

          if (onlineItems.isNotEmpty) {
            listItems.addAll(
              onlineItems.map((item) {
                if (localItems.any(
                  (localItem) =>
                      localItem.routeID.toString().contains(item.routeID),
                )) {
                  return Container();
                } else {
                  return RouteCard(key: UniqueKey(),
                    routeContent: item,
                    onRouteUpdated: _refreshRoutes, // Pass the callback
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
            controller: widget.scrollController,
            children: listItems,
          );
        }
      },
    );
  }
}
