import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_tiles_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LayerSelector extends ConsumerStatefulWidget {
  const LayerSelector({
    super.key, required this.entryType,
  });

  final EntryType entryType;

  @override
  ConsumerState<LayerSelector> createState() {
    return _LayerSelectorState();
  }
}

class _LayerSelectorState extends ConsumerState<LayerSelector> {
  late Iterable<MapLayer> layers;
  late Iterable<MapLayer> filteredLayers;

  @override
  void initState() {
    super.initState();
    layers = ref.read(tileEntriesProvider).items.where((layer)=> layer.entryType == widget.entryType);
    filteredLayers = layers;
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
          return ListTile(leading: Icon(Icons.layers_outlined),onTap: () {
          },title: Text(filteredLayers.elementAt(index).name),);
        },separatorBuilder: (context, index) => const Divider(),),
      ),
      actions: [
        TextButton(
          onPressed: () {Navigator.of(context).pop();},
          child: Text("cancel"),
        ),
        TextButton(
          onPressed: () {Navigator.of(context).pop();},
          child: Text("ok"),
        ),
      ],
    );
  }
}
