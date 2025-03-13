import 'package:flutter/material.dart';
import 'package:onroute_app/Routes/Widgets/package_download_button.dart';
import 'package:onroute_app/Routes/Widgets/package_tabs.dart';
import 'package:onroute_app/Routes/Widgets/package_title.dart';
import 'package:onroute_app/Routes/Widgets/packeg_image_preview.dart';

class RoutePackage extends StatefulWidget {
  const RoutePackage({super.key});

  @override
  State<RoutePackage> createState() => _RoutePackageState();
}

class _RoutePackageState extends State<RoutePackage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          PackageTabs(),
        ],
      ),
    );
  }
}
