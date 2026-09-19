import 'package:davi/davi.dart';
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
  double _dividerThickness = 50;

  void shrinkDividerThickness() {
    setState(() => _dividerThickness = 1);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: SizedBox(
                height: 300,
                child: DaviTheme(
                    data: DaviThemeData(
                        row: RowThemeData(
                            dividerThickness: _dividerThickness)),
                    child: Davi<_Row>(widget.model,
                        verticalScrollController: widget.controller)))));
  }
}

void main() {
  testWidgets(
      'scrolling to the end, then shrinking total content height, leaves '
      'the scroll position in range - not stuck past the new end with a '
      'blank gap until an active scroll gesture corrects it',
      (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: List.generate(20, (i) => _Row('row $i')),
        columns: [
          // cellWidget (a real Text widget) rather than cellValue (which
          // paints through a raw TextPainter, not a Text widget) so
          // find.text can actually locate rendered rows in this test.
          DaviColumn<_Row>(
              name: 'Name',
              cellWidget: (params) => Text(params.data.name)),
        ]);

    final GlobalKey<_ThemeChangerState> changerKey =
        GlobalKey<_ThemeChangerState>();
    await tester.pumpWidget(
        _ThemeChanger(model: model, controller: controller, key: changerKey));
    await tester.pumpAndSettle();

    // Scroll all the way to the true end (large divider thickness).
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pumpAndSettle();
    final double pixelsAtEnd = controller.position.pixels;
    expect(pixelsAtEnd, greaterThan(0));

    // Shrink the divider thickness - total content height drops a lot.
    // A single pump (the very next rendered frame, ~16ms in a live app -
    // imperceptible) is the bar: if it's still broken after just this one
    // frame, nothing will fix it without an explicit user scroll gesture
    // (matching the reported bug, which does not self-heal by itself).
    changerKey.currentState!.shrinkDividerThickness();
    await tester.pump();

    expect(tester.takeException(), isNull);
    // The scroll position value itself must not be left past the new valid
    // end...
    expect(controller.position.pixels,
        lessThanOrEqualTo(controller.position.maxScrollExtent + 0.5));

    // ...AND the actual rendered rows must reflect it: the last row should
    // be visible within the 300px viewport, not scrolled off past a stale,
    // too-large offset (a blank gap) because ViewportState/row painting
    // never got re-driven by a notification for the correction.
    final Finder lastRow = find.text('row 19');
    expect(lastRow, findsOneWidget);
    final double lastRowTop = tester.getTopLeft(lastRow).dy;
    final double lastRowBottom = tester.getBottomLeft(lastRow).dy;
    expect(lastRowBottom, greaterThan(0));
    expect(lastRowTop, lessThan(300));
  });
}
