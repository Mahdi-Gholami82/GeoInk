import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:geoink/data/inherited/inherited_map_controller.dart';
import 'package:geoink/data/providers/projects.dart';
import 'package:geoink/features/appbar/widgets/edit_dropdown_manu.dart';
import 'package:geoink/features/appbar/widgets/file_menu.dart';
import 'package:geoink/features/appbar/widgets/free_style_dropdown_menu.dart';
import 'package:geoink/features/appbar/widgets/map_dropdown_menu.dart';

class CustomAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final Widget drawer;
  final Function onTapSettings;
  final Function onTapDrawer;
  final Color? backgroundColor;
  final double borderRadius;
  final double height;
  final MapController mapController;
  const CustomAppBar({
    super.key,
    required this.drawer,
    required this.onTapSettings,
    this.backgroundColor,
    this.borderRadius = 6,
    this.height = 80,
    required this.mapController,
    required this.onTapDrawer,
  });

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();

  @override
  final Size preferredSize = const Size.fromHeight(double.maxFinite);
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  late bool freeStyleEnabled;

  @override
  void initState() {
    freeStyleEnabled = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return InheritedMapController(
      mapController: widget.mapController,
      child: IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          color: theme.colorScheme.surfaceContainer,
          child: Align(
            alignment: AlignmentGeometry.topStart,
            child: Padding(
              padding: const EdgeInsetsGeometry.only(
                top: 5,
                left: 15,
                right: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 3,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () {
                          widget.onTapDrawer();
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          fixedSize: Size.square(40),
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(3),
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: FittedBox(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 150),
                            child: Text(
                              ref.watch(projectProvider)?.title ?? "Untitled",
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          fixedSize: Size.square(40),
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(3),
                          ),
                        ),
                        onPressed: () {
                          widget.onTapSettings();
                        },
                        icon: Icon(Icons.settings),
                      ),
                    ],
                  ),
                  Divider(),
                  FittedBox(
                    child: Padding(
                      padding: EdgeInsetsGeometry.only(bottom: 7),
                      child: Row(
                        children: [
                          FileMenu(),
                          MapDropdownMenu(),
                          FreeStyleDropdownMenu(),
                          EditDropdownManu(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
