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
    extends $NotifierProvider<TileEntriesNotifier, List<MapLayerEntry>> {
  const TileEntriesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tileEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tileEntriesNotifierHash();

  @$internal
  @override
  TileEntriesNotifier create() => TileEntriesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MapLayerEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MapLayerEntry>>(value),
    );
  }
}

String _$tileEntriesNotifierHash() =>
    r'b0da5db6a9ef5595fe6d5cd47cb2286afbfaba44';

abstract class _$TileEntriesNotifier extends $Notifier<List<MapLayerEntry>> {
  List<MapLayerEntry> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<MapLayerEntry>, List<MapLayerEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<MapLayerEntry>, List<MapLayerEntry>>,
              List<MapLayerEntry>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
