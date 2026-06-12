// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_tiles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TileEntriesNotifier)
const tileEntriesProvider = TileEntriesNotifierProvider._();

final class TileEntriesNotifierProvider
    extends $NotifierProvider<TileEntriesNotifier, MapLayerList> {
  const TileEntriesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tileEntriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tileEntriesNotifierHash();

  @$internal
  @override
  TileEntriesNotifier create() => TileEntriesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapLayerList value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapLayerList>(value),
    );
  }
}

String _$tileEntriesNotifierHash() =>
    r'4efd0013c173b00a5f1f4551f48b978cc6cb0d1e';

abstract class _$TileEntriesNotifier extends $Notifier<MapLayerList> {
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
