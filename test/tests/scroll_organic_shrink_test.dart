import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

void main() {
  testWidgets(
      'jumping straight to the (estimate-inflated) max scroll extent before '
      'most rows have ever been measured settles on the true end once their '
      'real (much shorter) height is measured - no theme change involved, '
      'purely organic measurement-driven shrink', (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);

    // Every row's real content is far shorter (10px) than the default seed
    // estimate (32px) - most rows haven't been measured yet right after the
    // very first frame, so maxScrollExtent starts out heavily inflated.
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: List.generate(200, (i) => _Row('row $i')),
        columns: [
          DaviColumn<_Row>(
              name: 'Name',
              cellWidget: (params) =>
                  SizedBox(height: 10, child: Text(params.data.name))),
        ]);

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                height: 300,
                child: Davi<_Row>(model,
                    verticalScrollController: controller)))));
    await tester.pump();

    // Jump straight to whatever the CURRENT (likely still estimate-inflated)
    // max is, before letting things settle - mirrors a fast wheel-fling to
    // "the end" before most rows have ever been visible/measured.
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(controller.position.pixels,
        lessThanOrEqualTo(controller.position.maxScrollExtent + 0.5));

    final Finder lastRow = find.text('row 199');
    expect(lastRow, findsOneWidget);
    final double lastRowBottom = tester.getBottomLeft(lastRow).dy;
    final double lastRowTop = tester.getTopLeft(lastRow).dy;
    expect(lastRowBottom, greaterThan(0));
    expect(lastRowTop, lessThan(300));
  });
}
