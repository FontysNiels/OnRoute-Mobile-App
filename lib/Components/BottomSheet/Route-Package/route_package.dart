import 'package:flutter/material.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_download_button.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_image_preview.dart';
import 'package:onroute_app/Components/BottomSheet/Route-Package/Widgets/package_title.dart';


class RoutePackage extends StatefulWidget {
  const RoutePackage({super.key});

  @override
  State<RoutePackage> createState() => _RoutePackageState();
}

int _selectedIndex = 0;

class _RoutePackageState extends State<RoutePackage> {
  @override
  void dispose() {
    super.dispose();
  }

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
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 26,
          children: [Icon(Icons.info_outline), Icon(Icons.more_vert)],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const PackageTitle(),
          // Images
          // const PackegImagePreview(description: '',),
          // Download Button
          const PackageDownloadButton(),
          // Tabs
          // Make one for Routes, or make it dynamic?
          // PackageTabs(setIndex: setIndex, isPackage: true),
          // Body of tabs
          // TabsBody(selectedIndex: _selectedIndex),
        ],
      ),
    );
  }
}
