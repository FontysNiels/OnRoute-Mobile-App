import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Components/BottomSheet/Routes-List/Widgets/list_divider.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/route_card.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_handle.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
import 'package:onroute_app/Functions/fetch_routes.dart';

class RoutesListView extends StatefulWidget {
  final ScrollController scrollController;
  final Function startRoute;
  final Function setSheetWidget;

  const RoutesListView({
    super.key,
    required this.scrollController,
    required this.startRoute,
    required this.setSheetWidget,
  });

  @override
  State<RoutesListView> createState() => _RoutesListViewState();
}

late Future<List<WebMapCollection>> _futureRoutes; // Store the future
List<ConnectivityResult> connectivityResult = [];

class _RoutesListViewState extends State<RoutesListView> {
  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _futureRoutes = futureRoutes;
  }

  void _initializeConnectivity() async {
    connectivityResult = await Connectivity().checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WebMapCollection>>(
      future: _futureRoutes,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<WebMapCollection>> snapshot,
      ) {
        final List<Widget> listItems = [
          BottomSheetHandle(context: context),
          SizedBox(
            height: MediaQuery.of(context).size.width / 7,
            child: Image.asset('assets/bragis_onroute.png'),
          ),
        ];

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          listItems.add(_buildStartupText(context));
          return _buildListView(listItems);
        }

        final data = snapshot.data ?? [];
        final localItems = data.where((item) => item.locally).toList();
        final onlineItems = data.where((item) => !item.locally).toList();

        final isOffline = connectivityResult.contains(ConnectivityResult.none);

        // Handle when both lists are empty
        if (data.isEmpty) {
          listItems.add(_buildEmptyState(context, isOffline));
          return _buildListView(listItems);
        }

        // Local routes section
        listItems.add(const ListDivider(text: 'Gedownloade Routes'));
        if (localItems.isNotEmpty) {
          listItems.addAll(localItems.map((item) => _buildRouteCard(item)));
        } else {
          listItems.add(_buildNoLocalRoutesText(context));
        }

        // Online routes section
        listItems.add(const ListDivider(text: 'Niet Gedownloade Routes'));
        if (isOffline) {
          listItems.add(_buildOfflineNotice(context));
        } else {
          final filteredOnlineItems =
              onlineItems
                  .where(
                    (item) =>
                        !localItems.any(
                          (localItem) => localItem.webmapId == item.webmapId,
                        ) &&
                        item.availableRoute.length == 1,
                  )
                  .toList();

          if (filteredOnlineItems.isNotEmpty) {
            listItems.addAll(
              filteredOnlineItems.map((item) => _buildRouteCard(item)),
            );
          } else {
            listItems.add(_buildNoOtherRoutesText(context));
          }
        }

        return _buildListView(listItems);
      },
    );
  }

  // === Helper widgets below ===

  Widget _buildStartupText(BuildContext context) {
    return Column(
      children: [
        Text(
          "Uw routes worden opgehaald!",
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildRouteCard(WebMapCollection item) {
    return RouteCard(
      key: UniqueKey(),
      routeContent: item,
      startRoute: widget.startRoute,
      scrollController: widget.scrollController,
      setSheetWidget: widget.setSheetWidget,
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isOffline) {
    return isOffline
        ? _buildOfflineNotice(context)
        : Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            "Er zijn momenteel geen routes beschikbaar",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        );
  }

  Widget _buildNoLocalRoutesText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        "Download routes om deze te gebruiken zonder internetverbinding",
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNoOtherRoutesText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        "Er zijn geen andere routes beschikbaar...",
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOfflineNotice(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          const Icon(Icons.wifi_off),
          Text(
            "Verbind met het internet om alle routes te zien",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton.filled(
              onPressed: () async {
                connectivityResult = await Connectivity().checkConnectivity();
                if (!connectivityResult.contains(ConnectivityResult.none)) {
                  // Show loaing indicator
                  context.loaderOverlay.show();
                  // Solve the future of futureRoutes
                  List<WebMapCollection> receivedRoutes = await futureRoutes;
                  // Fetch online items and add them to receivedRoutes, avoiding duplicates
                  List<WebMapCollection> onlineItems = await fetchOnlineItems(
                    context,
                  );
                  receivedRoutes.addAll(
                    onlineItems.where(
                      (onlineItem) =>
                          !receivedRoutes.any(
                            (route) => route.webmapId == onlineItem.webmapId,
                          ),
                    ),
                  );
                  // Reload the sheetWidget
                  widget.setSheetWidget(null, true);
                  // Hide the loading indicator
                  context.loaderOverlay.hide();
                }
              }, // Add refresh logic if needed
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Widget> children) {
    return ListView(
      padding: const EdgeInsets.all(5),
      controller: widget.scrollController,
      children: children,
    );
  }
}
