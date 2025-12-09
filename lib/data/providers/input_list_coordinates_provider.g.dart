// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_list_coordinates_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InputListCoordinatesNotifier)
const inputListCoordinatesProvider = InputListCoordinatesProvider._();

final class InputListCoordinatesProvider
    extends
        $NotifierProvider<InputListCoordinatesNotifier, List<SheetListInput>> {
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
  InputListCoordinatesNotifier create() => InputListCoordinatesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SheetListInput> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SheetListInput>>(value),
    );
  }
}

String _$inputListCoordinatesHash() =>
    r'e3a50062a92d443d5c47af67a655a172c7dfec3f';

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
