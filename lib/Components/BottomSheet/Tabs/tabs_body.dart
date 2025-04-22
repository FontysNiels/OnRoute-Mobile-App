import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/TESTCLASS.dart';
import 'package:onroute_app/Components/BottomSheet/POI/poi_card.dart';
import 'package:onroute_app/Components/BottomSheet/Tabs/Content/tabs_description_block.dart';

class TabsBody extends StatelessWidget {
  final WebMapCollection currentRoute;
  const TabsBody({
    super.key,
    required this.selectedIndex,
    required this.routeDescription,
    required this.currentRoute,
  });
  final int selectedIndex;
  final String routeDescription;
  @override
  Widget build(BuildContext context) {

    List<Widget> textWidgets = [
      //Bescrhijving
      DescriptionBlock(description: routeDescription),
      // POIs
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: currentRoute.pointsOfInterest.length,
        itemBuilder: (context, index) {
          return POICard(currentPoi: currentRoute.pointsOfInterest[index]);
        },
      ),

      Container(),

      // Routes
      // FutureBuilder zodat er meerdere gegeveneerd worden, of iets in die richting
      // ^ deze exporten naar Widgets/Tabs/Content

      // deze vullen routeID, based op de routes in the package
      // RouteCard(startRoute: () {}, routeID: ''),
    ];
    return textWidgets[selectedIndex];
  }
}
