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
                  // placeholder:
                  //     (context, url) => Image.asset(
                  //       'assets/temp.png',
                  //       height: MediaQuery.of(context).size.height * 0.2,
                  //       // fit: BoxFit.cover,
                  //     ),
                  placeholder:
                      (context, url) => CircularProgressIndicator(),
                  errorWidget:
                      (context, url, error) => Image.asset(
                        'assets/temp.png',
                        height: MediaQuery.of(context).size.height * 0.2,
                        // fit: BoxFit.cover,
                      ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
