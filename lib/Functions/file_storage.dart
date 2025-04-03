import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Gets the directory
Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

// Make one that just receives a JSON File
Future<File> writeFile(String content, String name) async {
  final path = await _localPath;
  final directory = Directory('$path/routes');

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

// Read content of one File
Future<String> readRouteFile(File name) async {
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
