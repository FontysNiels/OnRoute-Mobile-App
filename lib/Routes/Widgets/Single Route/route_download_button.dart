import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';

class RouteDownloadButton extends StatelessWidget {
  final AvailableRoutes routeID;
  const RouteDownloadButton({super.key, required this.routeID});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton.icon(
        onPressed: () async {
          var response = await getRouteData(routeID.routeID);
          var modifiedResponse = jsonDecode(response.body);
          modifiedResponse['title'] = routeID.routeData.title;
          modifiedResponse['description'] = routeID.routeData.description;
          var encodedResponse = jsonEncode(modifiedResponse);

          var writtenfile = await writeFile(
            encodedResponse,
            '${routeID.routeID}.json',
          );
          // var contentoffile = jsonDecode(await readRouteFile(writtenfile));
          // print(contentoffile);
        },
        icon: const Icon(Icons.download),
        label: Text(
          'Downlaod route',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        iconAlignment: IconAlignment.start,
      ),
    );
  }
}
