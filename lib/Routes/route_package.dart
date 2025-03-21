import 'package:flutter/material.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_download_button.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_tabs.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_title.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_image_preview.dart';
import 'package:onroute_app/Routes/Widgets/Tabs/tabs_body.dart';

class RoutePackage extends StatefulWidget {
  const RoutePackage({super.key});

  @override
  State<RoutePackage> createState() => _RoutePackageState();
}

int _selectedIndex = 0;

class _RoutePackageState extends State<RoutePackage> {
  @override
  Widget build(BuildContext context) {
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
          // Make one for Routes, or make it dynamic?
          PackageTabs(setIndex: setIndex),
          // Body of tabs
          TabsBody(selectedIndex: _selectedIndex,),
        ],
      ),
    );
  }
}
