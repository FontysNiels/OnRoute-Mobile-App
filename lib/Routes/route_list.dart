import 'package:flutter/material.dart';
import 'package:onroute_app/Routes/Route%20Package/package_card.dart';

class RoutesList extends StatelessWidget {
  const RoutesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Routes'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Searchbar(),
                // generated maken, futurebuilder ofzo
                PackageCard(),
                PackageCard(),
                PackageCard(),
                PackageCard(),
                PackageCard(),
                PackageCard(),
                PackageCard(),
                PackageCard(),
                PackageCard(),
                PackageCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Searchbar extends StatelessWidget {
  const Searchbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            hintText: 'Search for routes',
            controller: controller,
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            onTap: () {
              controller.openView();
            },
            onChanged: (_) {
              controller.openView();
            },
            leading: const Icon(Icons.search),
          );
        },
        suggestionsBuilder: (
          BuildContext context,
          SearchController controller,
        ) {
          return List<Widget>.generate(5, (int index) {
            return ListTile(title: Text('Suggestion $index'), onTap: () {});
          });
        },
      ),
    );
  }
}