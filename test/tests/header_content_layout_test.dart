import 'package:davi/davi.dart';
import 'package:davi/src/internal/header_content_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  const _Row(this.value);

  final String value;
}

void main() {
  const leading = Key('leading');
  const name = Key('name');
  const icon = Key('icon');
  const gap = Key('gap');
  const priority = Key('priority');

  Widget header(double width, {bool expandableName = true}) => MaterialApp(
        home: Center(
          child: SizedBox(
            width: width,
            height: 30,
            child: HeaderContentLayout(
              expandableName: expandableName,
              leading: const SizedBox(key: leading, width: 20),
              content: const SizedBox(key: name, width: 10),
              sortIcon: const SizedBox(key: icon, width: 12),
              priorityGap: const SizedBox(key: gap, width: 2),
              priority: const SizedBox(key: priority, width: 10),
            ),
          ),
        ),
      );

  testWidgets('hides accessories in priority order without overflow',
      (tester) async {
    await tester.pumpWidget(header(50));
    final RenderHeaderContentLayout layout =
        tester.renderObject(find.byType(HeaderContentLayout));
    expect(layout.getMaxIntrinsicWidth(double.infinity), 54);
    expect(tester.getSize(find.byKey(leading)).width, 20);
    expect(tester.getSize(find.byKey(icon)).width, 12);
    expect(tester.getSize(find.byKey(priority)).width, 10);

    await tester.pumpWidget(header(40));
    expect(tester.getSize(find.byKey(leading)).width, 20);
    expect(tester.getSize(find.byKey(icon)).width, 12);
    expect(tester.getSize(find.byKey(gap)).width, 0);
    expect(tester.getSize(find.byKey(priority)).width, 0);

    await tester.pumpWidget(header(25));
    expect(tester.getSize(find.byKey(leading)).width, 0);
    expect(tester.getSize(find.byKey(icon)).width, 12);

    await tester.pumpWidget(header(8));
    expect(tester.getSize(find.byKey(icon)).width, 0);
    expect(tester.getSize(find.byKey(name)).width, 8);
    expect(layout.getMaxIntrinsicWidth(double.infinity), 54);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nonexpanding name keeps its natural width', (tester) async {
    await tester.pumpWidget(header(80, expandableName: false));
    expect(tester.getSize(find.byKey(name)).width, 10);
    await tester.pumpWidget(header(48, expandableName: false));
    expect(tester.getSize(find.byKey(name)).width, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nonexpanding header still honors right alignment',
      (tester) async {
    final column = DaviColumn<_Row>(
      name: 'Name',
      width: 160,
      headerAlignment: Alignment.centerRight,
      resizable: false,
      sortable: false,
      cellValue: (params) => params.data.value,
    );
    final model = DaviModel<_Row>(
      rows: const [_Row('a')],
      columns: [column],
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 200,
          child: DaviTheme(
            data: const DaviThemeData(
              headerCell: HeaderCellThemeData(expandableName: false),
            ),
            child: Davi<_Row>(model),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.getTopRight(find.text('Name')).dx, greaterThan(125));
    expect(tester.takeException(), isNull);
  });

  testWidgets('auto size includes accessories hidden at the initial width',
      (tester) async {
    final column = DaviColumn<_Row>(
      name: 'Long header label',
      width: 20,
      initialAutoSize: true,
      leading: const SizedBox(width: 30),
      cellValue: (params) => params.data.value,
    );
    final model = DaviModel<_Row>(
      rows: const [_Row('a')],
      columns: [column],
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 300, height: 200, child: Davi<_Row>(model)),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // Includes the full name, leading widget, padding and reserved sort icon.
    expect(column.width, greaterThan(140));
  });

  testWidgets('narrow fitted sorted columns do not report overflow',
      (tester) async {
    final columns = [
      DaviColumn<_Row>(
        id: 1,
        name: 'First',
        leading: const SizedBox(width: 20),
        cellValue: (params) => params.data.value,
      ),
      DaviColumn<_Row>(
        id: 2,
        name: 'Second',
        cellValue: (params) => params.data.value,
      ),
    ];
    final model = DaviModel<_Row>(
      rows: const [_Row('a')],
      columns: columns,
      multiSortEnabled: true,
    );
    model.sort([DaviSort(1), DaviSort(2)]);
    expect(model.isMultiSorted, isTrue);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 40,
          height: 200,
          child:
              Davi<_Row>(model, columnWidthBehavior: ColumnWidthBehavior.fit),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final firstHeader = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .firstWhere((widget) => widget.properties.label == 'header 0');
    expect(firstHeader.properties.value, 'sorted ascending, priority 1');
  });
}
