import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';
import 'package:onroute_app/Functions/file_storage.dart';

class DescriptionBlock extends StatelessWidget {
  final String description;
  final WebMapCollection currentRoute;
  final Function setSheetWidget;
  const DescriptionBlock({
    super.key,
    required this.description,
    required this.currentRoute,
    required this.setSheetWidget,
  });

  @override
  Widget build(BuildContext context) {
    List<String> getImageSources() {
      List<String> listOfItems = description.split(' ');
      final List<String> sources =
          listOfItems
              .where((word) => word.contains('src'))
              .map(
                (word) =>
                    word.replaceAll('src=', '').replaceAll("'", '').trim(),
              )
              .toList();
      return sources;
    }

    String replaceImageDivs(String htmlString) {
      List<String> imageSources = getImageSources();
      int index = 0;

      final String updatedHtml = htmlString.replaceAllMapped(
        RegExp(r'(?:<div>)?<img[^>]*>(?:</div>)?', caseSensitive: true),
        // RegExp(r'<div>*<img[^>]*></div>*', caseSensitive: true),
        (match) {
          // return imageSources[0];
          if (index < imageSources.length) {
            return imageSources[index++];
          }
          return '';
        },
      );

      return updatedHtml;
    }

    String stripHtmlTags(String htmlString) {
      // RegExp to remove all HTML tags
      final RegExp exp = RegExp(
        r'<[^>]*>',
        multiLine: true,
        caseSensitive: true,
      );
      // htmlString.replaceAll("<div>", '');
      // htmlString.replaceAll("</div>", '\n');
      // htmlString.replaceAll("<br />", '\n');
      // Replace <br/> tags with new lines

      htmlString = htmlString.replaceAllMapped(
        RegExp(r'<br\s*/?>', multiLine: true, caseSensitive: true),
        (match) {
          if (match.group(0)!.contains('src=')) {
            return match.group(0)!; // Keep the src attribute intact
          }
          return 'BREAKLINE'; // Replace other matches with a newline
        },
      );
      htmlString = htmlString.replaceAllMapped(
        RegExp(r'<()([^>]*)>', multiLine: true, caseSensitive: true),
        (match) {
          if (match.group(0)!.contains('src=')) {
            return match.group(0)!; // Keep the src attribute intact
          }
          return '\n'; // Replace other matches with a newline
        },
      );

      final String cleaned = htmlString.replaceAll(exp, '');

      // Replace HTML entities if needed
      final Map<String, String> htmlEntities = {
        '&quot;': '"',
        '&amp;': '&',
        '&nbsp;': ' ',
        // Add more if necessary
      };

      String decoded = cleaned;
      htmlEntities.forEach((key, value) {
        decoded = decoded.replaceAll(key, value);
      });

      // Optionally, trim extra whitespace
      return decoded.trim();
    }

    List<Widget> parseStringToWidgets(String inputString) {
      List<Widget> widgets = [];
      // Split the string based on the newline characters '\n'

      List<String> parts = inputString.split('\n');
      String lastItem = "";
      for (var part in parts) {
        // Check if the part is a URL by simple pattern matching
        if (part.startsWith('https://') || part.startsWith('http://')) {
          widgets.add(
            CachedNetworkImage(
              imageUrl: part,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget:
                  (context, url, error) => Image.asset(
                    'assets/temp.png',
                    height: MediaQuery.of(context).size.height * 0.2,
                    fit: BoxFit.cover,
                  ),
            ),
          );
        } else if (part != '') {
          if (part.contains('BREAKLINE')) {
            part = part.replaceAll('BREAKLINE', '');
          }
          widgets.add(Text(part));
        } else if (part == '') {
          if (lastItem != part) {
            widgets.add(Text(part));
          }
          lastItem = part;
        }
      }
      return widgets;
    }

    // Makes a list of widgets with text
    List<Widget> descriptionTabContent = parseStringToWidgets(
      stripHtmlTags(replaceImageDivs(description)),
    );

    if (currentRoute.locally) {
      descriptionTabContent.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Divider(),
        ),
      );
      descriptionTabContent.add(
        Wrap(
          spacing: 4,
          children: [
            FilledButton.icon(
              onPressed: () async {},
              icon: const Icon(Icons.update),
              label: Text(
                'Bijwerken Route',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(color: Colors.white),
              ),
              iconAlignment: IconAlignment.start,
            ),

            TextButton.icon(
              onPressed: () async {
                await deleteRouteInfo(currentRoute.webmapId);
                await moveSheetTo(0.5);

                await setSheetWidget(null, true);
              },
              icon: const Icon(Icons.delete),
              label: Text(
                'Verwijder Route',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              iconAlignment: IconAlignment.start,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: descriptionTabContent,

        // Pretitle
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 8.0),
        //   child: Text(
        //     'Deze set heeft 4 routes',
        //     style: Theme.of(context).textTheme.labelSmall,
        //   ),
        // ),
        // // Beschrijving
        // Text(
        //   stripHtmlTags(replaceImageDivs(description)),
        //   style: Theme.of(context).textTheme.bodyMedium,
        // ),
      ),
    );
  }
}
