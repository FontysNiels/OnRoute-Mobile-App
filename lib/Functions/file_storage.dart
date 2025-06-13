import 'dart:convert';
import 'dart:io';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart';
import 'package:onroute_app/Classes/poi.dart';
import 'package:onroute_app/Classes/route_layer_data.dart';
import 'package:onroute_app/Classes/web_map_collection.dart';
import 'package:onroute_app/Functions/api_calls.dart';
import 'package:onroute_app/Functions/fetch_routes.dart';
import 'package:path_provider/path_provider.dart';

// Gets the directory
Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

// Make one that just receives a JSON File
Future<File> writeFile(String content, String name, String folder) async {
  final path = await _localPath;
  final directory = Directory('$path/routes/$folder');

  // Create the directory if it doesn't exist
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final file = File('${directory.path}/$name');

  // Write the file
  return file.writeAsString('$content');
}

// Deletes all files in the routes folder
Future<void> deleteAllSavedFiles() async {
  try {
    final path = await _localPath;
    final directory = Directory('$path/routes');

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  } catch (e) {
    // Handle any errors if needed
    print('Error deleting files: $e');
  }
}

// Deletes the route info for a specific webId (this includes images)
Future<void> deleteRouteInfo(String webId) async {
  try {
    final path = await _localPath;
    final directory = Directory('$path/routes/$webId');

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  } catch (e) {
    // Handle any errors if needed
    print('Error deleting files: $e');
  }
}

// Get all files
Future<List<File>> getRouteFiles() async {
  try {
    final path = await _localPath;
    final directory = Directory('$path/routes');

    // List only files in the directory
    return directory.listSync().whereType<File>().toList();
  } catch (e) {
    // If encountering an error, return an empty list
    return [];
  }
}

// Gets all Folders
Future<List> getRouteFolders() async {
  try {
    final path = await _localPath;
    final directory = Directory('$path/routes');

    // Recursively process files and directories
    List<dynamic> processDirectory(Directory dir) {
      // List all entities in the directory
      final entities = dir.listSync();
      // If the directory is empty, return an empty list
      return entities
          .map((entity) {
            if (entity is File) {
              return entity;
            } else if (entity is Directory) {
              return processDirectory(entity);
            }
            return null;
          })
          .where((e) => e != null)
          .toList();
    }

    // Process the directory and return a list of files and folders
    List<dynamic> result = processDirectory(directory);
    // Convert the result to a List of dynamic type
    for (var i = 0; i < result.length; i++) {
      // If the result is a List, it means it's a folder with files
      if (result[i] is List) {
        // Get the folder name from the first file's parent path
        final folderName =
            (result[i] as List).isNotEmpty
                ? (result[i] as List).first.parent.path.split('/').last
                : 'unknown';
        result[i] = {
          "package": {"id": folderName, "files": result[i]},
        };
      }
    }
    // Return the processed list of files and folders
    return result;
  } catch (e) {
    // If encountering an error, return an empty list
    return [];
  }
}

// Read content of one File
Future<String> readFile(File name) async {
  try {
    // Read the file
    return await name.readAsString();
  } catch (e) {
    // If encountering an error, return an empty string
    return '';
  }
}

// Turns a Flutter Asset into a File
Future<File> copyAssetToFile(String assetPath, String filename) async {
  // Load asset as ByteData
  final byteData = await rootBundle.load(assetPath);

  // Get device directory to store the file
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');

  // Write bytes to file
  await file.writeAsBytes(byteData.buffer.asUint8List());

  return file; // Now you can use File() on this path
}

//Clears the MMPK data when it isn't used
Future<void> clearMMPKStorage() async {
  final appDir = await getApplicationDocumentsDirectory();
  // Do this when the route stops or smtn
  final directory = Directory(appDir.path);
  final List<FileSystemEntity> entities = directory.listSync(recursive: true);
  for (var entity in entities) {
    // print(entity.path);
    if (entity.path.contains('MMP.mmpk')) {
      try {
        await entity.delete(recursive: true);
        // print('Deleted: ${entity.path}');
      } catch (e) {
        // print('Error deleting ${entity.path}: $e');
      }
    } else {
      // print(entity.path);
    }
  }
}

// Download function for the route-download
Future<void> downloadRouteLayer(
  WebMapCollection route,
  BuildContext context,
) async {
  // Get ArcGIS route layer data JSON
  var routeResponse = await getArcgisItemData(route.availableRoute[0].routeID);

  // Clean it up
  RouteLayerData routeInfo = await filterRouteInfo(routeResponse, route, true);

  Map<String, dynamic> allPoiJSON = {'points': []};
  for (Poi point in route.pointsOfInterest) {
    // Turning the Poi into JSON
    var poiAsJSON = point.toJson();
    // Save the image, ad set its path in the JSON
    if (poiAsJSON['asset'] != '') {
      poiAsJSON['asset'] = await saveImageFromUrl(
        poiAsJSON['asset'],
        route.webmapId + poiAsJSON['objectId'].toString(),
        route.webmapId,
      );
    }
    // add the POI to the list of POIs
    (allPoiJSON['points'] as List).add(poiAsJSON);
  }

  // used to be used for the potential package check, to see if the route was already downloaded
  // var folderContent = await getRouteFolders();

  // Encode the routeInfo so it can be saved as a JSON file
  var encodeRoute = jsonEncode(routeInfo.toJson());
  // Save the route info as a JSON file
  await writeFile(
    encodeRoute,
    'route-${route.availableRoute[0].routeID}.json',
    route.webmapId,
  );
  // Encode the poi info so it can be saved as a JSON file
  var encodePoi = jsonEncode(allPoiJSON);
  // Save the POI info as a JSON file
  await writeFile(encodePoi, 'pois-${route.webmapId}.json', route.webmapId);
}

// Save a image to the device
Future<String> saveImageFromUrl(
  String imageUrl,
  String fileName,
  String webId,
) async {
  try {
    final response = await get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final path = await _localPath;
      final directory = Directory('$path/routes/$webId');

      // Create the directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/$fileName');

      // Write the image bytes to the file
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception('Failed to download image: ${response.statusCode}');
    }
  } catch (e) {
    // print('Error saving image: $e');
    rethrow;
  }
}

///////////////////////////// OLD MMPK DOWNLOAD CODE ///////////////////////////////////////////////////////////////

Future<void> downloadSampleData(List<String> portalItemIds) async {
  // var token = await generateToken();
  const portal = 'https://bragis-def.maps.arcgis.com';
  // Location where files are saved to on the device. Persists while the app persists.
  final appDirPath = (await getApplicationDocumentsDirectory()).absolute.path;

  for (final itemId in portalItemIds) {
    // Create a portal item to ensure it exists and load to access properties.
    final portalItem = PortalItem.withUri(
      Uri.parse('$portal/home/item.html?id=$itemId'),
    );
    if (portalItem == null) continue;

    await portalItem.load();
    final itemName = portalItem.name;
    final filePath = '$appDirPath/$itemName';
    final file = File(filePath);
    if (file.existsSync()) continue;

    final request = await _fetchData(portal, itemId);
    file.createSync(recursive: true);
    file.writeAsBytesSync(request.bodyBytes, flush: true);

    if (itemName.contains('.zip')) {
      // If the data is a zip we need to extract it.
      await extractZipArchive(file);
    }
  }
}

Future<void> extractZipArchive(File archiveFile) async {
  // Save all files to a directory with the filename without the zip extension in the same directory as the zip file.
  final pathWithoutExt = archiveFile.path.replaceFirst(RegExp(r'.zip$'), '');
  final dir = Directory.fromUri(Uri.parse(pathWithoutExt));
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  await ZipFile.extractToDirectory(zipFile: archiveFile, destinationDir: dir);
}

/// Fetch data from the provided Portal and PortalItem ID and return the response.
Future<Response> _fetchData(String portal, String itemId) async {
  return get(Uri.parse('$portal/sharing/rest/content/items/$itemId/data'));
}
