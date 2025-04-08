import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:path_provider/path_provider.dart';

class OfflineMapDownloadExample extends StatefulWidget {
  const OfflineMapDownloadExample({super.key});

  @override
  State<OfflineMapDownloadExample> createState() =>
      _OfflineMapDownloadExampleState();
}

class _OfflineMapDownloadExampleState extends State<OfflineMapDownloadExample> {
  final _mapViewController = ArcGISMapView.createController();
  final _preplannedMapAreas =
      <PreplannedMapArea, DownloadPreplannedOfflineMapJob?>{};
  late OfflineMapTask _offlineMapTask;
  late ArcGISMap _webMap;
  Directory? _downloadDirectory;
  final _mapAreas = <PreplannedMapArea>[];
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initMapAndTask();
  }

  Future<void> _initMapAndTask() async {
    _downloadDirectory = await _createDownloadDirectory();

    final portal = Portal.arcGISOnline();
    final portalItem = PortalItem.withPortalAndItemId(
      portal: portal,
      itemId: 'acc027394bc84c2fb04d1ed317aac674',
    );

    _webMap = ArcGISMap.withItem(portalItem);
    _offlineMapTask = OfflineMapTask.withPortalItem(portalItem);
    await _offlineMapTask.load();

    final areas = await _offlineMapTask.getPreplannedMapAreas();
    for (final area in areas) {
      await area.load();
      _preplannedMapAreas[area] = null;
    }

    _mapAreas.addAll(areas);
    _mapViewController.arcGISMap = _webMap;

    setState(() => _ready = true);
  }

  Future<Directory> _createDownloadDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(
      '${appDir.path}${Platform.pathSeparator}offline_map_areas',
    );
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Future<ArcGISMap?> _downloadOrLoadOfflineMap(
    PreplannedMapArea mapArea,
  ) async {
    final mapDir = Directory(
      '${_downloadDirectory!.path}${Platform.pathSeparator}${mapArea.portalItem.title}',
    );

    // final areaDir = Directory(
    //     '${_downloadDirectory!.path}${Platform.pathSeparator}${area.portalItem.title}',
    //   );
    // final areas = await _offlineMapTask.getPreplannedMapAreas();

    // for (var are in areas) {
    //   print(are);
    // }
    // If map already downloaded, track it as such

    // if (mapDir.existsSync()) {
    //   final params = await _offlineMapTask
    //       .createDefaultDownloadPreplannedOfflineMapParameters(mapArea);
    //   params.updateMode = PreplannedUpdateMode.noUpdates;

    //   mapDir.createSync(recursive: true);
    //   final job = _offlineMapTask.downloadPreplannedOfflineMapWithParameters(
    //     parameters: params,
    //     downloadDirectoryUri: mapDir.uri,
    //   );

    //   _preplannedMapAreas[mapArea] = job;

    //   debugPrint('Found downloaded map: ${mapDir.path}');

    //   await job.run();
    //   if (job.status == JobStatus.succeeded) {
    //     return job.result?.offlineMap;
    //   }
    //   // _preplannedMapAreas[area] = null;
    // }

    final params2 = await _offlineMapTask
        .createDefaultDownloadPreplannedOfflineMapParameters(mapArea);
    // params2.updateMode = PreplannedUpdateMode.noUpdates;

    final jober = _offlineMapTask.downloadPreplannedOfflineMapWithParameters(
      parameters: params2,
      downloadDirectoryUri: mapDir.uri,
    );

    if (mapDir.existsSync()) {
      // await jober.run();
      // if (jober.status == JobStatus.succeeded) {
      //   return jober.result?.offlineMap;
      // }

      debugPrint('Map already downloaded at ${mapDir.path}');
      final job = _preplannedMapAreas[mapArea];
      final map = job?.result!.offlineMap;

      return map;
    }

    final params = await _offlineMapTask
        .createDefaultDownloadPreplannedOfflineMapParameters(mapArea);
    params.updateMode = PreplannedUpdateMode.noUpdates;

    mapDir.createSync(recursive: true);
    final job = _offlineMapTask.downloadPreplannedOfflineMapWithParameters(
      parameters: params,
      downloadDirectoryUri: mapDir.uri,
    );
    setState(() => _preplannedMapAreas[mapArea] = job);



    await job.run();
    if (job.status == JobStatus.succeeded) {
      return job.result?.offlineMap;
    } else {
      debugPrint('Download failed: ${job.error?.message}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Map Download Example')),
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onMapViewReady: () => debugPrint('MapView is ready'),
          ),
          if (!_ready) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomSheet:
          _ready
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      _mapAreas.map((area) {
                        return ElevatedButton(
                          child: Text('Load: ${area.portalItem.title}'),
                          onPressed: () async {
                            final map = await _downloadOrLoadOfflineMap(area);
                            if (map != null) {
                              _mapViewController.arcGISMap = map;

                              final envBuilder = EnvelopeBuilder.fromEnvelope(
                                map.initialViewpoint!.targetGeometry.extent,
                              )..expandBy(0.5);
                              final viewpoint = Viewpoint.fromTargetExtent(
                                envBuilder.toGeometry(),
                              );
                              _mapViewController.setViewpoint(viewpoint);
                            }
                          },
                        );
                      }).toList(),
                ),
              )
              : null,
    );
  }
}
