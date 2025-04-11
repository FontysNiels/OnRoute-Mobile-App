import 'package:flutter/material.dart';

class RouteTitle extends StatelessWidget {
  final String title;
  const RouteTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              style: Theme.of(context).textTheme.headlineSmall,
              // Limiet op mijn telefoon is 60 (57 met deze text) +-, depending on woordlengte
              title,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 6),
          child: IconButton.filled(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
