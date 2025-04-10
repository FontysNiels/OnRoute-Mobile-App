import 'package:flutter/material.dart';

class RouteTitle extends StatelessWidget {
  final String title;
  const RouteTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      style: Theme.of(context).textTheme.headlineSmall,
      // Limiet op mijn telefoon is 60 (57 met deze text) +-, depending on woordlengte
      title,
    );
  }
}
