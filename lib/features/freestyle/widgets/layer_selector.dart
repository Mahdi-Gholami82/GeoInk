import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LayerSelector extends ConsumerStatefulWidget {
  const LayerSelector({
    super.key, required this.entryType, required this.initialLayer, required this.onConfirm,
  });

  final EntryType entryType;
  final MapLayer initialLayer;
  final void Function(MapLayer selection) onConfirm;

  @override
  ConsumerState<LayerSelector> createState() {
    return _LayerSelectorState();
  }
}

class _LayerSelectorState extends ConsumerState<LayerSelector> {
  late Iterable<MapLayer> layers;
  late Iterable<MapLayer> filteredLayers;
  late MapLayer selectedLayer;

  @override
  void initState() {
    super.initState();
    layers = ref.read(tileEntriesProvider).items.where((layer)=> layer.entryType == widget.entryType);
    filteredLayers = layers;
    selectedLayer = widget.initialLayer;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
        onChanged:(value) {
          setState(() {
            if (value.isNotEmpty) {
              filteredLayers = layers.where(
                (element) => element.name.contains(value),
              );
            } else {
              filteredLayers = layers;
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Search layers...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).focusColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
        ),
      ),
      content: SizedBox(
        height: 400,
        width: 300,
        child: ListView.separated(itemCount: filteredLayers.length,itemBuilder:(context, index) {
          MapLayer currentLayer = filteredLayers.elementAt(index);
            return ListTile(
              leading: Icon(Icons.layers_outlined),
              trailing: currentLayer == selectedLayer
                  ? Icon(Icons.check)
                  : null,
              onTap: () {
                setState(() {
                  selectedLayer = currentLayer;
                });
          },title: Text(filteredLayers.elementAt(index).name),);
        },separatorBuilder: (context, index) => const Divider(),),
      ),
      actions: [
        TextButton(
          onPressed: () {Navigator.of(context).pop();},
          child: Text("cancel"),
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm(selectedLayer);
            Navigator.of(context).pop();},
          child: Text("ok"),
        ),
      ],
    );
  }
}
