import 'package:flutter/material.dart';
import 'package:onroute_app/Routes/route_package.dart';

class POICard extends StatelessWidget {
  const POICard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RoutePackage()),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          // padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 9.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/temp.png',
                        height: 56,
                        width: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              style: Theme.of(context).textTheme.bodyLarge,
                              // 2 lines van maken? Titels zijn vrij lang
                              "POI Titel",
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "POI Type",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Handle the tap event here
                        },
                        child: Text(
                          "Bekijken",
                          style: Theme.of(context).textTheme.labelLarge,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
