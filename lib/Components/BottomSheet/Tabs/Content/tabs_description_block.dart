import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Components/BottomSheet/Single-Route/Widgets/route_edit_buttons.dart';

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
    List<Widget> parseStringToWidgets(String inputString) {
      List<Widget> widgets = [];
      // Split the string based on the newline characters '\n'

      List<String> parts = inputString.split('\n');
      String lastItem = "";
      for (var part in parts) {
        // Check if the part is a URL by simple pattern matching

        if (part.startsWith('https://') || part.startsWith('http://')) {
          widgets.add(
            Image.network(
              part,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 197, 197, 197),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: Icon(Icons.wifi_off, size: 25, color: Colors.grey),
                  ),
                );
              },
            ),
          );
        } else if (part.startsWith('IMAGE/')) {
          widgets.add(
            Image.file(
              File(part.replaceFirst('IMAGE/', '')),
              // height: MediaQuery.of(context).size.height * 0.2,
              fit: BoxFit.cover,
              // fit: BoxFit.cover,
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
        RouteEditButtons(
          currentRoute: currentRoute,
          setSheetWidget: setSheetWidget,
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

List<String> getImageSources(String description) {
  List<String> listOfItems = description.split(' ');
  final List<String> sources =
      listOfItems
          .where((word) => word.contains('src'))
          .map((word) => word.replaceAll('src=', '').replaceAll("'", '').trim())
          .toList();
  return sources;
}

String replaceImageDivs(String htmlString) {
  List<String> imageSources = getImageSources(htmlString);
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
  final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
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
