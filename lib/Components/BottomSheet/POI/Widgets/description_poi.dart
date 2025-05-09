import 'package:flutter/material.dart';

class DescriptionPOI extends StatelessWidget {
  final String description;
  const DescriptionPOI({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            // 'POI beschrijving',
            'Beschrijving',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),

        // Beschrijving
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
