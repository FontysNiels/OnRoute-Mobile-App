import 'package:flutter/material.dart';

class RoutesList extends StatelessWidget {
  const RoutesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Routes'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
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
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
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

class RouteCard extends StatelessWidget {
  const RouteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Placeholder(fallbackHeight: 55, fallbackWidth: 55),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        // color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      "Titel",
                      // "Dit is zeker weten een heeeelee langeeeeeee Titel",
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
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Add your onPressed code here!
              },
            ),
          ],
        ),
      ),
    );
  }
}
