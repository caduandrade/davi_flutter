import 'package:davi/davi.dart';
import 'package:davi/src/internal/cell_widget_builder.dart';
import 'package:davi/src/internal/table_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../example/demo/demo.dart';

final _tableFinder = find.byWidgetPredicate((widget) => widget is TableContent);

void _expectCompleteRows(WidgetTester tester) {
  final table = tester.widget<TableContent>(_tableFinder);
  final manager = table.daviContext.rowExtentManager;
  final controller = table.daviContext.scrollControllers.vertical;
  final offset = controller.hasClients ? controller.offset : 0.0;
  final cells = tester
      .renderObjectList<RenderCustomSingleChild>(
          find.byType(CustomSingleChildWidget))
      .toList();
  for (int row = manager.indexAtOffset(offset);
      row < table.daviContext.dataSource.rowsLength &&
          manager.offsetOf(row) < offset + table.maxHeight;
      row++) {
    final rowCells = cells.where((cell) => cell.cellMapping.rowIndex == row);
    expect(rowCells.length, table.daviContext.dataSource.columnsLength,
        reason: 'Missing cells in visible row $row');
    for (final cell in rowCells) {
      expect(cell.child!.size.height, closeTo(manager.heightOf(row), 0.001),
          reason: 'Stale height in row $row, '
              'column ${cell.cellMapping.columnIndex}');
    }
  }
}

Future<void> _settle(WidgetTester tester) async {
  // Include the old debounce delay so a timer-driven loop cannot hide
  // behind pumpAndSettle returning before the timer fires.
  for (int i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
  expect(tester.takeException(), isNull);
  _expectCompleteRows(tester);
  final table = tester.widget<TableContent>(_tableFinder);
  final generation = table.daviContext.rowExtentManager.generation;
  await tester.pump(const Duration(milliseconds: 300));
  expect(table.daviContext.rowExtentManager.generation, generation,
      reason: 'Row heights must stop changing after resize');
  expect(tester.binding.hasScheduledFrame, isFalse);
}

void main() {
  testWidgets('real demo keeps complete, stable rows during window resize',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1300, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const DemoApp());
    await _settle(tester);

    for (final size in [
      const Size(1000, 400),
      const Size(750, 600),
      const Size(1300, 350),
      const Size(1000, 700),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await _settle(tester);
    }

    await tester.ensureVisible(find.text('Columns fit'));
    await tester.tap(find.text('Columns fit'));
    await _settle(tester);
    expect(
        tester
            .widget<TableContent>(_tableFinder)
            .daviContext
            .columnWidthBehavior,
        ColumnWidthBehavior.fit);
    for (int i = 0; i < 30; i++) {
      await tester.binding.setSurfaceSize(Size(1300 - i * 16, 700 - i * 8));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await _settle(tester);

    // A small data set exercises the threshold where the vertical
    // scrollbar appears/disappears while the columns rewrap.
    await tester.ensureVisible(find.text('Few rows'));
    await tester.tap(find.text('Few rows'));
    await _settle(tester);
    expect(
        tester.widget<TableContent>(_tableFinder).daviContext.dataSource.rowsLength,
        5);
    final scrollbarStates = <bool>{};
    for (final size in [
      const Size(1400, 900),
      const Size(850, 400),
      const Size(1400, 900),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await _settle(tester);
      scrollbarStates.add(tester
          .widget<TableContent>(_tableFinder)
          .layoutSettings
          .hasVerticalScrollbar);
    }
    expect(scrollbarStates, containsAll([false, true]));
  });
}
