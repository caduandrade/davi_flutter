import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tab(WidgetTester tester, {bool reverse = false}) async {
  if (reverse) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  if (reverse) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  // TextField cursor animation prevents using an unbounded settle loop.
  for (int i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('pinned columns use their own horizontal area with variable rows',
      (tester) async {
    final nodes = <String, FocusNode>{};
    final horizontal = ScrollController();
    final pinned = ScrollController();
    final vertical = ScrollController();
    addTearDown(() {
      for (final node in nodes.values) {
        node.dispose();
      }
      horizontal.dispose();
      pinned.dispose();
      vertical.dispose();
    });
    final model = DaviModel<int>(rows: List.generate(12, (i) => i), columns: [
      for (int column = 0; column < 3; column++)
        DaviColumn<int>(
            width: column == 0 ? 90 : 170,
            pinStatus: column == 0 ? PinStatus.left : PinStatus.none,
            cellWidget: (p) {
              final id = '${p.rowIndex}:$column';
              return SizedBox(
                  height: p.rowIndex.isEven ? 55 : 95,
                  child: TextField(
                      key: ValueKey(id),
                      focusNode: nodes.putIfAbsent(id, () => FocusNode())));
            }),
    ]);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 300,
                height: 220,
                child: Davi<int>(model,
                    verticalScrollController: vertical,
                    unpinnedHorizontalScrollController: horizontal,
                    leftPinnedHorizontalScrollController: pinned)))));
    await tester.pumpAndSettle();
    nodes['0:0']!.requestFocus();
    await tester.pump();
    for (int index = 1; index < 16; index++) {
      await tab(tester);
      final id = '${index ~/ 3}:${index % 3}';
      expect(nodes[id]?.hasPrimaryFocus, isTrue, reason: id);
      final rect = tester.getRect(find.byKey(ValueKey(id)));
      expect(rect.left, greaterThanOrEqualTo(index % 3 == 0 ? 0 : 90));
      expect(rect.right, lessThanOrEqualTo(300));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(220));
      expect(pinned.offset, 0);
    }
    expect(vertical.offset, greaterThan(0));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'rapid TABs preserve order using TextFields with internal focus nodes',
      (tester) async {
    final model = DaviModel<int>(rows: List.generate(50, (i) => i), columns: [
      DaviColumn<int>(
          cellWidget: (p) => TextField(key: ValueKey('field-${p.rowIndex}'))),
    ]);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(width: 250, height: 180, child: Davi<int>(model)))));
    await tester.pumpAndSettle();
    FocusNode node(int row) => tester
        .widget<EditableText>(find.descendant(
            of: find.byKey(ValueKey('field-$row')),
            matching: find.byType(EditableText)))
        .focusNode;
    expect(find.byKey(const ValueKey('field-15')), findsNothing);
    node(0).requestFocus();
    await tester.pump();
    for (int i = 0; i < 15; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    }
    for (int i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(tester.takeException(), isNull);
    expect(node(15).hasPrimaryFocus, isTrue);
    expect(find.byType(TextField).evaluate().length, lessThan(12));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('pending traversal does not steal focus after leaving the table',
      (tester) async {
    final outside = FocusNode();
    addTearDown(outside.dispose);
    final model = DaviModel<int>(rows: List.generate(50, (i) => i), columns: [
      DaviColumn<int>(
          cellWidget: (p) => TextField(
              key: ValueKey(p.rowIndex),
              enabled: p.rowIndex == 0 || p.rowIndex == 49)),
    ]);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Column(children: [
      SizedBox(width: 250, height: 180, child: Davi<int>(model)),
      TextField(focusNode: outside),
    ]))));
    await tester.pumpAndSettle();
    tester
        .widget<EditableText>(find.descendant(
            of: find.byKey(const ValueKey(0)),
            matching: find.byType(EditableText)))
        .focusNode
        .requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    outside.requestFocus();
    for (int i = 0; i < 20; i++) {
      await tester.pump();
    }
    expect(outside.hasPrimaryFocus, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('TAB and Shift+TAB reveal virtual rows and horizontal columns',
      (tester) async {
    final nodes = <String, FocusNode>{};
    final vertical = ScrollController();
    final horizontal = ScrollController();
    final after = FocusNode();
    addTearDown(() {
      for (final node in nodes.values) {
        node.dispose();
      }
      vertical.dispose();
      horizontal.dispose();
      after.dispose();
    });
    final model = DaviModel<int>(rows: List.generate(30, (i) => i), columns: [
      for (int column = 0; column < 3; column++)
        DaviColumn<int>(
            width: 180,
            cellWidget: (params) {
              final id = '${params.rowIndex}:$column';
              return TextField(
                  key: ValueKey(id),
                  focusNode:
                      nodes.putIfAbsent(id, () => FocusNode(debugLabel: id)));
            }),
    ]);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Column(children: [
      SizedBox(
          width: 300,
          height: 220,
          child: Davi<int>(model,
              verticalScrollController: vertical,
              unpinnedHorizontalScrollController: horizontal)),
      TextButton(
          focusNode: after, onPressed: () {}, child: const Text('After')),
    ]))));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('10:0')), findsNothing);
    nodes['0:0']!.requestFocus();
    await tester.pump();
    for (int index = 1; index <= 32; index++) {
      await tab(tester);
      final id = '${index ~/ 3}:${index % 3}';
      expect(nodes[id]?.hasPrimaryFocus, isTrue, reason: 'TAB to $id');
      final bounds = tester.getRect(find.byKey(ValueKey(id)));
      expect(bounds.left, greaterThanOrEqualTo(0));
      expect(bounds.right, lessThanOrEqualTo(300));
      expect(bounds.top, greaterThanOrEqualTo(0));
      expect(bounds.bottom, lessThanOrEqualTo(220));
    }
    expect(vertical.offset, greaterThan(0));
    expect(horizontal.offset, greaterThan(0));
    for (int index = 31; index >= 0; index--) {
      await tab(tester, reverse: true);
      final id = '${index ~/ 3}:${index % 3}';
      expect(nodes[id]?.hasPrimaryFocus, isTrue, reason: 'Shift+TAB to $id');
    }
    expect(vertical.offset, closeTo(0, 0.01));
    expect(horizontal.offset, closeTo(0, 0.01));

    // Traversal at the last logical cell leaves the table.
    vertical.jumpTo(vertical.position.maxScrollExtent);
    for (int i = 0; i < 8; i++) {
      await tester.pump();
    }
    nodes['29:2']!.requestFocus();
    await tester.pump();
    await tab(tester);
    expect(after.hasPrimaryFocus, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('skips plain and disabled cells and visits both inputs in a cell',
      (tester) async {
    final nodes = List.generate(4, (i) => FocusNode(debugLabel: '$i'));
    addTearDown(() {
      for (final node in nodes) {
        node.dispose();
      }
    });
    final model = DaviModel<int>(rows: [
      0,
      1
    ], columns: [
      DaviColumn<int>(
          width: 180,
          cellWidget: (p) => Row(children: [
                for (int i = 0; i < 2; i++)
                  Expanded(
                      child: TextField(focusNode: nodes[p.rowIndex * 2 + i])),
              ])),
      DaviColumn<int>(cellValue: (p) => 'plain'),
      DaviColumn<int>(cellWidget: (p) => const TextField(enabled: false)),
    ]);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(width: 300, height: 200, child: Davi<int>(model)))));
    await tester.pumpAndSettle();
    nodes.first.requestFocus();
    await tester.pump();
    for (int i = 1; i < nodes.length; i++) {
      await tab(tester);
      expect(nodes[i].hasPrimaryFocus, isTrue);
    }
    await tab(tester, reverse: true);
    expect(nodes[2].hasPrimaryFocus, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
}
