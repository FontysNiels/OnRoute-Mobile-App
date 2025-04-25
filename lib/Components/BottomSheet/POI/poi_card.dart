import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/TESTCLASS.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Components/BottomSheet/POI/point_of_interest.dart';
import 'package:onroute_app/Components/BottomSheet/TripContent/trip_info_bar.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_handle.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';

class POICard extends StatelessWidget {
  final Poi currentPoi;
  final ScrollController scroller;
  final Function setSheetWidget;
  final WebMapCollection currentRoute;
  const POICard({
    super.key,
    required this.currentPoi,
    required this.scroller,
    required this.setSheetWidget,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Navigate to ROUTE
        await moveSheetTo(0.9);
        setSheetWidget(
          Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: BottomSheetHandle(context: context),
                  ),
                  POI(
                    key: UniqueKey(),
                    routeContent: currentPoi,
                    scroller: scroller,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 22),
                  child: IconButton.filled(
                    icon: Icon(Icons.close),
                    onPressed: () async {
                      setSheetWidget(null, false);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).primaryColor.withValues(alpha: 1.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          false,
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
