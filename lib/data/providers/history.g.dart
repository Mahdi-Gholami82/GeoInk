// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryNotifier)
const historyProvider = HistoryNotifierProvider._();

final class HistoryNotifierProvider
    extends $NotifierProvider<HistoryNotifier, MapHistory> {
  const HistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyNotifierHash();

  @$internal
  @override
  HistoryNotifier create() => HistoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapHistory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapHistory>(value),
    );
  }
}

String _$historyNotifierHash() => r'1463e204d486d7f7c47fd85ff5816823d6e8c35f';

abstract class _$HistoryNotifier extends $Notifier<MapHistory> {
  MapHistory build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MapHistory, MapHistory>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapHistory, MapHistory>,
              MapHistory,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
