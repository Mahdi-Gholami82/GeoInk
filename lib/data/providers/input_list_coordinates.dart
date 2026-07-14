import 'package:flutter/material.dart';
import 'package:geoink/core/utils/map_colors.dart';
import 'package:geoink/data/models/coordinates_sheet_data.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'input_list_coordinates.g.dart';

class InputListCoordinatesState {
  Color color;
  MapLayer? layer;
  List<SheetListInput> fields;
  EntryType type;

  static const Map<EntryType, int> minNumberOfCoordinatesFields = {
    EntryType.circle: 1,
    EntryType.marker: 1,
    EntryType.polyline: 2,
    EntryType.polygon: 3,
  };

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
    MapLayer? layer,
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
      .where((input) => input.type == SheetInputFieldType.coordinates)
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

  void _forceRebuild() {
    state = state.copyWith();
  }

  void initSheetListInput({required EntryType initType}) {
    int numberOfCoordinatesFields;
    final fields = <SheetListInput>[];
    fields.add(SheetListInput.nameField());
    numberOfCoordinatesFields =
        InputListCoordinatesState.minNumberOfCoordinatesFields[initType]!;
    fields.addAll(
      List.generate(
        numberOfCoordinatesFields,
        (index) => SheetListInput.coordinatesField(),
      ),
    );
    if (initType == EntryType.circle) {
      fields.add(SheetListInput.radiusField());
    }
    state = state.copyWith(
      type: initType,
      fields: fields,
      color: MapDefaultColors.fromType(initType),
      layer: null,
    );
  }

  void setColor(Color color) {
    state = state.copyWith(color: color);
  }

  void setLayer(MapLayer layer) {
    state = state.copyWith(layer: layer);
  }

  void addCoordinatesField({String input = ""}) {
    state.fields.add(SheetListInput.coordinatesField(input: input));
    _forceRebuild();
  }

  void _removeFieldUnlessEmpty(
    SheetListInput input, {
    Function? onNotEmpty,
    Function? onLenghtLimit,
  }) {
    var fields = state.fields;
    if (!(fields
            .where((e) => e.type == SheetInputFieldType.coordinates)
            .length >
        InputListCoordinatesState.minNumberOfCoordinatesFields[state.type]!)) {
      if (onLenghtLimit != null) onLenghtLimit;
      return;
    } else if (input.value.isNotEmpty) {
      if (onNotEmpty != null) onNotEmpty();
      return;
    }
    fields.remove(input);
  }

  void removeField(
    SheetListInput input, {
    Function? onNotEmpty,
    Function? onLenghtLimit,
  }) {
    _removeFieldUnlessEmpty(
      input,
      onNotEmpty: onNotEmpty,
      onLenghtLimit: onLenghtLimit,
    );
    _forceRebuild();
  }

  void clearEmptyFields({Function? onNotEmpty, Function? onLenghtLimit}) {
    var fields = state.fields;

    for (int index = fields.length - 1; index > 0; index--) {
      var coordinatesField = fields[index];
      _removeFieldUnlessEmpty(
        coordinatesField,
        onNotEmpty: onNotEmpty,
        onLenghtLimit: onLenghtLimit,
      );
    }
    _forceRebuild();
  }

  void addMultipleCoordinates(Iterable<String> results) {
    state.fields.addAll(
      results.map((e) => SheetListInput.coordinatesField(input: e)),
    );
    clearEmptyFields();
  }

  InputCoordinatesResult takeFinalResult() {
    final String name = state.name.trim();
    MapLayer layer =
        state.layer ??
        ref.read(mapLayerListProvider).getDefaultLayerEntry(state.type);
    return InputCoordinatesResult(
      name: name.isNotEmpty ? name : null,
      coordinates: state.coordinates,
      color: state.color,
      radius: state.radius,
      layer: layer,
    );
  }
}
