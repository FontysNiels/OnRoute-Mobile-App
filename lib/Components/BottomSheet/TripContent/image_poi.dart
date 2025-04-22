import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/poi.dart';

class ImagePOI extends StatelessWidget {
  final Poi poiList;
  const ImagePOI({super.key, required this.poiList});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 197, 197, 197),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: poiList.asset ?? '',
                  placeholder:
                      (context, url) => Image.asset(
                        'assets/temp.png',
                        height: MediaQuery.of(context).size.height * 0.2,
                        // fit: BoxFit.cover,
                      ),
                  errorWidget:
                      (context, url, error) => Image.asset(
                        'assets/temp.png',
                        height: MediaQuery.of(context).size.height * 0.2,
                        // fit: BoxFit.cover,
                      ),
                ),

                // Image.asset(
                //   'assets/temp.png',
                //   height: MediaQuery.of(context).size.height * 0.2,
                // ),
              ),
            ),
            // SizedBox(height: 20),
            // Container(
            //   decoration: const BoxDecoration(
            //     color: Color.fromARGB(255, 197, 197, 197),
            //   ),
            //   child: AspectRatio(
            //     aspectRatio: 16 / 9,
            //     child: Image.asset(
            //       'assets/temp-vertical.png',
            //       height: MediaQuery.of(context).size.height * 0.2,
            //     ),
            //   ),
            // ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 6, top: 6),
            child: IconButton.filled(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).primaryColor.withValues(alpha: 1.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
