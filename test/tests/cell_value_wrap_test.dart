import 'package:davi/davi.dart';
import 'package:davi/src/internal/text_cell_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.text);
  final String text;
}

const String _longText =
    'This is a long sentence that will not fit on a single line at all '
    'given a narrow column width, so it must wrap onto several lines.';

/// The rendered heights of every `TextCellPainter` currently on screen,
/// ordered top to bottom (row order). `cellValue` paints through a raw
/// `TextPainter`, not a real `Text` widget, so `find.text` can't locate it -
/// this samples the render tree directly, mirroring
/// scroll_shrink_correction_cellvalue_test.dart.
List<double> _renderedCellHeights(WidgetTester tester) {
  final List<MapEntry<double, double>> entries = [];
  for (final Element element in tester.elementList(find.byType(TextCellPainter))) {
    final RenderBox box = element.renderObject as RenderBox;
    if (!box.attached || !box.hasSize) continue;
    entries.add(MapEntry(box.localToGlobal(Offset.zero).dy, box.size.height));
  }
  entries.sort((a, b) => a.key.compareTo(b.key));
  return entries.map((e) => e.value).toList();
}

Widget _buildTable(DaviModel<_Row> model) => MaterialApp(
    home:
        Scaffold(body: SizedBox(height: 400, child: Davi<_Row>(model))));

void main() {
  testWidgets(
      'a cellValue row grows to fit wrapped text instead of clipping it '
      '(default cellOverflow: null)', (WidgetTester tester) async {
    final DaviModel<_Row> model = DaviModel<_Row>(rows: [
      _Row(_longText),
      _Row('short'),
    ], columns: [
      DaviColumn<_Row>(
          name: 'Text', width: 80, cellValue: (params) => params.data.text),
    ]);

    await tester.pumpWidget(_buildTable(model));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final List<double> heights = _renderedCellHeights(tester);
    expect(heights.length, 2);
    final double longRowHeight = heights[0];
    final double shortRowHeight = heights[1];

    // Wrapped onto several lines, the long-text row must be noticeably
    // taller than the single-line short-text row.
    expect(longRowHeight, greaterThan(shortRowHeight * 2));
  });

  testWidgets(
      'cellOverflow keeps a cellValue row single-line instead of wrapping',
      (WidgetTester tester) async {
    final DaviModel<_Row> model = DaviModel<_Row>(rows: [
      _Row(_longText),
      _Row('short'),
    ], columns: [
      DaviColumn<_Row>(
          name: 'Text',
          width: 80,
          cellOverflow: TextOverflow.ellipsis,
          cellValue: (params) => params.data.text),
    ]);

    await tester.pumpWidget(_buildTable(model));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final List<double> heights = _renderedCellHeights(tester);
    expect(heights.length, 2);
    final double longRowHeight = heights[0];
    final double shortRowHeight = heights[1];

    // With cellOverflow set, both rows stay single-line and roughly the
    // same height instead of the long one wrapping and growing.
    expect(longRowHeight, closeTo(shortRowHeight, 0.5));
  });
}
