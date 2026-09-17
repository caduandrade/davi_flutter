import 'package:davi/davi.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

DaviModel<_Row> _buildModel({int columnCount = 10}) {
  return DaviModel<_Row>(
      rows: List.generate(30, (i) => _Row('row $i')),
      columns: List.generate(
          columnCount,
          (i) => DaviColumn<_Row>(
              name: 'Col $i',
              cellWidget: (params) => Text(params.data.name),
              width: 150)));
}

// Cell/header content is positioned via a manual paint-time transform (not
// real RenderObject offsets, no applyPaintTransform override), so
// WidgetTester.getCenter/getTopLeft/tap on that content don't reflect actual
// scroll/position. Interact using a raw point relative to the table's real
// (normally laid out) top-left, which goes through the table's own
// (correctly implemented) hit-testing, and verify scrolling via the public
// ScrollController the test itself supplies.
Offset _bodyPoint(WidgetTester tester) {
  final Offset topLeft = tester.getTopLeft(find.byType(Davi<_Row>));
  return topLeft + const Offset(100, 150);
}

void main() {
  testWidgets('mouse click-and-drag on the body scrolls horizontally',
      (WidgetTester tester) async {
    final DaviModel<_Row> model = _buildModel();
    final ScrollController horizontalController = ScrollController();
    addTearDown(horizontalController.dispose);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 300,
                height: 300,
                child: Davi<_Row>(model,
                    unpinnedHorizontalScrollController:
                        horizontalController)))));
    await tester.pumpAndSettle();
    expect(horizontalController.offset, 0);

    final TestGesture gesture = await tester.startGesture(
        _bodyPoint(tester),
        kind: PointerDeviceKind.mouse);
    await tester.pump(const Duration(milliseconds: 20));
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump(const Duration(milliseconds: 20));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(horizontalController.offset, closeTo(120, 0.5));
  });

  testWidgets('touch drag on the body does not scroll horizontally',
      (WidgetTester tester) async {
    final DaviModel<_Row> model = _buildModel();
    final ScrollController horizontalController = ScrollController();
    addTearDown(horizontalController.dispose);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 300,
                height: 300,
                child: Davi<_Row>(model,
                    unpinnedHorizontalScrollController:
                        horizontalController)))));
    await tester.pumpAndSettle();

    final TestGesture gesture = await tester.startGesture(
        _bodyPoint(tester),
        kind: PointerDeviceKind.touch);
    await tester.pump(const Duration(milliseconds: 20));
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump(const Duration(milliseconds: 20));
    await gesture.up();
    await tester.pumpAndSettle();

    // Touch drags must not trigger the mouse/trackpad-only scroll path.
    expect(horizontalController.offset, 0);
  });

  testWidgets('a plain click (no drag) still fires onRowTap',
      (WidgetTester tester) async {
    final DaviModel<_Row> model = _buildModel();
    _Row? tapped;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 300,
                height: 300,
                child: Davi<_Row>(model, onRowTap: (row) => tapped = row)))));
    await tester.pumpAndSettle();

    // onRowTap resolves the row from the current hover state, so a mouse
    // must "arrive" (hover) at the point before clicking, same as a real
    // mouse would.
    final Offset point = _bodyPoint(tester);
    final TestGesture gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: point);
    await tester.pump();
    await gesture.down(point);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tapped, isNotNull);
  });
}
