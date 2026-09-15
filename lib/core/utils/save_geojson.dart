import 'dart:convert';

import 'package:file_picker/file_picker.dart';

Future<String?> saveGeoJSONFilePicker({
  required String fileName,
  required String dialogTitle,
  required String result,
}) async {
  var savedPath = await FilePicker.platform.saveFile(
    lockParentWindow: true,
    type: FileType.custom,
    dialogTitle: dialogTitle,
    allowedExtensions: ["geojson"],
    fileName: fileName,
    bytes: utf8.encode(result),
  );
  return savedPath;
}
