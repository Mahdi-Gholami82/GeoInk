// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_camera.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MapCameraNotifier)
const mapCameraProvider = MapCameraNotifierProvider._();

final class MapCameraNotifierProvider
    extends $NotifierProvider<MapCameraNotifier, MapCameraState> {
  const MapCameraNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapCameraProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapCameraNotifierHash();

  @$internal
  @override
  MapCameraNotifier create() => MapCameraNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapCameraState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapCameraState>(value),
    );
  }
}

String _$mapCameraNotifierHash() => r'91a6eb5d0ee53cffc9b4d2e0d2b32b3af151b5bf';

abstract class _$MapCameraNotifier extends $Notifier<MapCameraState> {
  MapCameraState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MapCameraState, MapCameraState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapCameraState, MapCameraState>,
              MapCameraState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
