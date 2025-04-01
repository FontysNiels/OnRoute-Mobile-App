import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_image_preview.dart';
import 'package:onroute_app/Routes/Widgets/Package/package_tabs.dart';
import 'package:onroute_app/Routes/Widgets/Single%20Route/route_download_button.dart';
import 'package:onroute_app/Routes/Widgets/Single%20Route/route_title.dart';
import 'package:onroute_app/Routes/Widgets/Tabs/tabs_body.dart';

class SingleRoute extends StatefulWidget {
  // final Function startRoute;
  final AvailableRoutes fileLocation;
  const SingleRoute({
    super.key,
    required this.fileLocation,
    // required this.startRoute,
  });

  @override
  State<SingleRoute> createState() => _SingleRouteState();
}

int _selectedIndex = 0;

class _SingleRouteState extends State<SingleRoute> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void setIndex(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    // void _readAndPrintFile() async {
    //   // print(widget.fileLoscation);
    //   if (widget.fileLocation != '') {
    //     File test = File(widget.fileLocation);
    //     // print(await readRouteFile(test));
    //     var test2 = jsonDecode(await readRouteFile(test));
    //     // print(jsonDecode(test2));
    //     RouteLayerData routeInfo = RouteLayerData.fromJson(test2);
    //   }

    //   //niet voor titel gebruiken, maar voor starten van route
    // }

    // _readAndPrintFile();

    bool isfile = false;

    if (widget.fileLocation.routeID.endsWith('.json')) {
      isfile = true;
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
          RouteTitle(title: widget.fileLocation.routeData.title),
          // Images (PACKAGE)
          PackegImagePreview(),

          // geef routeId(s) mee aan download button
          // Download Button
          !isfile ? RouteDownloadButton(routeID: widget.fileLocation.routeID,) : Text('data'),
          // Tabs
          // Make one for Routes, or make it dynamic?
          PackageTabs(setIndex: setIndex, isPackage: false),
          // Body of tabs
          TabsBody(selectedIndex: _selectedIndex),
        ],
      ),
    );
  }
}
