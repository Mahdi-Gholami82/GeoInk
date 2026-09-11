import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoink/data/models/coordinates_sheet_data.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:geoink/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:geoink/main.dart' as app;

Future<void> doCombinationKey(
  WidgetTester tester,
  List<LogicalKeyboardKey> keys,
) async {
  for (var key in keys) {
    await tester.sendKeyDownEvent(key);
  }
  await tester.pumpAndSettle();
  for (var key in keys) {
    await tester.sendKeyUpEvent(key);
  }
}

Future<void> pressUndoHotKey(WidgetTester tester) async {
  await doCombinationKey(tester, [
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyZ,
  ]);
}

Future<void> pressRedoHotKey(WidgetTester tester) async {
  await doCombinationKey(tester, [
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.keyZ,
  ]);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("User interaction scenario", () {
    testWidgets("test coordinates sheet functionality for each entry type", (
      tester,
    ) async {
      // Load app widget.
      await app.initialize();
      PrefsState.instance.clear();
      await tester.pumpWidget(ProviderScope(child: const GeoInkApp()));
      final container = tester.container();

      int randInt(int min, int max) {
        return min + Random().nextInt(max - min);
      }

      String randLatLng() => "${randInt(-90, 90)}, ${randInt(-180, 180)}";

      Finder findCoordinatesFields() {
        return find.ancestor(
          of: find.text(SheetInputFieldType.coordinates.name),
          matching: find.byType(TextFormField),
        );
      }

      MapLayerList getMapLayerList() => container.read(mapLayerListProvider);
      var mapLayerList = getMapLayerList();

      void refreshProviders() {
        mapLayerList = getMapLayerList();
      }

      void expectEntryTypes(MapLayer layer, EntryType entryType) {
        expect(layer.entryType, entryType);
        expect(layer.items.first.runtimeType, entryType.type);
      }

      /// Emulate a tap on the floating action button.
      Future<void> tapFabAndSettle() async {
        await tester.tap(find.byKey(const ValueKey("homeAddMapFeatureFab")));
        await tester.pumpAndSettle();
      }

      await tester.pumpAndSettle();
      // Expect projetcs bottom sheet to be open when opening app for the first time
      expect(find.byKey(const ValueKey("homeProjectsSheet")), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey("projectsSheetIconButtonClose")),
      );
      await tester.pumpAndSettle();

      for (var entryType in EntryType.values) {
        debugPrint("Testing $entryType");
        await tapFabAndSettle();
        await tester.tap(find.byKey(ValueKey("speedDial${entryType.name}Add")));
        await tester.pumpAndSettle();
        var fieldsFinder = findCoordinatesFields();
        var result = fieldsFinder.evaluate();
        for (int index = 0; index < result.length; index++) {
          await tester.enterText(fieldsFinder.at(index), randLatLng());
        }
        if (entryType == EntryType.circle) {
          await tester.enterText(
            find.ancestor(
              of: find.text(SheetInputFieldType.radius.name),
              matching: find.byType(TextFormField),
            ),
            "400000",
          );
        }
        await tester.tap(
          find.ancestor(
            of: find.text("Apply"),
            matching: find.byType(ElevatedButton),
          ),
        );
        await tester.pumpAndSettle();
        refreshProviders();
        expect(mapLayerList.items.length, 1);
        MapLayer addedLayer = mapLayerList.items.last;
        expectEntryTypes(addedLayer, entryType);
        expect(addedLayer.items.length, 1);

        await pressUndoHotKey(tester);
        await tester.pumpAndSettle();

        refreshProviders();
        expect(
          mapLayerList.items.isEmpty,
          true,
          reason: "items: ${mapLayerList.items}",
        );

        await pressRedoHotKey(tester);
        await tester.pumpAndSettle();

        refreshProviders();
        expect(mapLayerList.items.isEmpty, false);

        await pressUndoHotKey(tester);
        await tester.pumpAndSettle();
      }
    });
  });
}
