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
    extends $NotifierProvider<MapCameraNotifier, MapCamera?> {
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
  Override overrideWithValue(MapCamera? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapCamera?>(value),
    );
  }
}

String _$mapCameraNotifierHash() => r'81461b5e1a8fc32043dd3120544172acc333fc04';

abstract class _$MapCameraNotifier extends $Notifier<MapCamera?> {
  MapCamera? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MapCamera?, MapCamera?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapCamera?, MapCamera?>,
              MapCamera?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
