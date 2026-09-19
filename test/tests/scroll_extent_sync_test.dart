import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

void main() {
  testWidgets(
      'ScrollPosition.maxScrollExtent tracks real measured row heights, not '
      'just the seed estimate (regression: mouse-wheel/keyboard scroll '
      'clamp to ScrollPosition, which must stay in sync with '
      'RowExtentManager as rows are measured)', (WidgetTester tester) async {
    final ScrollController verticalController = ScrollController();
    addTearDown(verticalController.dispose);

    // Every row is much taller (120) than the default seed estimate (32),
    // so the true total height is far larger than what the FIRST frame's
    // estimate-only totalHeight would suggest.
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: List.generate(10, (i) => _Row('row $i')),
        columns: [
          DaviColumn<_Row>(
              name: 'Name',
              cellWidget: (params) =>
                  SizedBox(height: 120, child: Text(params.data.name))),
        ]);

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                height: 300,
                child: Davi<_Row>(model,
                    verticalScrollController: verticalController)))));
    await tester.pumpAndSettle();

    expect(verticalController.hasClients, isTrue);
    // 10 rows * 120 + 9 dividers(1px) = 1209, minus the trailing divider not
    // counted in the "content height not counting the last one" convention:
    // exact pixel math isn't the point here - the point is it must be far
    // larger than the pre-measurement estimate-based total would have been
    // (10 * 32 = 320), proving the real (not estimated) heights won round.
    final double maxScrollExtent = verticalController.position.maxScrollExtent;
    expect(maxScrollExtent, greaterThan(800));

    // Scrolling all the way down via the ScrollController (equivalent to
    // what mouse-wheel/keyboard scrolling clamps to) must actually reach
    // that real end, and the last row must become visible/measured.
    verticalController.jumpTo(verticalController.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(find.text('row 9'), findsOneWidget);
  });
}
