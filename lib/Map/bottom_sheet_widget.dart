import 'package:flutter/material.dart';
import 'package:onroute_app/Routes/Widgets/Cards/package_card.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({super.key});

  Future<List> fetchItems() async {
    // make this the get routes from ArcGIS and get routes from local storage
    // {storedLocaly: [route1, route2, route3], fromArcGIS: [route4, route5, route6]}
    // of
    List test = [
      {"...": "....", "locally": true},
      {"...": "....", "locally": true},
      {"...": "....", "locally": false},
    ];

    return test;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Persistent bottom sheet
        DraggableScrollableSheet(
          initialChildSize: 0.2,
          minChildSize: 0.1,
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: FutureBuilder<List>(
                future: fetchItems(), // Replace with your async function
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No items available'));
                  } else {
                    List localItems =
                        snapshot.data!
                            .where((item) => item["locally"] == true)
                            .toList();
                    List onlineItems =
                        snapshot.data!
                            .where((item) => item["locally"] == false)
                            .toList();
                    List<Widget> listItems = [];

                    // Add the "Start een route" section
                    listItems.add(BottomSheetHandle(context));

                    // Add the local items section
                    listItems.add(ListDivider(text: 'Gedownloade Routes'));
                    if (localItems.isNotEmpty) {
                      listItems.addAll(
                        localItems.map((item) {
                          return PackageCard();
                        }).toList(),
                      );
                    }

                    // Add the online items section
                    listItems.add(ListDivider(text: 'Niet Gedownloade Routes'));
                    if (onlineItems.isNotEmpty) {
                      listItems.addAll(
                        onlineItems.map((item) {
                          return PackageCard();
                        }).toList(),
                      );
                    } 
                    // Make this an ONLINE CHECK, since there are always routes it shouldn't be that big of a problem tho
                    else {
                      listItems.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            spacing: 8,
                            children: [
                              Icon(Icons.wifi_off),
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
              ),
            );
          },
        ),
      ],
    );
  }

  Column BottomSheetHandle(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 10,
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Text("Start een route", style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class ListDivider extends StatelessWidget {
  final String text;
  const ListDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(child: Divider(thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(child: Divider(thickness: 1)),
            ],
          ),
        ),
        Divider(thickness: 1),
      ],
    );
  }
}
