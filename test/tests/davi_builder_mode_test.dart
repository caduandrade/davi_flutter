import 'package:davi/davi.dart';
import 'package:davi/src/internal/text_cell_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

List<String> _cellTexts(WidgetTester tester) => tester
    .widgetList<TextCellPainter>(find.byType(TextCellPainter))
    .map((p) => p.text)
    .toList();

void main() {
  testWidgets('Davi.builder renders rows supplied directly, without a model',
      (WidgetTester tester) async {
    final DaviController<_Row> controller = DaviController<_Row>(columns: [
      DaviColumn<_Row>(name: 'Name', cellValue: (params) => params.data.name),
    ]);

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                height: 200,
                child: Davi<_Row>.builder(
                    controller: controller,
                    rows: [_Row('Alice'), _Row('Bob')])))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(_cellTexts(tester), ['Alice', 'Bob']);
  });

  testWidgets(
      'Davi.builder reflects new rows on rebuild without a new controller',
      (WidgetTester tester) async {
    final DaviController<_Row> controller = DaviController<_Row>(columns: [
      DaviColumn<_Row>(name: 'Name', cellValue: (params) => params.data.name),
    ]);

    Widget buildWithRows(List<_Row> rows) {
      return MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  height: 200,
                  child: Davi<_Row>.builder(
                      controller: controller, rows: rows))));
    }

    await tester.pumpWidget(buildWithRows([_Row('Alice')]));
    await tester.pumpAndSettle();
    expect(_cellTexts(tester), ['Alice']);

    await tester.pumpWidget(buildWithRows([_Row('Carol')]));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(_cellTexts(tester), ['Carol']);
  });

  testWidgets(
      'Davi.builder with a null onSort never changes row order and reports no sort',
      (WidgetTester tester) async {
    final DaviColumn<_Row> nameColumn = DaviColumn<_Row>(
        name: 'Name', cellValue: (params) => params.data.name);
    final DaviController<_Row> controller =
        DaviController<_Row>(columns: [nameColumn]);

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                height: 200,
                child: Davi<_Row>.builder(
                    controller: controller,
                    rows: [_Row('Bob'), _Row('Alice')])))));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(nameColumn.sortDirection, isNull);
    expect(_cellTexts(tester), ['Bob', 'Alice']);
  });

  testWidgets(
      'Davi.builder with onSort requests a sort and updates the visual sort state',
      (WidgetTester tester) async {
    final DaviColumn<_Row> nameColumn = DaviColumn<_Row>(
        name: 'Name', cellValue: (params) => params.data.name);
    final DaviController<_Row> controller =
        DaviController<_Row>(columns: [nameColumn]);
    List<DaviColumn<_Row>>? requestedSort;

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                height: 200,
                child: Davi<_Row>.builder(
                    controller: controller,
                    rows: [_Row('Bob'), _Row('Alice')],
                    onSort: (sortedColumns) =>
                        requestedSort = sortedColumns)))));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(requestedSort, isNotNull);
    expect(requestedSort, [nameColumn]);
    expect(nameColumn.sortDirection, DaviSortDirection.ascending);

    // The requested sort is only visual: rows stay exactly as given until
    // whoever owns the data rebuilds with a new (sorted) row list.
    expect(_cellTexts(tester), ['Bob', 'Alice']);
  });
}
