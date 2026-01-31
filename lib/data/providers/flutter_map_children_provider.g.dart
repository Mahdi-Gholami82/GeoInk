// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flutter_map_children_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mapChildren)
const mapChildrenProvider = MapChildrenProvider._();

final class MapChildrenProvider
    extends $FunctionalProvider<List<Widget>, List<Widget>, List<Widget>>
    with $Provider<List<Widget>> {
  const MapChildrenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapChildrenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapChildrenHash();

  @$internal
  @override
  $ProviderElement<List<Widget>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Widget> create(Ref ref) {
    return mapChildren(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Widget> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Widget>>(value),
    );
  }
}

String _$mapChildrenHash() => r'07c886fef94c5b038fcf2847869c4be0506c8df8';
