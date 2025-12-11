import 'package:flutter/material.dart';
import 'package:mapify/data/models/coordinates_sheet_data.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'input_list_coordinates_provider.g.dart';

class InputListCoordinatesState {
  Color color;
  MapLayerEntry? layer;
  EntryType type;
  List<SheetListInput> fields;

  InputListCoordinatesState({
    required this.color,
    required this.layer,
    required this.type,
    required this.fields,
  });

  InputListCoordinatesState.empty()
    : color = Colors.red,
      layer = null,
      type = EntryType.marker,
      fields = [];

  InputListCoordinatesState copyWith({
    Color? color,
    MapLayerEntry? layer,
    EntryType? type,
    List<SheetListInput>? fields,
  }) {
    return InputListCoordinatesState(
      color: color ?? this.color,
      layer: layer ?? this.layer,
      type: type ?? this.type,
      fields: fields ?? this.fields,
    );
  }

  String get name => fields
      .firstWhere(
        (input) => input.type == SheetInputFieldType.name,
        orElse: () => SheetListInput.nameField(),
      )
      .value;

  List<String> get coordinates => fields
      .where((input) => input.type == SheetInputFieldType.coordinate)
      .map((input) => input.value)
      .toList();

  String? get radius => fields
      .firstWhere(
        (input) => input.type == SheetInputFieldType.radius,
        orElse: () => SheetListInput.radiusField(),
      )
      .value;
}

@riverpod
class InputListCoordinatesNotifier extends _$InputListCoordinatesNotifier {
  @override
  InputListCoordinatesState build() {
    return InputListCoordinatesState.empty();
  }

  void initSheetListInput({required EntryType initType}) {
    int numberOfCoordinatesFields;
    bool needsRadiusField = false;
    final fields = <SheetListInput>[];
    fields.add(SheetListInput.nameField());
    switch (initType) {
      case EntryType.circle:
        numberOfCoordinatesFields = 1;
        needsRadiusField = true;
        break;
      case EntryType.marker:
        numberOfCoordinatesFields = 1;
        break;
      case EntryType.polygon:
        numberOfCoordinatesFields = 3;
        break;
      case EntryType.polyline:
        numberOfCoordinatesFields = 2;
        break;
    }
    fields.addAll(
      List.generate(
        numberOfCoordinatesFields,
        (index) => SheetListInput.coordinateField(),
      ),
    );
    if (needsRadiusField) {
      fields.add(SheetListInput.radiusField());
    }
    state = state.copyWith(
      type: initType,
      fields: fields,
      color: Colors.red,
      layer: null,
    );
  }

  void setColor(Color color) {
    state = state.copyWith(color: color);
  }

  void setLayer(MapLayerEntry layer) {
    state = state.copyWith(layer: layer);
  }

  void addCoordinatesField() {
    state = state.copyWith(
      fields: [...state.fields, SheetListInput.coordinateField()],
    );
  }

  InputCoordinatesSheetResult takeFinalResult() {
    return InputCoordinatesSheetResult(
      coordinates: state.coordinates,
      color: state.color,
      radius: state.radius,
      layer: state.layer,
    );
  }
}
