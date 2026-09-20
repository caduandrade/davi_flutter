import 'package:davi/davi.dart';
import 'package:davi/src/internal/cell_widget_builder.dart';
import 'package:davi/src/internal/table_content.dart';
import 'package:davi/src/internal/text_cell_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.text);
  final String text;
}

// Short enough to wrap onto just a few lines at the narrow column width
// used below (not so long the row alone would dominate the viewport).
const String _longText = 'A sentence that wraps onto a few lines.';

/// Every currently rendered `TextCellPainter`'s vertical span, ordered top
/// to bottom (row order). `cellValue` paints through a raw `TextPainter`,
/// not a real `Text` widget, so `find.text` can't be used to count/locate
/// rendered rows - this samples the render tree directly.
List<double> _renderedTops(WidgetTester tester) {
  final List<double> tops = [];
  for (final Element element
      in tester.elementList(find.byType(TextCellPainter))) {
    final RenderBox box = element.renderObject as RenderBox;
    if (!box.attached || !box.hasSize) continue;
    tops.add(box.localToGlobal(Offset.zero).dy);
  }
  tops.sort();
  return tops;
}

class _ResizableHost extends StatefulWidget {
  const _ResizableHost({super.key, required this.model, required this.width});
  final DaviModel<_Row> model;
  final double width;

  @override
  State<_ResizableHost> createState() => _ResizableHostState();
}

class _ResizableHostState extends State<_ResizableHost> {
  late double _width = widget.width;

  void setWidth(double width) => setState(() => _width = width);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: _width,
                height: 400,
                child: Davi<_Row>(widget.model,
                    columnWidthBehavior: ColumnWidthBehavior.fit))));
  }
}

TableContent<_Row> _table(WidgetTester tester) =>
    tester.widget<TableContent<_Row>>(find.byType(TableContent<_Row>));

void _expectCompleteViewport(WidgetTester tester) {
  final table = _table(tester);
  final manager = table.daviContext.rowExtentManager;
  final cells = tester
      .widgetList<CustomSingleChildWidget>(find.byType(CustomSingleChildWidget))
      .map((cell) => cell.cellMapping)
      .toList();
  for (int row = 0;
      row < manager.rowsLength && manager.offsetOf(row) < table.maxHeight;
      row++) {
    expect(cells.where((cell) => cell.rowIndex == row).length,
        table.daviContext.model.columnsLength,
        reason: 'Missing cells in visible row $row');
  }
}

void main() {
  testWidgets(
      'widening the table (no scroll) re-measures wrapped rows and keeps '
      'the pool of rendered cells in sync once things settle - no cell '
      'stays missing', (WidgetTester tester) async {
    // Many rows so the pool doesn't already cover the whole data set -
    // matches the reported scenario (some cells popping in/out, not just a
    // height change on an already-fully-rendered table).
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: List.generate(50, (i) => _Row(_longText)),
        columns: [
          DaviColumn<_Row>(
              name: 'Text', width: 80, cellValue: (params) => params.data.text),
        ]);

    final GlobalKey<_ResizableHostState> hostKey =
        GlobalKey<_ResizableHostState>();
    await tester
        .pumpWidget(_ResizableHost(model: model, width: 200, key: hostKey));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final int narrowCellCount = _renderedTops(tester).length;
    final double narrowHeight =
        _table(tester).daviContext.rowExtentManager.heightOf(0);
    _expectCompleteViewport(tester);

    // Widen the table a lot - the column grows, row 0's text unwraps from
    // several lines down to one, shrinking that row a lot. This should not
    // leave the rendered-cell pool undersized/stale for rows further down,
    // after the measurement and viewport reconciliation have completed.
    hostKey.currentState!.setWidth(800);
    await tester.pumpAndSettle(const Duration(milliseconds: 16));
    expect(tester.takeException(), isNull);

    final List<double> topsAfterSettling = _renderedTops(tester);
    // No gaps: consecutive rendered rows must be contiguous (a missing cell
    // in the middle of the pool would show up as an unusually large jump
    // between consecutive tops, or fewer rendered cells than before even
    // though there's plenty of data and room to show more).
    expect(topsAfterSettling.length, greaterThan(narrowCellCount));
    expect(_table(tester).daviContext.rowExtentManager.heightOf(0),
        lessThan(narrowHeight));
    _expectCompleteViewport(tester);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'a live resize with wrapping rows converges without missing cells',
      (WidgetTester tester) async {
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: List.generate(50, (i) => _Row(i.isEven ? _longText : 'row $i')),
        columns: [
          DaviColumn<_Row>(
              name: 'Text', width: 80, cellValue: (params) => params.data.text),
        ]);

    final GlobalKey<_ResizableHostState> hostKey =
        GlobalKey<_ResizableHostState>();
    await tester
        .pumpWidget(_ResizableHost(model: model, width: 200, key: hostKey));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Simulate a live drag, then reverse it to exercise both pool growth
    // and shrinkage with the same recycled slots.
    for (int i = 0; i < 30; i++) {
      hostKey.currentState!.setWidth(200 + i * 20);
      await tester.pump(const Duration(milliseconds: 10));
    }
    for (int i = 29; i >= 0; i--) {
      hostKey.currentState!.setWidth(200 + i * 20);
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(tester.takeException(), isNull);

    final frames = await tester.pumpAndSettle(const Duration(milliseconds: 16));
    expect(frames, lessThan(12));
    expect(tester.takeException(), isNull);
    expect(_renderedTops(tester), isNotEmpty);
    _expectCompleteViewport(tester);
    final manager = _table(tester).daviContext.rowExtentManager;
    final generation = manager.generation;
    await tester.pump(const Duration(milliseconds: 300));
    expect(manager.generation, generation);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
