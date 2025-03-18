import 'dart:convert';
import 'dart:io';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Functions/math.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

Future<void> initialize() async {
  await dotenv.load(fileName: ".env");
  // gets and sets API key from .env file
  String apiKey = dotenv.env['API_KEY'] ?? 'default_api_key';
  // sets the API key for the ArcGIS environment
  ArcGISEnvironment.apiKey = apiKey;
}

class OfflineMapPage extends StatefulWidget {
  @override
  _OfflineMapPageState createState() => _OfflineMapPageState();
}

class _OfflineMapPageState extends State<OfflineMapPage> {
  late Future<List<PreplannedMapArea>> _mapAreasFuture;
  final Map<PreplannedMapArea, DownloadPreplannedOfflineMapJob?> _downloadJobs =
      {};
  Directory? _downloadDirectory;

  // Create a controller for the map view.
  final _mapViewController = ArcGISMapView.createController();
  final _stopsGraphicsOverlay = GraphicsOverlay();
  // Create a graphics overlay.
  final _graphicsOverlay = GraphicsOverlay();
  // Create symbols which will be used for each geometry type.
  late final SimpleLineSymbol _polylineSymbol;

  @override
  void initState() {
    super.initState();
    initialize();
    _mapAreasFuture = getOfflineMapAreas();
  }

  @override
  void dispose() {
    _downloadDirectory?.deleteSync(recursive: true);
    super.dispose();
  }

  void onMapViewReady() async {
    // Create a map with an imagery basemap style.
    final map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISDarkGray);
    // Set the map to the map view controller.
    _mapViewController.arcGISMap = map;
    // Add the graphics overlay to the map view.
    _mapViewController.graphicsOverlays.add(_graphicsOverlay);
    // Configure some initial graphics.
    _graphicsOverlay.graphics.addAll(await initialGraphics());
    // Set an initial viewpoint over the graphics.
    _mapViewController.graphicsOverlays.add(_stopsGraphicsOverlay);
    _mapViewController.setViewpoint(
      Viewpoint.fromCenter(
        convertToArcGISPoint(51.596998975053424, 5.526808584638516),
        scale: 5000,
      ),
    );
  }

  Future<http.Response> createMarker() async {
    // Get Car Id (By License Plate)
    final response = await http.get(
      Uri.parse(
        'https://bragis-def.maps.arcgis.com/sharing/rest/content/items/4f4cea7adeb0463c9ccb4a92d2c62dbf/data',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // 'Authorization': 'Bearer ${_credentials!.accessToken}',
      },
    );

    // String carId = jsonDecode(response.body)['_id'];
    // print(jsonDecode(response.body));
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Offline Map Areas')),
      // body: FutureBuilder<List<PreplannedMapArea>>(
      //   future: _mapAreasFuture,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(child: CircularProgressIndicator());
      //     } else if (snapshot.hasError) {
      //       return Center(child: Text('Error: ${snapshot.error}'));
      //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      //       return Center(child: Text('No offline map areas found.'));
      //     } else {
      //       final mapAreas = snapshot.data!;
      //       return ListView.builder(
      //         itemCount: mapAreas.length,
      //         itemBuilder: (context, index) {
      //           final mapArea = mapAreas[index];
      //           return Card(child: buildMapAreaListTile(mapArea));
      //         },
      //       );
      //     }
      //   },
      // ),
      body: Center(
        child: FloatingActionButton(
          onPressed: () async {
            var response = await createMarker();
            RouteLayerData routeInfo = RouteLayerData.fromJson(jsonDecode(response.body));
            // log(response.body);

            // Full route info
            routeInfo.layers[0].featureSet.features[0].attributes['RouteName'];
            // Route Part(s) Info
            routeInfo.layers[1].featureSet.features[0].attributes['ARRTIBUTE'];
            // Point Info
            routeInfo.layers[2].featureSet.features[0].attributes['ARRTIBUTE'];

            final polylineOneJson = '''
            {"paths": ${routeInfo.layers[1].featureSet.features[0].geometry.paths},
            "spatialReference":${routeInfo.layers[1].featureSet.features[0].geometry.spatialReference.toString()}}''';

            print(polylineOneJson);
          },
        ),
      ),
      // body: FutureBuilder<http.Response>(
      //   future: createMarker(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(child: CircularProgressIndicator());
      //     } else if (snapshot.hasError) {
      //       return Center(child: Text('Error: ${snapshot.error}'));
      //     } else if (!snapshot.hasData || snapshot.data!.body.isEmpty) {
      //       return Center(child: Text('No data found.'));
      //     } else {
      //       final data = jsonDecode(snapshot.data!.body);
      //       return ListView.builder(
      //         itemCount: data.length,
      //         itemBuilder: (context, index) {
      //           final item = data[index];
      //           return ListTile(
      //             title: Text(item['title'] ?? 'No Title'),
      //             subtitle: Text(item['description'] ?? 'No Description'),
      //           );
      //         },
      //       );
      //     }
      //   },
      // ),
    );
  }

  Future<List<Graphic>> initialGraphics() async {
    // Create symbols for each geometry type.
    _polylineSymbol = SimpleLineSymbol(
      style: SimpleLineSymbolStyle.solid,
      color: Colors.blue,
      width: 2,
    );

     var response = await createMarker();
            RouteLayerData routeInfo = RouteLayerData.fromJson(jsonDecode(response.body));
            // log(response.body);

            // Full route info
            routeInfo.layers[0].featureSet.features[0].attributes['RouteName'];
            // Route Part(s) Info
            routeInfo.layers[1].featureSet.features[0].attributes['ARRTIBUTE'];
            // Point Info
            routeInfo.layers[2].featureSet.features[0].attributes['ARRTIBUTE'];

            final polylineOneJson = '''
            {"paths": ${routeInfo.layers[1].featureSet.features[0].geometry.paths},
            "spatialReference":${routeInfo.layers[1].featureSet.features[0].geometry.spatialReference.toString()}}''';

    // const polylineOneJson = '''
    //     {"paths": [ [ [ 615224.858209659, 6727584.162867368 ], [ 615191.0913345609, 6727589.861555635 ],
    //      [ 615143.8362107181, 6727627.566184853 ], [ 614840.8690845782, 6727896.055434369 ], 
    //      [ 614750.5555816966, 6727975.858411968 ], [ 614711.3265931414, 6728010.518201776 ] 
    //      ] ],
    //     "spatialReference":{"latestWkid":3857,"wkid":102100}}''';


    final roadOneGeometry = Geometry.fromJsonString(polylineOneJson);

    final startPoint = ArcGISPoint(
      x: 615224.858209659,
      y: 6727584.162867368,
      spatialReference: SpatialReference.webMercator,
    );

    final routeStartCircleSymbol = SimpleMarkerSymbol(
      style: SimpleMarkerSymbolStyle.circle,
      color: Colors.blue,
      size: 15.0,
    );
    // Add the start and end points to the stops graphics overlay.
    _stopsGraphicsOverlay.graphics.addAll([
      Graphic(geometry: startPoint, symbol: routeStartCircleSymbol),
    ]);

    // Return a list of graphics for each geometry type.
    return [
      Graphic(geometry: roadOneGeometry, symbol: _polylineSymbol),
      // Graphic(geometry: roadTwoGeometry, symbol: _polylineSymbol),
    ];
  }

  Future<List<PreplannedMapArea>> getOfflineMapAreas() async {
    final portal = Portal.arcGISOnline();
    PortalConnection connection = PortalConnection.anonymous;

    final portalItem = PortalItem.withPortalAndItemId(
      portal: Portal(
        Uri.parse('https://gisportal.bragis.nl/arcgis'),
        connection: connection,
      ),
      itemId: '65e1dc5d7178478d8b30d4f93f683a91',
    );

    final offlineMapTask = OfflineMapTask.withPortalItem(portalItem);
    await offlineMapTask.load();

    final preplannedMapAreas = await offlineMapTask.getPreplannedMapAreas();
    for (final mapArea in preplannedMapAreas) {
      await mapArea.load();
    }

    return preplannedMapAreas;
  }
}
