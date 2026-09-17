import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

void main() {
  testWidgets(
      'scrolling within and across row boundaries keeps correct cell content',
      (WidgetTester tester) async {
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: List.generate(200, (i) => _Row('row $i')),
        columns: [
          DaviColumn<_Row>(
              name: 'Name', cellWidget: (params) => Text(params.data.name)),
        ]);

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 300, height: 300, child: Davi<_Row>(model)))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('row 0'), findsOneWidget);

    final ScrollableState scrollable =
        tester.state(find.byType(Scrollable).first);
    final ScrollController controller =
        scrollable.widget.controller as ScrollController;

    // Small, sub-row-height delta: should not break anything and content
    // must remain consistent (this exercises the fast/skip path).
    controller.jumpTo(controller.offset + 3);
    await tester.pump();
    expect(tester.takeException(), isNull);

    // Big delta crossing many row boundaries: content must update.
    controller.jumpTo(2000);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('row 0'), findsNothing);

    // Scroll back to the top: original content must reappear correctly.
    controller.jumpTo(0);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('row 0'), findsOneWidget);
  });
}
