import 'package:flutter/material.dart';
import 'package:onroute_app/Routes/Widgets/Cards/poi_card.dart';
import 'package:onroute_app/Routes/Widgets/Cards/route_card.dart';
import 'package:onroute_app/Routes/Widgets/Tabs/Content/tabs_description_block.dart';

class TabsBody extends StatelessWidget {
  const TabsBody({super.key, required this.selectedIndex});
  final int selectedIndex;
  @override
  Widget build(BuildContext context) {
    List<Widget> textWidgets = [
      //Bescrhijving
      DescriptionBlock(),
      // POIs
      // FutureBuilder zodat er meerdere gegeveneerd worden, of iets in die richting
      // deze exporten naar Widgets/Tabs/Content
      POICard(),
      // Routes
      // FutureBuilder zodat er meerdere gegeveneerd worden, of iets in die richting
      // deze exporten naar Widgets/Tabs/Content
      RouteCard(),
    ];
    return Expanded(
      child: SingleChildScrollView(child: textWidgets[selectedIndex]),
    );
  }
}
