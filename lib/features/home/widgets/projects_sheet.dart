import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/show_simple_progress.dart';
import 'package:geoink/core/ui/widgets/custom_sheet_drag_handle.dart';
import 'package:geoink/core/utils/date_time_format.dart';
import 'package:geoink/core/utils/handle_save.dart';
import 'package:geoink/core/utils/show_simple_snackbar.dart';
import 'package:geoink/data/models/geoink_project.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:geoink/data/providers/projects.dart';
import 'package:path_provider/path_provider.dart';

class ProjectsSheet extends ConsumerStatefulWidget {
  ProjectsSheet({required this.scrollController}) {}
  final ScrollController scrollController;

  @override
  ConsumerState<ProjectsSheet> createState() => _ProjectsSheetState();
}

class _ProjectsSheetState extends ConsumerState<ProjectsSheet> {
  Future<List<GeoinkProject>>? recentProjectsFuture;
  late final Directory projectsDirectory;
  late ProjectNotifier projectNotifier;
  late TextEditingController searchBarController;
  late final GeoinkProject? openProject;

  @override
  void initState() {
    super.initState();
    searchBarController = TextEditingController();
    openProject = ref.read(projectProvider);
    projectNotifier = ref.read(projectProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      projectsDirectory = await getApplicationDocumentsDirectory();
      recentProjectsFuture = PrefsState.loadRecentProjects().then((value) {
        setState(() {});
        return value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);

    void initNewUnsavedAndPop([String? text]) {
      projectNotifier.initNewUnsaved(text);
      navigator.pop();
    }

    Future<void> showUnsavedDialogue({
      void Function()? onOk,
      void Function()? onCancel,
    }) async {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Warning"),
            content: Text(
              "The current project is still unsaved. continue anyway?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  onCancel?.call();
                  navigator.pop();
                },
                child: Text("cancel"),
              ),
              TextButton(
                onPressed: () {
                  onOk?.call();
                  navigator.pop();
                },
                child: Text("ok"),
              ),
              TextButton(
                onPressed: () {
                  handleSaveAs(context, ref);
                  navigator.pop();
                },
                child: Text("save"),
              ),
            ],
          );
        },
      );
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.only(left: 20, top: 10),
          child: Text("Projects", style: TextStyle(fontSize: 25)),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            onPressed: () {
              if (openProject == null) {
                projectNotifier.initNewUnsaved(null);
              }
              navigator.pop();
            },
            icon: Icon(Icons.close),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSheetDragHandle(),
            Padding(padding: EdgeInsetsGeometry.all(25)),
            Expanded(
              child: CustomScrollView(
                controller: widget.scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsetsGeometry.only(bottom: 20),
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
                            Padding(padding: EdgeInsetsGeometry.all(2)),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 50),
                              child: SearchBar(
                                controller: searchBarController,
                                shadowColor: WidgetStatePropertyAll(
                                  Colors.black12,
                                ),
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 7),
                                  child: Icon(Icons.search),
                                ),
                                hintText: "Search Projects...",
                                onChanged: (value) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 30),
                    sliver: FutureBuilder(
                      future: recentProjectsFuture,
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.hasData) {
                          List<GeoinkProject> projects = asyncSnapshot.data!;
                          if (projects.isEmpty)
                            return SliverToBoxAdapter(child: SizedBox.shrink());
                          return SliverFixedExtentList(
                            itemExtent: 50,
                            delegate: SliverChildBuilderDelegate(
                              childCount: projects.length,
                              (context, index) {
                                var currentProject = projects[index];
                                return InkWell(
                                  onTap: () async {
                                    if (currentProject == openProject) {
                                      debugPrint("selected same project");
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
                                      navigator.pop();
                                    } on PathNotFoundException {
                                      projects.remove(currentProject);
                                      showSimpleSnackBar(
                                        context,
                                        message: "File Not Found",
                                      );
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
                                                        currentProject.title!,
                                                        maxLines: 1,
                                                        style: Theme.of(
                                                          context,
                                                        ).textTheme.titleMedium,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      AutoSizeText(
                                                        currentProject
                                                                .description ??
                                                            "",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
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
                                              const Icon(Icons.arrow_forward),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
                  SliverPadding(padding: EdgeInsetsGeometry.all(10)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (openProject?.path != null) {
                            showSimpleProgress(context);
                            await projectNotifier.saveToPath();
                            navigator.pop();
                            showSimpleSnackBar(
                              context,
                              message: "Saved The Previous File",
                            );
                          } else if (openProject != null) {
                            showUnsavedDialogue(
                              onOk: () {
                                initNewUnsavedAndPop(searchBarController.text);
                              },
                            );
                            return;
                          }
                          initNewUnsavedAndPop(searchBarController.text);
                        },
                        child: Text(
                          "[+]  Create New Project",
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          minimumSize: Size.fromHeight(50),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
