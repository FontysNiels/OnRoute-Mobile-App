import 'package:flutter/material.dart';

class PackegImagePreview extends StatelessWidget {
  const PackegImagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            spacing: 16,
            children: [
              // Big image
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/temp.png',
                    height: MediaQuery.of(context).size.height * 0.2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Smaller image
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/temp.png',
                    height: MediaQuery.of(context).size.height * 0.2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
            child: GestureDetector(
              onTap: () {
                // Handle the tap event here
              },
              child: Text(
                "Zie alle",
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
