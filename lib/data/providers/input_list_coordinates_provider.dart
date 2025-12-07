import 'package:flutter/material.dart';
import 'package:mapify/data/models/coordinates_sheet_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'input_list_coordinates_provider.g.dart';

@riverpod
class InputListCoordinates extends _$InputListCoordinates {
  Color color = Colors.red;
  bool needsRadiusField = false;
  int minNumberOfCoordinatesFields = 1;
  int? maxNumberOfCoordinatesFields = 1;

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

  void initSheetListInput() {
    state.add(SheetListInput.nameField());
    state.addAll(
      List.generate(
        minNumberOfCoordinatesFields,
        (index) => SheetListInput.coordinateField(),
      ),
    );
    if (needsRadiusField) {
      state.add(SheetListInput.radiusField(input: radius ?? ""));
    }
  }

  void addCoordinatesField() {
    state.add(SheetListInput.coordinateField());
  }

  InputCoordinatesSheetResult takeFinalResult() {
    InputCoordinatesSheetResult result = InputCoordinatesSheetResult(
      coordinates: coordinates,
      color: color,
      radius: radius,
    );
    return result;
  }
}
