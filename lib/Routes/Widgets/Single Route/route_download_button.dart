import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/file_storage.dart';

class RouteDownloadButton extends StatelessWidget {
  final String routeID;
  const RouteDownloadButton({super.key, required this.routeID});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton.icon(
        onPressed: () async {
          var response = await getRouteData(routeID);
          var writtenfile = await writeFile(
            response.body,
            '$routeID.json',
          );
          var contentoffile = jsonDecode(await readRouteFile(writtenfile));
          print(contentoffile);
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
