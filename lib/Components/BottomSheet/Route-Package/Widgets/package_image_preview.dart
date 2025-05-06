import 'package:cached_network_image/cached_network_image.dart';
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
                    child: CachedNetworkImage(
                      imageUrl: routeContent.availableRoute[0].thumbnail,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => CircularProgressIndicator(),
                      errorWidget:
                          (context, url, error) => Image.asset(
                            'assets/temp.png',
                            height: MediaQuery.of(context).size.height * 0.2,
                            fit: BoxFit.cover,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.end,
      //   children: [
      //     Row(
      //       spacing: 16,
      //       children: [
      //         // Big image
      //         Expanded(
      //           flex: 6,
      //           child: ClipRRect(
      //             borderRadius: BorderRadius.circular(28),
      //             child: AspectRatio(
      //               aspectRatio: 16 / 9,
      //               child: CachedNetworkImage(
      //                 // height: MediaQuery.of(context).size.height * 0.2,
      //                 fit: BoxFit.cover,
      //                 // imageUrl: getImageSource(),
      //                 imageUrl: routeContent.availableRoute[0].thumbnail,
      //                 placeholder:
      //                     (context, url) => Image.network(
      //                       // getImageSource(),
      //                       routeContent.availableRoute[0].thumbnail,

      //                       height: MediaQuery.of(context).size.height * 0.2,
      //                       fit: BoxFit.cover,
      //                     ),
      //                 errorWidget:
      //                     (context, url, error) => Image.asset(
      //                       'assets/temp.png',
      //                       height: MediaQuery.of(context).size.height * 0.2,
      //                       fit: BoxFit.cover,
      //                     ),
      //               ),
      //             ),
      //           ),
      //         ),
      //         // Smaller image
      //         // Expanded(
      //         //   flex: 1,
      //         //   child: ClipRRect(
      //         //     borderRadius: BorderRadius.circular(28),
      //         //     child: Image.asset(
      //         //       'assets/temp.png',
      //         //       height: MediaQuery.of(context).size.height * 0.2,
      //         //       fit: BoxFit.cover,
      //         //     ),
      //         //   ),
      //         // ),
      //       ],
      //     ),
      //     // Padding(
      //     //   padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
      //     //   child: GestureDetector(
      //     //     onTap: () {
      //     //       // Handle the tap event here
      //     //     },
      //     //     child: Text(
      //     //       "Zie alle",
      //     //       style: Theme.of(context).textTheme.labelLarge,
      //     //       textAlign: TextAlign.end,
      //     //     ),
      //     //   ),
      //     //   // child: TextButton(onPressed: () {}, child: const Text('Zie alle')),
      //     // ),
      //   ],
      // ),
    );
  }
}
