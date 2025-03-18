import 'package:flutter/material.dart';

class PackageTitle extends StatelessWidget {
  const PackageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        style: Theme.of(context).textTheme.headlineSmall,
        // Limiet op mijn telefoon is 60 (57 met deze text) +-, depending on woordlengte
        "Bergsebosfietsen - Genieten over heuvelrug en kromme rijn gebied",
      ),
    );
  }
}
