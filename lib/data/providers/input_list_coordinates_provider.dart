import 'package:flutter/material.dart';
import 'package:mapify/data/models/coordinates_sheet_data.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'input_list_coordinates_provider.g.dart';

@riverpod
class InputListCoordinatesNotifier extends _$InputListCoordinates {
  Color color = Colors.red;
  MapLayerEntry? layer;
  late EntryType type;

  @override
  List<SheetListInput> build() {
    return [];
  }

  String get name => state
      .firstWhere(
        (input) => input.type == SheetInputFieldType.name,
        orElse: () => SheetListInput.nameField(),
      )
      .value;

  List<String> get coordinates => state
      .where((input) => input.type == SheetInputFieldType.coordinate)
      .map((input) => input.value)
      .toList();

  String? get radius => state
      .firstWhere(
        (input) => input.type == SheetInputFieldType.radius,
        orElse: () => SheetListInput.radiusField(),
      )
      .value;

  void _forceRebuild() {
    state = [...state];
  }

  void initSheetListInput({required EntryType initType}) {
    type = initType;
    int numberOfCoordinatesFields;
    bool needsRadiusField = false;
    state.add(SheetListInput.nameField());
    switch (type) {
      case EntryType.circle:
        numberOfCoordinatesFields = 1;
        needsRadiusField = true;

      case EntryType.marker:
        numberOfCoordinatesFields = 1;

      case EntryType.polygon:
        numberOfCoordinatesFields = 3;

      case EntryType.polyline:
        numberOfCoordinatesFields = 2;
    }
    state.addAll(
      List.generate(
        numberOfCoordinatesFields,
        (index) => SheetListInput.coordinateField(),
      ),
    );
    if (needsRadiusField) {
      state.add(SheetListInput.radiusField(input: radius ?? ""));
    }
  }

  void addCoordinatesField() {
    state.add(SheetListInput.coordinateField());
    _forceRebuild();
  }

  InputCoordinatesSheetResult takeFinalResult() {
    InputCoordinatesSheetResult result = InputCoordinatesSheetResult(
      coordinates: coordinates,
      color: color,
      radius: radius,
      layer: layer,
    );
    return result;
  }
}
