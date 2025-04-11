import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Components/BottomSheet/Routes-List/Widgets/list_divider.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/route_card.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_handle.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/Functions/route_functions.dart';

class RoutesListView extends StatefulWidget {
  final ScrollController scrollController;
  final Function startRoute;

  const RoutesListView({
    super.key,
    required this.scrollController,
    required this.startRoute,
  });

  @override
  State<RoutesListView> createState() => _RoutesListViewState();
}

late Future<List<AvailableRoutes>> _futureRoutes; // Store the future

class _RoutesListViewState extends State<RoutesListView> {
  @override
  void initState() {
    super.initState();
    _futureRoutes = fetchItems();
  }

  void _refreshRoutes() {
    // TODO: make this refresh the list of which ones local (and remove the online ones, no need to make more API calls)
    setState(() {
      _futureRoutes = fetchItems();
    });
  }

  Future<List<AvailableRoutes>> fetchItems() async {
    // List of available routes
    List<File> localFiles = await getRouteFiles();
    List<AvailableRoutes> allAvailableRoutes = [];

    allAvailableRoutes.addAll(await fetchLocalItems(localFiles));

    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      allAvailableRoutes.addAll(await fetchOnlineItems(localFiles));
    }

    return allAvailableRoutes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AvailableRoutes>>(
      future: _futureRoutes, // Use the stored future
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        // List of widgets that will be displayed
        List<Widget> listItems = [];
        // Add the "Start een route" section
        listItems.add(BottomSheetHandle(context: context));
        listItems.add(
          SizedBox(
            height: MediaQuery.of(context).size.width / 7,
            child: Image.asset('assets/bragis_onroute.png'),
          ),
        );

        Widget startupText = Column(
          spacing: 8,
          children: [
            Text(
              "Uw routes worden opgehaald!",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            CircularProgressIndicator(),
          ],
        );

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          listItems.add(startupText);
          return ListView(
            padding: const EdgeInsets.all(5),
            controller: widget.scrollController,
            children: listItems,
          );
        } else {
          listItems.remove(startupText);
          // Sets snashot.data as a list of AvailableRoutes
          List<AvailableRoutes> allItems =
              snapshot.data! as List<AvailableRoutes>;

          // Sorts the items into locally saved and online ones
          List localItems =
              allItems.where((item) => item.locally == true).toList();
          List onlineItems =
              allItems.where((item) => item.locally == false).toList();

          // Add the local items section
          listItems.add(const ListDivider(text: 'Gedownloade Routes'));
          if (localItems.isNotEmpty) {
            listItems.addAll(
              localItems.map((item) {
                return RouteCard(
                  key: UniqueKey(),
                  routeContent: item,
                  onRouteUpdated: _refreshRoutes, // Pass the callback
                  startRoute: widget.startRoute,
                  scrollController: widget.scrollController,
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
                  return RouteCard(
                    key: UniqueKey(),
                    routeContent: item,
                    onRouteUpdated: _refreshRoutes, // Pass the callback
                    startRoute: widget.startRoute,
                    scrollController: widget.scrollController,
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
                    // TODO: add a loading modal
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton.filled(onPressed: _refreshRoutes, icon: Icon(Icons.refresh)),
                    )
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
