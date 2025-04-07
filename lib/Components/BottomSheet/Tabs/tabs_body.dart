import 'package:flutter/material.dart';
import 'package:onroute_app/Components/BottomSheet/POI/poi_card.dart';
import 'package:onroute_app/Components/BottomSheet/Tabs/Content/tabs_description_block.dart';

class TabsBody extends StatelessWidget {
  const TabsBody({super.key, required this.selectedIndex});
  final int selectedIndex;
  @override
  Widget build(BuildContext context) {
    List<Widget> textWidgets = [
      //Bescrhijving
      const DescriptionBlock(),
      // POIs
      // FutureBuilder zodat er meerdere gegeveneerd worden, of iets in die richting
      // ^ deze exporten naar Widgets/Tabs/Content
      const POICard(),
      const POICard(),
      
      // Routes
      // FutureBuilder zodat er meerdere gegeveneerd worden, of iets in die richting
      // ^ deze exporten naar Widgets/Tabs/Content
      
      // deze vullen routeID, based op de routes in the package
      // RouteCard(startRoute: () {}, routeID: ''),
    ];
    return Expanded(
      child: SingleChildScrollView(child: textWidgets[selectedIndex]),
    );
  }
}
