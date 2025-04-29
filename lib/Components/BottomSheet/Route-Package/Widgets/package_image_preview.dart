import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class PackegImagePreview extends StatelessWidget {
  final String description;
  const PackegImagePreview({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    String getImageSource() {
      List<String> listOfItems = description.split(' ');
      final String sourceString =
          listOfItems
              .firstWhere((word) => word.contains('src'), orElse: () => '')
              .replaceAll('src=', '')
              .replaceAll("'", '')
              .trim();
      return sourceString;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            spacing: 16,
            children: [
              // Big image
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: CachedNetworkImage(
                    height: MediaQuery.of(context).size.height * 0.2,
                    fit: BoxFit.cover,
                    imageUrl: getImageSource(),
                    placeholder:
                        (context, url) => Image.network(
                          getImageSource(),
                          height: MediaQuery.of(context).size.height * 0.2,
                          fit: BoxFit.cover,
                        ),
                    errorWidget:
                        (context, url, error) => Image.asset(
                          'assets/temp.png',
                          height: MediaQuery.of(context).size.height * 0.2,
                          fit: BoxFit.cover,
                        ),
                  ),
                ),
              ),
              // Smaller image
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/temp.png',
                    height: MediaQuery.of(context).size.height * 0.2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
            child: GestureDetector(
              onTap: () {
                // Handle the tap event here
              },
              child: Text(
                "Zie alle",
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.end,
              ),
            ),
            // child: TextButton(onPressed: () {}, child: const Text('Zie alle')),
          ),
        ],
      ),
    );
  }
}
