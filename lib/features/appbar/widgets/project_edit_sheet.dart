import 'package:flutter/material.dart';
import 'package:geoink/core/ui/widgets/bottom_sheet_buttons.dart';
import 'package:geoink/core/ui/widgets/custom_draggable_sheet.dart';
import 'package:geoink/core/ui/widgets/custom_sheet_drag_handle.dart';
import 'package:geoink/core/utils/date_time_format.dart';
import 'package:geoink/data/models/geoink_project.dart';

class ProjectEditSheet extends StatefulWidget {
  const ProjectEditSheet({
    super.key,
    required this.project,
    required this.onSave,
  });

  final GeoinkProject project;
  final ValueChanged<GeoinkProject> onSave;

  @override
  State<ProjectEditSheet> createState() => _ProjectEditSheetState();
}

class _ProjectEditSheetState extends State<ProjectEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project.title);
    _descriptionController = TextEditingController(
      text: widget.project.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomDraggableSheet(
      minChildSize: 0.3,
      initialChildSize: 0.7,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return Stack(
          children: [
            Column(
              children: [
                CustomSheetDragHandle(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 12,
                      bottom: 12,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomScrollView(
                              controller: scrollController,
                              slivers: [
                                SliverList.list(
                                  children: [
                                    Text(
                                      "Project properties",
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 20),

                                    TextFormField(
                                      controller: _titleController,
                                      textInputAction: TextInputAction.next,
                                      style: theme.textTheme.titleMedium,
                                      decoration: const InputDecoration(
                                        labelText: "Title",
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "Title cannot be empty";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    TextFormField(
                                      controller: _descriptionController,
                                      maxLines: 4,
                                      minLines: 3,
                                      style: theme.textTheme.bodyMedium,
                                      textInputAction: TextInputAction.newline,
                                      decoration: const InputDecoration(
                                        labelText: "Description",
                                        alignLabelWithHint: true,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    _ReadOnlyField(
                                      label: "Path",
                                      value: (widget.project.path ?? "").isEmpty
                                          ? "—"
                                          : widget.project.path ?? "",
                                      monospace: true,
                                    ),
                                    const SizedBox(height: 12),

                                    _ReadOnlyField(
                                      label: "Last modified",
                                      value: customDateTimeFormat(
                                        widget.project.lastModified,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: FittedBox(
                                      child: BottomSheetOutlinedBotton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text("Cancel"),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: FittedBox(
                                      child: BottomSheetElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            final updated = widget.project
                                                .copyWith(
                                                  title: _titleController.text
                                                      .trim(),
                                                  description:
                                                      _descriptionController
                                                          .text
                                                          .trim(),
                                                );
                                            widget.onSave(updated);
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: const Text("Save"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 10,
              top: 10,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimColor = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: dimColor),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(124),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 16, color: dimColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(color: dimColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
