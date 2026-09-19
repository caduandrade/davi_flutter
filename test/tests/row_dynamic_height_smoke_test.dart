import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

Widget _buildTable({
  required List<_Row> rows,
  required List<DaviColumn<_Row>> columns,
  DaviThemeData theme = const DaviThemeData(),
  double height = 400,
}) {
  final DaviModel<_Row> model = DaviModel<_Row>(rows: rows, columns: columns);
  return MaterialApp(
      home: Scaffold(
          body: SizedBox(
              height: height,
              child: DaviTheme(data: theme, child: Davi<_Row>(model)))));
}

void main() {
  testWidgets('renders without crashing with plain text cells',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTable(
        rows: [_Row('a'), _Row('b'), _Row('c')],
        columns: [
          DaviColumn<_Row>(
              name: 'Name', cellValue: (params) => params.data.name),
        ]));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a row grows to fit a tall cellWidget instead of clipping it',
      (WidgetTester tester) async {
    const Key tallKey = Key('tall-cell');
    await tester.pumpWidget(_buildTable(
        rows: [_Row('a'), _Row('b'), _Row('c')],
        columns: [
          DaviColumn<_Row>(
              name: 'Content',
              cellWidget: (params) => params.rowIndex == 1
                  ? SizedBox(
                      key: tallKey,
                      height: 150,
                      child: Text(params.data.name))
                  : Text(params.data.name)),
        ]));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // If the row had NOT grown to fit it, RenderCustomSingleChild would
    // have handed the SizedBox a tight, smaller height and it would have
    // been forced to that smaller size instead of reporting 150.
    final Size tallCellSize = tester.getSize(find.byKey(tallKey));
    expect(tallCellSize.height, 150);
  });

  testWidgets('a short row stays close to the seed estimated height',
      (WidgetTester tester) async {
    const Key tallKey = Key('tall-cell');
    const Key shortKey = Key('short-0');
    await tester.pumpWidget(_buildTable(
        rows: [_Row('a'), _Row('b'), _Row('c')],
        columns: [
          DaviColumn<_Row>(
              name: 'Content',
              cellWidget: (params) {
                if (params.rowIndex == 1) {
                  return SizedBox(
                      key: tallKey, height: 150, child: const SizedBox());
                }
                return SizedBox(
                    key: ValueKey('short-${params.rowIndex}'),
                    child: Text(params.data.name));
              }),
        ]));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final double tallRowTop = tester.getTopLeft(find.byKey(tallKey)).dy;
    final double tallRowBottom = tester.getBottomLeft(find.byKey(tallKey)).dy;
    final double shortRowTop = tester.getTopLeft(find.byKey(shortKey)).dy;
    final double shortRowBottom =
        tester.getBottomLeft(find.byKey(shortKey)).dy;

    // The short row (row 0) must be much shorter than the tall row (row 1).
    expect(tallRowBottom - tallRowTop, 150);
    expect(shortRowBottom - shortRowTop, lessThan(60));
  });

  testWidgets('sorting after measuring a tall row does not crash',
      (WidgetTester tester) async {
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: [_Row('a'), _Row('b'), _Row('c')],
        columns: [
          DaviColumn<_Row>(
              name: 'Name',
              dataComparator: (a, b, rowA, rowB) =>
                  rowA.name.compareTo(rowB.name),
              cellWidget: (params) => params.rowIndex == 1
                  ? const SizedBox(height: 150)
                  : Text(params.data.name)),
        ]);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SizedBox(height: 400, child: Davi<_Row>(model)))));
    await tester.pumpAndSettle();

    model.sort([DaviSort(model.columnAt(0).id, DaviSortDirection.descending)]);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
