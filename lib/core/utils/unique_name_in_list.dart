import 'dart:math' as math;

RegExp uniquePattern = RegExp(r"^(.*?)(?:\s\((\d+)\))?$");

RegExp getUniqueNamePattern(String name) {
  return RegExp(r"^(" + RegExp.escape(name) + r")(?:\s\((\d+)\))?");
}

int getUniqueMaxNum(String name, List<String> targetList) {
  var uniqueNamePattern = getUniqueNamePattern(name);
  List<int> nums = targetList.map((e) {
    var match = uniqueNamePattern.firstMatch(e);
    if (match != null) {
      return int.parse(match.group(2) ?? "1");
    }
    return 0;
  }).toList();
  nums.add(0);
  return nums.reduce(math.max);
}

String getUniqueNameFromTargets(String name, List<String> targetList) {
  int maxNum = getUniqueMaxNum(name, targetList);
  if (maxNum == 0) {
    return name;
  }
  return "$name (${maxNum + 1})";
}

List<String> getUniqueNameAll(List<String> names, List<String> targetList) {
  Map<String, int> preNamesMax = {};
  List<String> results = [];
  for (var name in names) {
    int? preMax = preNamesMax[name];
    int maxNum = 0;
    if (preMax == null) {
      maxNum = getUniqueMaxNum(name, targetList);
      if (maxNum == 0) {
        results.add(name);
        continue;
      }
    } else {
      maxNum = preMax;
    }
    maxNum++;
    preNamesMax[name] = maxNum;
    name = "${name} (${maxNum})";
    results.add(name);
  }
  return results;
}
