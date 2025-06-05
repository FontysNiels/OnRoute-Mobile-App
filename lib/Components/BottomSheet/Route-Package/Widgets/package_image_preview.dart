import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';

class PackegImagePreview extends StatelessWidget {
  final WebMapCollection routeContent;
  const PackegImagePreview({super.key, required this.routeContent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 197, 197, 197),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child:
                        routeContent.availableRoute[0].thumbnail == ''
                            ? Image.asset(
                              'assets/temp.png',
                              height: MediaQuery.of(context).size.height * 0.2,
                              fit: BoxFit.cover,
                            )
                            : routeContent.locally
                            ? Image.file(
                              File(routeContent.availableRoute[0].thumbnail),
                              height: MediaQuery.of(context).size.height * 0.2,
                              fit: BoxFit.cover,
                            )
                            : Image.network(
                              routeContent.availableRoute[0].thumbnail,
                              height: MediaQuery.of(context).size.height * 0.2,
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
