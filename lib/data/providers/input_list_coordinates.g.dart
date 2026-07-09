// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_list_coordinates.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InputListCoordinatesNotifier)
const inputListCoordinatesProvider = InputListCoordinatesNotifierProvider._();

final class InputListCoordinatesNotifierProvider
    extends
        $NotifierProvider<
          InputListCoordinatesNotifier,
          InputListCoordinatesState
        > {
  const InputListCoordinatesNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$inputListCoordinatesNotifierHash();

  @$internal
  @override
  InputListCoordinatesNotifier create() => InputListCoordinatesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InputListCoordinatesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InputListCoordinatesState>(value),
    );
  }
}

String _$inputListCoordinatesNotifierHash() =>
    r'ba1b26901d1474f41968e62a06719b636973195e';

abstract class _$InputListCoordinatesNotifier
    extends $Notifier<InputListCoordinatesState> {
  InputListCoordinatesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<InputListCoordinatesState, InputListCoordinatesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InputListCoordinatesState, InputListCoordinatesState>,
              InputListCoordinatesState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
