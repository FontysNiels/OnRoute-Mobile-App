import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Components/BottomSheet/POI/point_of_interest.dart';

class POICard extends StatelessWidget {
  final Poi currentPoi;
  const POICard({super.key, required this.currentPoi});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Navigate to ROUTE
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => POI(
                  key: UniqueKey(),
                  routeContent: currentPoi,
                
                ),
          ),
        );

        // Trigger the callback if result is true
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                            currentPoi.title,
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
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 6.0),
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       // Handle the tap event here
                  //       // Navigator.push(
                  //       //   context,
                  //       //   MaterialPageRoute(
                  //       //     builder: (context) => POI(),
                  //       //   ),
                  //       // );
                  //     },
                  //     child: Text(
                  //       "Bekijken",
                  //       style: Theme.of(context).textTheme.labelLarge,
                  //       textAlign: TextAlign.end,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
