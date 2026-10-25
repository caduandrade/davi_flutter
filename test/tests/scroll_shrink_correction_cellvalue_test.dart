import 'package:davi/davi.dart';
import 'package:davi/src/internal/text_cell_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

class _ThemeChanger extends StatefulWidget {
  const _ThemeChanger({super.key, required this.model, required this.controller});
  final DaviModel<_Row> model;
  final ScrollController controller;

  @override
  State<_ThemeChanger> createState() => _ThemeChangerState();
}

class _ThemeChangerState extends State<_ThemeChanger> {
  double _dividerThickness = 10;

  void toggleDividerThickness() {
    setState(() {
      _dividerThickness = _dividerThickness == 10 ? 1 : 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: SizedBox(
                height: 400,
                width: 600,
                child: DaviTheme(
                    data: DaviThemeData(
                        row: RowThemeData(
                            dividerThickness: _dividerThickness,
                            dividerColor: Colors.blue)),
                    child: Davi<_Row>(widget.model,
                        verticalScrollController: widget.controller)))));
  }
}

/// The max bottom-edge y among all currently rendered text cells
/// (`cellValue`-based columns render through [TextCellPainter], not a real
/// `Text` widget, so `find.text` can't locate them - this samples the raw
/// render tree instead, mirroring how demo.dart's columns are built).
double _maxRenderedBottom(WidgetTester tester) {
  double maxBottom = 0;
  for (final Element element
      in tester.elementList(find.byType(TextCellPainter))) {
    final RenderBox box = element.renderObject as RenderBox;
    if (!box.attached || !box.hasSize) continue;
    final Offset topLeft = box.localToGlobal(Offset.zero);
    final double bottom = topLeft.dy + box.size.height;
    if (bottom > maxBottom) {
      maxBottom = bottom;
    }
  }
  return maxBottom;
}

void main() {
  testWidgets(
      'demo.dart-like setup (cellValue columns, ~300 rows): scrolling to '
      'the end then shrinking total content height does not leave a blank '
      'gap at the bottom', (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: List.generate(298, (i) => _Row('row $i')),
        columns: [
          DaviColumn<_Row>(
              name: 'Name', width: 100, cellValue: (params) => params.data.name),
          DaviColumn<_Row>(
              name: 'Extra', width: 100, cellValue: (params) => 'x${params.rowIndex}'),
        ]);

    final GlobalKey<_ThemeChangerState> changerKey =
        GlobalKey<_ThemeChangerState>();
    await tester.pumpWidget(
        _ThemeChanger(model: model, controller: controller, key: changerKey));
    await tester.pumpAndSettle();

    // Scroll to the true end (divider thickness 10, matching demo's "on").
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(_maxRenderedBottom(tester), greaterThan(390));

    // Turn "custom divider thickness" back off (10 -> 1): content shrinks.
    changerKey.currentState!.toggleDividerThickness();
    await tester.pump();

    expect(tester.takeException(), isNull);
    // Content should still reach close to the bottom of the 400px viewport
    // (header eats a bit of it) - not stuck with a blank gap because
    // rendering never caught up to the shrink.
    expect(_maxRenderedBottom(tester), greaterThan(350));
  });
}
