import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mapify/core/utils/map_icons.dart' as map_icons;
import 'package:mapify/data/models/map_entry_data_models.dart';
import 'package:mapify/data/providers/map_tiles_provider.dart';
import 'package:provider/provider.dart';

class MapDrawer extends StatefulWidget {
  const MapDrawer({super.key});

  @override
  State<MapDrawer> createState() => _MapDrawerState();
}

class _MapDrawerState extends State<MapDrawer> {
  Icon _getLayerIcon(EntryType type) {
    switch (type) {
      case EntryType.circle:
        return map_icons.circleIcon;
      case EntryType.marker:
        return map_icons.markerIcon;
      case EntryType.polygon:
        return map_icons.polygonIcon;
      case EntryType.polyline:
        return map_icons.polylineIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MapLayerEntry> collection = context
        .watch<TileEntriesProvider>()
        .mapEntriesCollection;
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Map Layers',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: collection.length,
              itemBuilder: (BuildContext context, int index) {
                MapLayerEntry layer = collection[index];
                return ExpansionTile(
                  leading: _getLayerIcon(layer.type),
                  title: Text(layer.name),
                  children: layer.items.map((item) {
                    return ListTile(
                      title: Text(item.name),
                      trailing: IconButton(
                        onPressed: () {
                          item.toggleVisiblity();
                        },
                        icon: Icon(
                          item.visible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
