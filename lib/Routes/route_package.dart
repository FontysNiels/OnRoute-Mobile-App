import 'package:flutter/material.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_download_button.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_tabs.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_title.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_image_preview.dart';
import 'package:onroute_app/Routes/Widgets/Cards/poi_card.dart';
import 'package:onroute_app/Routes/Widgets/Cards/route_card.dart';

class RoutePackage extends StatefulWidget {
  const RoutePackage({super.key});

  @override
  State<RoutePackage> createState() => _RoutePackageState();
}

int _selectedIndex = 0;

class _RoutePackageState extends State<RoutePackage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> _textWidgets = [
      //Bescrhijving
      BeschrijvingBlock(),
      // POIs
      // FutureBuilder zodat er meerdere gegeveneerd worden, of iets in die richting
      POICard(),
      // Routes
      // FutureBuilder zodat er meerdere gegeveneerd worden, of iets in die richting
      RouteCard(),
    ];

    void setIndex(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 26,
          children: [Icon(Icons.info_outline), Icon(Icons.more_vert)],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          PackageTitle(),
          // Images
          PackegImagePreview(),
          // Download Button
          PackageDownloadButton(),

          // Tabs
          PackageTabs(setIndex: setIndex),
          // Body of tabs
          Expanded(
            child: SingleChildScrollView(child: _textWidgets[_selectedIndex]),
          ),
        ],
      ),
    );
  }
}

class BeschrijvingBlock extends StatelessWidget {
  const BeschrijvingBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pretitle
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Deze set heeft 4 routes',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          // Beschrijving
          Text(
            '''Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 
    orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 
    orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ''',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
