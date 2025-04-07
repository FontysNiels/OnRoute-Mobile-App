import 'package:flutter/material.dart';

class ListDivider extends StatelessWidget {
  final String text;
  const ListDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(child: Divider(thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(child: Divider(thickness: 1)),
            ],
          ),
        ),
        Divider(thickness: 1),
      ],
    );
  }
}
