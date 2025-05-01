import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Components/BottomSheet/Routes-List/Widgets/list_divider.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/route_card.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_handle.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';

class RoutesListView extends StatefulWidget {
  final ScrollController scrollController;
  final Function startRoute;
  final Function changesheetsize;
  final Function setSheetWidget;

  const RoutesListView({
    super.key,
    required this.scrollController,
    required this.startRoute,
    required this.changesheetsize,
    required this.setSheetWidget,
  });

  @override
  State<RoutesListView> createState() => _RoutesListViewState();
}

late Future<List<WebMapCollection>> _futureRoutes; // Store the future

class _RoutesListViewState extends State<RoutesListView> {
  @override
  void initState() {
    super.initState();
    _futureRoutes = futureRoutes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WebMapCollection>>(
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
        }
        // else if (snapshot.connectionState == ConnectionState.none) {
        //   listItems.add(startupText);
        //   return ListView(
        //     padding: const EdgeInsets.all(5),
        //     controller: widget.scrollController,
        //     children: listItems,
        //   );
        // }
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          listItems.add(startupText);
          return ListView(
            padding: const EdgeInsets.all(5),
            controller: widget.scrollController,
            // controller: getScroller(),
            children: listItems,
          );
        } else {
          listItems.remove(startupText);
          // Sets snashot.data as a list of AvailableRoutes
          List<WebMapCollection> allItems =
              snapshot.data! as List<WebMapCollection>;

          // Sorts the items into locally saved and online ones
          List<WebMapCollection> localItems =
              allItems.where((item) => item.locally == true).toList();
          List<WebMapCollection> onlineItems =
              allItems.where((item) => item.locally == false).toList();

          // Add the local items section
          listItems.add(const ListDivider(text: 'Gedownloade Routes'));
          if (localItems.isNotEmpty) {
            listItems.addAll(
              localItems.map((item) {
                return RouteCard(
                  key: UniqueKey(),
                  routeContent: item,
                  // onRouteUpdated: _refreshRoutes, // Pass the callback
                  startRoute: widget.startRoute,
                  scrollController: widget.scrollController,
                  setSheetWidget: widget.setSheetWidget,
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
          // TODO: Not container, remove earlier
          // TODO: Add something for when everything is downloaded
          if (onlineItems.isNotEmpty) {
            listItems.addAll(
              onlineItems.map((item) {
                if (localItems.any(
                  (localItem) =>
                      localItem.webmapId.toString().contains(item.webmapId),
                )) {
                  return Container();
                } else {
                  // Check if it is only 1 route, making it a route and not package
                  if (item.availableRoute.length == 1) {
                    return RouteCard(
                      key: UniqueKey(),
                      routeContent: item,
                      // onRouteUpdated: _refreshRoutes, // Pass the callback
                      startRoute: widget.startRoute,
                      scrollController: widget.scrollController,
                      setSheetWidget: widget.setSheetWidget,
                    );
                  } else {
                    return Container();
                    // return const PackageCard();
                  }
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
                      child: IconButton.filled(
                        onPressed: null,
                        // _refreshRoutes,
                        icon: Icon(Icons.refresh),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(5),
            controller: widget.scrollController,
            // controller: getScroller(),
            children: listItems,
          );
        }
      },
    );
  }
}
