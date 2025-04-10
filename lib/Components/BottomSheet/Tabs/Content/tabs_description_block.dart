import 'package:flutter/material.dart';

class DescriptionBlock extends StatelessWidget {
  final String description;
  const DescriptionBlock({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    String stripHtmlTags(String htmlString) {
      // RegExp to remove all HTML tags
      final RegExp exp = RegExp(
        r'<[^>]*>',
        multiLine: true,
        caseSensitive: true,
      );

      // Replace <br/> tags with new lines
      htmlString = htmlString.replaceAll(
        RegExp(r'<div[^>]*>|<br\s*/?>', multiLine: true, caseSensitive: true),
        '\n',
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

    getImageSource();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pretitle
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Deze set heeft 4 routes',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          // Beschrijving
          Text(
            stripHtmlTags(description),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void getImageSource() {
    List<String> listOfItems = description.split(' ');
    final String sourceString =
        listOfItems
            .firstWhere((word) => word.contains('src'), orElse: () => '')
            .replaceAll('src=', '')
            .trim();
  }
}
