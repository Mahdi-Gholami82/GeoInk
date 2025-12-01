import 'package:flutter/material.dart';
import 'package:mapify/data/models/coordinates_sheet_data_models.dart';

class InputListCoordinatesProvider with ChangeNotifier {
  String get name => inputs
      .firstWhere(
        (input) => input.type == SheetInputFieldType.name,
        orElse: () => SheetListInput.nameField(),
      )
      .value;

  List<String> get coordinates => inputs
      .where((input) => input.type == SheetInputFieldType.coordinate)
      .map((input) => input.value)
      .toList();

  String? get radius => inputs
      .firstWhere(
        (input) => input.type == SheetInputFieldType.radius,
        orElse: () => SheetListInput.radiusField(),
      )
      .value;

  late Color color;
  bool needsRadiusField = false;
  late List<SheetListInput> inputs;
  late int minNumberOfCoordinatesFields;

  void initCoordinatesProvider() {
    color = Colors.red;
    inputs = [];
  }

  void initSheetListInput() {
    initCoordinatesProvider();
    inputs.add(SheetListInput.nameField());
    inputs.addAll(
      List.generate(
        minNumberOfCoordinatesFields,
        (index) => SheetListInput.coordinateField(),
      ),
    );
    if (needsRadiusField) {
      inputs.add(SheetListInput.radiusField(input: radius ?? ""));
    }
  }

  InputCoordinatesSheetResult takeFinalResult() {
    InputCoordinatesSheetResult result = InputCoordinatesSheetResult(
      coordinates: coordinates,
      color: color,
      radius: radius,
    );
    initCoordinatesProvider();
    notifyListeners();
    return result;
  }
}
