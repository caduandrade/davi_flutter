import 'package:davi/davi.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

void main() {
  testWidgets(
      'the hovered row follows the mouse position after a scroll, instead '
      'of staying pinned to whichever row was under the mouse before the '
      'scroll (Flutter does not fire a new PointerHoverEvent just because '
      'content moved under a stationary mouse)', (WidgetTester tester) async {
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: List.generate(30, (i) => _Row('row $i')),
        columns: [
          DaviColumn<_Row>(
              name: 'Name',
              width: 150,
              cellWidget: (params) => Text(params.data.name)),
        ]);
    final ScrollController verticalController = ScrollController();
    addTearDown(verticalController.dispose);

    _Row? tapped;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 300,
                height: 300,
                child: Davi<_Row>(model,
                    verticalScrollController: verticalController,
                    onRowTap: (row) => tapped = row)))));
    await tester.pumpAndSettle();

    final Offset topLeft = tester.getTopLeft(find.byType(Davi<_Row>));
    final Offset hoverPoint = topLeft + const Offset(60, 120);

    final TestGesture gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: hoverPoint);
    await tester.pump();

    // onRowTap resolves the row from the current hover state (set by the
    // mouse "arriving" above), same as a real mouse click.
    await gesture.down(hoverPoint);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final _Row? tappedBeforeScroll = tapped;
    expect(tappedBeforeScroll, isNotNull);
    tapped = null;

    // Scroll all the way to the end WITHOUT moving the mouse - the point on
    // screen under the cursor is now a much later row.
    verticalController.jumpTo(verticalController.position.maxScrollExtent);
    await tester.pump();

    // Click again at the exact same screen point, mouse never having moved.
    await gesture.down(hoverPoint);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final _Row? tappedAfterScroll = tapped;
    expect(tappedAfterScroll, isNotNull);

    int rowIndex(_Row row) => int.parse(row.name.split(' ')[1]);

    // Scrolled to the very end: the row now under the cursor must be a much
    // later row than before - not still the early row that was there prior
    // to the scroll (the bug: hover stayed pinned to the old row index).
    expect(rowIndex(tappedAfterScroll!), greaterThan(rowIndex(tappedBeforeScroll!) + 15));
  });
}
