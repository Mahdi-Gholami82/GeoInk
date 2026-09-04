// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProjectNotifier)
const projectProvider = ProjectNotifierProvider._();

final class ProjectNotifierProvider
    extends $NotifierProvider<ProjectNotifier, GeoinkProject?> {
  const ProjectNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectNotifierHash();

  @$internal
  @override
  ProjectNotifier create() => ProjectNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeoinkProject? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeoinkProject?>(value),
    );
  }
}

String _$projectNotifierHash() => r'a806928c2ebf79de48a1ee6bebb6728c42243562';

abstract class _$ProjectNotifier extends $Notifier<GeoinkProject?> {
  GeoinkProject? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<GeoinkProject?, GeoinkProject?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GeoinkProject?, GeoinkProject?>,
              GeoinkProject?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
