import 'package:flutter/material.dart';
import 'package:onroute_app/Map/BottomSheet/bottom_sheet_handle.dart';
import 'package:onroute_app/Map/BottomSheet/list_divider.dart';
import 'package:onroute_app/Map/bottom_sheet_widget.dart';
import 'package:onroute_app/Routes/Widgets/Cards/package_card.dart';

class RoutesListView extends StatelessWidget {
  final ScrollController scrollController;

  const RoutesListView({super.key, required this.scrollController});

  Future<List> fetchItems() async {
    List test = [
      {"...": "....", "locally": true},
      {"...": "....", "locally": true},
      {"...": "....", "locally": false},
      {"...": "....", "locally": false},
      {"...": "....", "locally": false},
      {"...": "....", "locally": false},
      {"...": "....", "locally": false},
      {"...": "....", "locally": false},
      {"...": "....", "locally": false},
      {"...": "....", "locally": false},
      {"...": "....", "locally": false},
    ];

    return test;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: fetchItems(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No items available'));
        } else {
          List localItems =
              snapshot.data!.where((item) => item["locally"] == true).toList();
          List onlineItems =
              snapshot.data!.where((item) => item["locally"] == false).toList();
          List<Widget> listItems = [];

          // Add the "Start een route" section
          listItems.add(BottomSheetHandle(context: context));

          // Add the local items section
          listItems.add(const ListDivider(text: 'Gedownloade Routes'));
          if (localItems.isNotEmpty) {
            listItems.addAll(
              localItems.map((item) {
                return const PackageCard();
              }).toList(),
            );
          }

          // Add the online items section
          listItems.add(const ListDivider(text: 'Niet Gedownloade Routes'));
          if (onlineItems.isNotEmpty) {
            listItems.addAll(
              onlineItems.map((item) {
                return const PackageCard();
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
