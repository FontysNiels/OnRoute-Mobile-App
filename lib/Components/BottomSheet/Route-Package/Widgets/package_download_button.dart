import 'package:flutter/material.dart';

class PackageDownloadButton extends StatelessWidget {
  const PackageDownloadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download),
        label: Text(
          'Downlaod alle routes',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        iconAlignment: IconAlignment.start,
      ),
    );
  }
}
