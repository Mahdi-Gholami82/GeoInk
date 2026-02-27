import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapify/core/services/tile_providers.dart';
import 'package:mapify/core/ui/widgets/custom_sheet_drag_handle.dart';
import 'package:mapify/core/utils/map_to_image.dart';
import 'package:mapify/data/providers/flutter_map_children_provider.dart';
import 'package:mapify/core/ui/widgets/load_error.dart';

class SaveToImageButtomSheet extends ConsumerStatefulWidget {
  const SaveToImageButtomSheet({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  ConsumerState<SaveToImageButtomSheet> createState() =>
      _SaveToImageButtomSheetState();
}

class _SaveToImageButtomSheetState
    extends ConsumerState<SaveToImageButtomSheet> {
  Uint8List? mapImage;
  late List<Widget> mapChildren;
  late Future<Uint8List> imageFuture;

  @override
  void initState() {
    super.initState();
    mapChildren = ref.read(mapChildrenProvider);
  }

  @override
  Widget build(BuildContext context) {
    imageFuture = mapToImage(
      tileLayer: openStreetMapTileLayerWaitLoad,
      mapChildren: mapChildren,
    );

    imageFuture.then((Uint8List image) {
      mapImage = image;
    });
    return Stack(
      alignment: AlignmentGeometry.topCenter,
      children: [
        CustomSheetDragHandle(),
        Positioned(
          top: 10,
          left: 10,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: imageFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                        controller: widget.scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(50),
                          child: Column(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 250),
                                child: Image.memory(snapshot.data!),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return loadError(
                        message: 'Failed to load tiles.',
                        onRetry: () {
                          setState(() {});
                        },
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  minimumSize: Size(110, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  if (mapImage != null) {
                    FilePicker.platform
                        .saveFile(bytes: mapImage, type: FileType.image)
                        .then((_) {
                          if (context.mounted) Navigator.of(context).pop();
                        });
                  }
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
