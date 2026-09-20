import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.text);
  final String text;
}

void main() {
  testWidgets(
      'continuously scrolling through many never-before-seen rows whose '
      'real height differs a lot from the seed estimate does not enter a '
      'rebuild feedback loop', (WidgetTester tester) async {
    // Estimate defaults to 32 - alternate between a much shorter row and a
    // much taller (wrapped) one so every newly-revealed batch corrects by a
    // lot, maximizing the chance of triggering unnecessary resyncs if the
    // fix were too broad.
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: List.generate(
            400,
            (i) => _Row(i.isEven
                ? 'x'
                : 'A somewhat long line of text that wraps onto a few '
                    'lines at this narrow column width.')),
        columns: [
          DaviColumn<_Row>(
              name: 'Text', width: 90, cellValue: (params) => params.data.text),
        ]);

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SizedBox(height: 400, child: Davi<_Row>(model)))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final Finder tableFinder = find.byType(Davi<_Row>);

    // Drag-scroll down through a large chunk of never-before-seen rows,
    // pumping a bounded, fixed number of frames per step (not
    // pumpAndSettle, which would hide a non-terminating rebuild loop by
    // timing out instead of failing fast).
    for (int i = 0; i < 20; i++) {
      await tester.drag(tableFinder, const Offset(0, -300));
      // A real (non-looping) settle takes only a handful of frames even
      // when a row-height correction triggers one extra resync pass.
      for (int f = 0; f < 6; f++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.takeException(), isNull);
    }

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
