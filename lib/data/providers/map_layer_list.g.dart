// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_layer_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MapLayerListNotifier)
const mapLayerListProvider = MapLayerListNotifierProvider._();

final class MapLayerListNotifierProvider
    extends $NotifierProvider<MapLayerListNotifier, MapLayerList> {
  const MapLayerListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapLayerListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapLayerListNotifierHash();

  @$internal
  @override
  MapLayerListNotifier create() => MapLayerListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapLayerList value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapLayerList>(value),
    );
  }
}

String _$mapLayerListNotifierHash() =>
    r'492027e95206dda9d139594dd9f7977c83607546';

abstract class _$MapLayerListNotifier extends $Notifier<MapLayerList> {
  MapLayerList build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MapLayerList, MapLayerList>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapLayerList, MapLayerList>,
              MapLayerList,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
