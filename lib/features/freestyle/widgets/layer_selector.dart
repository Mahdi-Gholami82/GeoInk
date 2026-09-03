import 'package:geoink/core/ui/widgets/search_bar.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LayerSelector extends ConsumerStatefulWidget {
  const LayerSelector({
    super.key,
    required this.entryType,
    required this.initialLayer,
    required this.onConfirm,
  });

  final EntryType entryType;
  final MapLayer? initialLayer;
  final void Function(MapLayer? selection) onConfirm;

  @override
  ConsumerState<LayerSelector> createState() {
    return _LayerSelectorState();
  }
}

class _LayerSelectorState extends ConsumerState<LayerSelector> {
  late List<MapLayer> layers;
  late List<MapLayer> filteredLayers;
  late MapLayer? selectedLayer;
  bool showMainLayer = true;

  @override
  void initState() {
    super.initState();
    layers = ref
        .read(mapLayerListProvider)
        .items
        .where((layer) => layer.entryType == widget.entryType)
        .toList();
    filteredLayers = layers;
    selectedLayer = widget.initialLayer;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: CustomSearchBar(
        hint: "Search layers...",
        onChanged: (value) {
          setState(() {
            if (value.isNotEmpty) {
              filteredLayers = layers
                  .where(
                    (element) => element.name.contains(
                      RegExp(value, caseSensitive: false),
                    ),
                  )
                  .toList();
              showMainLayer = widget.entryType.mainLayerName.contains(
                RegExp(value, caseSensitive: false),
              );
            } else {
              filteredLayers = layers;
              showMainLayer = true;
            }
          });
        },
      ),
      content: SizedBox(
        height: 400,
        width: 300,
        child: CustomScrollView(
          slivers: [
            if (!layers.any((e) => e.isMain) && showMainLayer)
              SliverToBoxAdapter(
                child: ListTile(
                  leading: const Icon(Icons.layers_outlined),
                  trailing: null == selectedLayer ? Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      selectedLayer = null;
                    });
                  },
                  title: Text(widget.entryType.mainLayerName),
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: filteredLayers.length,
                (context, index) {
                  MapLayer currentLayer = filteredLayers[index];
                  return ListTile(
                    leading: const Icon(Icons.layers_outlined),
                    trailing: currentLayer == selectedLayer
                        ? Icon(Icons.check)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedLayer = currentLayer;
                      });
                    },
                    title: Text(filteredLayers[index].name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("cancel"),
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm(selectedLayer);
            Navigator.of(context).pop();
          },
          child: const Text("ok"),
        ),
      ],
    );
  }
}
