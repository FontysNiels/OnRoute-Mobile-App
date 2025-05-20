import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:url_launcher/url_launcher.dart';

class PoiButtons extends StatelessWidget {
  final Poi routeContent;
  const PoiButtons({super.key, required this.routeContent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 10,
        children: [
          if (routeContent.website != null)
            ElevatedButton.icon(
              onPressed: () async {
                // Handle website button press
                if (!await launchUrl(Uri.parse(routeContent.website!))) {
                  // throw Exception('Could not launch $_url');
                }
              },
              icon: const Icon(Icons.language),
              label: Text(
                'Website',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          if (routeContent.mail != null)
            ElevatedButton.icon(
              onPressed: () async {
                // Handle email button press
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Email: ${routeContent.mail}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                );
              },
              icon: const Icon(Icons.mail),
              label: Text(
                'Email',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          if (routeContent.phone != null)
            ElevatedButton.icon(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Telefoonnummer: ${routeContent.phone}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                );
              },
              icon: const Icon(Icons.phone),
              label: Text(
                'Telefoon',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
