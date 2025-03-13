import 'package:flutter/material.dart';

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
                RouteCard(),
                RouteCard(),
                RouteCard(),
                RouteCard(),
                RouteCard(),
                RouteCard(),
                RouteCard(),
                RouteCard(),
                RouteCard(),
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

class RouteCard extends StatelessWidget {
  const RouteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        // padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 9.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/temp.png',
                      height: 56,
                      width: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: Theme.of(context).textTheme.bodyLarge,
                            // 2 lines van maken? Titels zijn vrij lang
                            "Bergsebosfietsen - Genieten over heuvelrug en kromme rijn gebied",
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "2nd text",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            "Download status",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.more_vert),
                  //   onPressed: () {
                  //   showPopover(context: context, bodyBuilder: (context)=> PopupMenuItem(child: Text('Download'), value: Text('yes'),));
                  //   },
                  // ),
                  PopupMenuButton(
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry>[
                          const PopupMenuItem(
                            // value: SampleItem.itemOne,
                            child: Padding(
                              padding: EdgeInsets.all(0),
                              child: Text('Download'),
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ),
            // Divider()
          ],
        ),
      ),
    );
  }
}
