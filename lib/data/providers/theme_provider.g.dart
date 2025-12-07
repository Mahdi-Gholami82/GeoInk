// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeNotifier)
const themeProvider = ThemeNotifierProvider._();

final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, ThemeData> {
  const ThemeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$themeNotifierHash() => r'c84e057e5a8f1799176b6c58adeff48246b2d6d6';

abstract class _$ThemeNotifier extends $Notifier<ThemeData> {
  ThemeData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ThemeData, ThemeData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeData, ThemeData>,
              ThemeData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
