import 'package:geoink/core/utils/unique_name_in_list.dart';
import 'package:unique_list/unique_list.dart';

class WithNameField {
  WithNameField({required this.name});
  String name;
}

mixin UniqueNamedItems<T extends WithNameField> {
  UniqueList<T> items = UniqueList.strict();

  List<String> get namesList => items.map((e) => e.name).toList();

  String getUniqueName(String name) {
    return getUniqueNameFromTargets(name, items.map((e) => e.name).toList());
  }

  void uniqifyName(T item) {
    item.name = getUniqueName(item.name);
  }

  void addUnique(T layer) {
    uniqifyName(layer);
    items.add(layer);
  }

  void addAllUnique(List<T> newItems) {
    Map<String, int> preNamesMax = {};
    List<String> names = namesList;
    for (var item in newItems) {
      int? preMax = preNamesMax[item.name];
      int maxNum = 0;
      if (preMax == null) {
        maxNum = getUniqueMaxNum(item.name, names);
        if (maxNum == 0) {
          items.add(item);
          preNamesMax[item.name] = maxNum;
          continue;
        }
      } else {
        maxNum = preMax;
      }
      maxNum++;
      preNamesMax[item.name] = maxNum;
      item.name = "${item.name} ($maxNum)";
      items.add(item);
    }
  }
}
