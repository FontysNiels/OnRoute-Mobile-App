import 'dart:io';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart';
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

Future<List> getRouteFolders() async {
  try {
    final path = await _localPath;
    final directory = Directory('$path/routes');

    // Recursively process files and directories
    List<dynamic> processDirectory(Directory dir) {
      final entities = dir.listSync();
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

    List<dynamic> result = processDirectory(directory);
    for (var i = 0; i < result.length; i++) {
      if (result[i] is List) {
        final folderName =
            (result[i] as List).isNotEmpty
                ? (result[i] as List).first.parent.path.split('/').last
                : 'unknown';
        result[i] = {
          "package": {"id": folderName, "files": result[i]},
        };
      }
    }

    return result;
  } catch (e) {
    // If encountering an error, return an empty list
    return [];
  }
}

// Read content of one File
Future<String> readFile(File name) async {
  try {
    // final path = await _localPath;
    // final directory = Directory('$path/routes');
    // final file = File(name);

    // Read the file
    return await name.readAsString();
  } catch (e) {
    // If encountering an error, return an empty string
    return '';
  }
}

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
