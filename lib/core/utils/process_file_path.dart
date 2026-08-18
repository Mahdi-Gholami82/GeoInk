import 'dart:io';

({String name, String? ext}) getNameWithExtension(String fullName) {
  var match = RegExp(r"^(.*)\.(.*?)$").firstMatch(fullName);
  if (match != null) {
    return (name: match.group(1)!, ext: match.group(2)!);
  }
  return (name: fullName, ext: null);
}

String getFileNameFromPath(String path) {
  return path.substring(path.lastIndexOf(Platform.pathSeparator) + 1);
}

String getNameFromPath(String path) {
  return getNameWithExtension(getFileNameFromPath(path)).name;
}
