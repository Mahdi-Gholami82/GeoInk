import 'dart:io';

({String name, String? ext}) getNameWithExtension(String fullName) {
  var match = RegExp(r"^(.*)\.(.*?)$").firstMatch(fullName);
  if (match != null) {
    return (name: match.group(1)!, ext: match.group(2)!);
  }
  return (name: fullName, ext: null);
}

String getNameFromPath(String path) {
  var match = RegExp(
    RegExp.escape(Platform.pathSeparator) + r"([^\/]*)$",
  ).firstMatch(path);
  String result = match!.group(1)!;
  return getNameWithExtension(result).name;
}
