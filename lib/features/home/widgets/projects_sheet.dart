import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/show_simple_progress.dart';
import 'package:geoink/core/ui/widgets/custom_sheet_drag_handle.dart';
import 'package:geoink/core/utils/date_time_format.dart';
import 'package:geoink/core/utils/project_storage.dart';
import 'package:geoink/core/utils/cross_project_management.dart';
import 'package:geoink/data/models/geoink_project.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:geoink/data/providers/projects.dart';

class ProjectsSheet extends ConsumerStatefulWidget {
  const ProjectsSheet({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  ConsumerState<ProjectsSheet> createState() => _ProjectsSheetState();
}

class _ProjectsSheetState extends ConsumerState<ProjectsSheet> {
  Future<List<GeoinkProject>>? projectsListFuture;
  late ProjectNotifier projectNotifier;
  late TextEditingController searchBarController;
  late final GeoinkProject? openProject;
  late List<GeoinkProject> filteredProjects;
  late List<GeoinkProject> projectsList;

  Future<List<GeoinkProject>>? loadProjects() {
    return loadProjectsList().then((value) {
      setState(() {});
      projectsList = filteredProjects = value;
      return value;
    });
  }

  @override
  void initState() {
    super.initState();
    searchBarController = TextEditingController();
    openProject = ref.read(projectProvider);
    projectNotifier = ref.read(projectProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      projectsListFuture = loadProjects();
    });
  }

  void doFilterProjects(String value) {
    if (value.isEmpty) {
      filteredProjects = projectsList;
    } else {
      filteredProjects = projectsList
          .where((e) => e.title!.contains(RegExp(value, caseSensitive: false)))
          .toList();
    }
  }

  void resetList(List<GeoinkProject> value) {
    projectsList = filteredProjects = value;
    doFilterProjects(searchBarController.text);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    void safePop() {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }

    void initNewUnsavedAndPop([String? text]) {
      projectNotifier.initNewUnsaved(text);
      Navigator.of(context).pop();
    }

    Future<void> showUnsavedDialogue({
      void Function()? onOk,
      void Function()? onCancel,
    }) async {
      return showDialog(
        context: context,
        builder: (context) {
          var navigator = Navigator.of(context);
          return AlertDialog(
            title: const Text("Warning"),
            content: Text(
              "The current project is still unsaved. continue anyway?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  onCancel?.call();
                  navigator.pop();
                },
                child: const Text("cancel"),
              ),
              TextButton(
                onPressed: () {
                  onOk?.call();
                  navigator.pop();
                },
                child: const Text("ok"),
              ),
              TextButton(
                onPressed: () {
                  projectNotifier.handleSave(context);
                  navigator.pop();
                },
                child: const Text("save"),
              ),
            ],
          );
        },
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && ref.read(projectProvider) == null) {
          if (Platform.isAndroid) {
            AndroidProjectStore.processDeletedProjects();
          }
          projectNotifier.initNewUnsaved(null);
        }
      },
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomSheetDragHandle(),
              Padding(padding: const EdgeInsetsGeometry.all(25)),
              Expanded(
                child: CustomScrollView(
                  controller: widget.scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsetsGeometry.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            spacing: 10,
                            children: [
                              Align(
                                alignment: AlignmentGeometry.topCenter,
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Icon(Icons.map_outlined, size: 120),
                                    Text(
                                      "Select or create a new project",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(padding: const EdgeInsetsGeometry.all(2)),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 50),
                                child: SearchBar(
                                  controller: searchBarController,
                                  shadowColor: WidgetStatePropertyAll(
                                    Colors.black12,
                                  ),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 7),
                                    child: const Icon(Icons.search),
                                  ),
                                  hintText: "Search Projects...",
                                  onChanged: (value) {
                                    setState(() {
                                      doFilterProjects(value);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsetsGeometry.symmetric(
                        horizontal: 30,
                      ),
                      sliver: FutureBuilder(
                        future: projectsListFuture,
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.hasData) {
                            if (filteredProjects.isEmpty) {
                              return SliverToBoxAdapter(
                                child: SizedBox.shrink(),
                              );
                            }
                            return SliverFixedExtentList(
                              itemExtent: 50,
                              delegate: SliverChildBuilderDelegate(
                                childCount: filteredProjects.length,
                                (context, index) {
                                  var currentProject = filteredProjects[index];
                                  return Dismissible(
                                    key: Key(currentProject.path!),
                                    confirmDismiss: (_) async =>
                                        currentProject !=
                                        ref.read(projectProvider),
                                    onDismissed: (_) {
                                      final project = currentProject;

                                      final path = project.path!;
                                      List<GeoinkProject> oldProjectList = [
                                        ...projectsList,
                                      ];

                                      setState(() {
                                        projectsList.removeWhere(
                                          (e) => e.path == path,
                                        );
                                        resetList(projectsList);
                                      });

                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      messenger.hideCurrentSnackBar();
                                      List<String> oldProjectPaths =
                                          PrefsState.recentProjectsPaths;

                                      if (!Platform.isAndroid) {
                                        List<String> projectPaths = [
                                          ...oldProjectPaths,
                                        ];
                                        projectPaths.remove(
                                          currentProject.path!,
                                        );
                                        PrefsState.recentProjectsPaths =
                                            projectPaths;
                                      } else {
                                        final deletedPaths = [
                                          ...PrefsState
                                              .deletedProjectsAndroidPaths,
                                        ];

                                        deletedPaths.add(path);

                                        PrefsState.deletedProjectsAndroidPaths =
                                            deletedPaths;
                                      }

                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text("Project removed"),
                                          action: SnackBarAction(
                                            label: "Undo",
                                            onPressed: () async {
                                              if (!Platform.isAndroid) {
                                                PrefsState.recentProjectsPaths =
                                                    oldProjectPaths;
                                              } else {
                                                PrefsState
                                                        .deletedProjectsAndroidPaths =
                                                    PrefsState
                                                        .deletedProjectsAndroidPaths
                                                      ..remove(path);
                                              }
                                              setState(() {
                                                resetList(oldProjectList);
                                              });
                                            },
                                          ),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      color: theme.colorScheme.surface,
                                      child: InkWell(
                                        onTap: () async {
                                          if (currentProject == openProject) {
                                            Navigator.of(context).pop();
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Selected the same project",
                                                  ),
                                                ),
                                              );
                                            }
                                            return;
                                          }
                                          if (openProject != null &&
                                              openProject!.path == null) {
                                            bool canceled = false;
                                            await showUnsavedDialogue(
                                              onCancel: () {
                                                canceled = true;
                                              },
                                            );
                                            if (canceled) {
                                              return;
                                            }
                                          }
                                          try {
                                            projectNotifier.importFromProject(
                                              currentProject,
                                            );
                                            safePop();
                                          } on PathNotFoundException {
                                            projectsList.remove(currentProject);
                                            PrefsState.setRecentProjects(
                                              projectsList,
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "File not found",
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    flex: 1,
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Icon(
                                                        Icons.image,
                                                        size: 50,
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    flex: 2,
                                                    child: LayoutBuilder(
                                                      builder: (context, constraints) {
                                                        return Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            AutoSizeText(
                                                              currentProject
                                                                  .title!,
                                                              maxLines: 1,
                                                              style:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .titleMedium,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            AutoSizeText(
                                                              currentProject
                                                                      .description ??
                                                                  "",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: FittedBox(
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 16),
                                                    AutoSizeText(
                                                      "🕔 ${customDateTimeFormat(currentProject.lastModified)}",
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      Icons.arrow_forward,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return SliverToBoxAdapter(
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                        },
                      ),
                    ),
                    SliverPadding(padding: const EdgeInsetsGeometry.all(10)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (ref.read(mapLayerListProvider).isNotEmpty) {
                              if (openProject?.path != null) {
                                showSimpleProgress(context);
                                try {
                                  await projectNotifier.saveToPathAuto();
                                } on Exception {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Failed to save The Previous Project",
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.errorContainer,
                                      ),
                                    );
                                  }
                                  return;
                                }
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Saved The Previous Project",
                                      ),
                                    ),
                                  );
                                }
                              } else if (openProject != null) {
                                showUnsavedDialogue(
                                  onOk: () {
                                    initNewUnsavedAndPop(
                                      searchBarController.text,
                                    );
                                  },
                                );
                                return;
                              }
                            }
                            initNewUnsavedAndPop(searchBarController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            minimumSize: Size.fromHeight(50),
                          ),
                          child: Text(
                            "[+]  Create New Project",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              key: const ValueKey("projectsSheetIconButtonClose"),
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
