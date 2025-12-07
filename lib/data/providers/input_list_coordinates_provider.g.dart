// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_list_coordinates_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InputListCoordinates)
const inputListCoordinatesProvider = InputListCoordinatesProvider._();

final class InputListCoordinatesProvider
    extends $NotifierProvider<InputListCoordinates, List<SheetListInput>> {
  const InputListCoordinatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inputListCoordinatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inputListCoordinatesHash();

  @$internal
  @override
  InputListCoordinates create() => InputListCoordinates();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SheetListInput> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SheetListInput>>(value),
    );
  }
}

String _$inputListCoordinatesHash() =>
    r'256c30317a6be1a4b7a4465f966350e4fb3aed04';

abstract class _$InputListCoordinates extends $Notifier<List<SheetListInput>> {
  List<SheetListInput> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<SheetListInput>, List<SheetListInput>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SheetListInput>, List<SheetListInput>>,
              List<SheetListInput>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
