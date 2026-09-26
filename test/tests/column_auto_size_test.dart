import 'package:davi/davi.dart';
import 'package:davi/src/internal/table_content.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

const String _long = 'A really long value to be measured by auto size';

Widget _table(Widget davi, {double width = 600}) => MaterialApp(
    home: Scaffold(
        body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, height: 300, child: davi))));

DaviColumn<_Row> _nameColumn(
        {bool initialAutoSize = true,
        double? maxAutoSizeWidth,
        String name = 'Name',
        bool resizable = true}) =>
    DaviColumn<_Row>(
        name: name,
        initialAutoSize: initialAutoSize,
        maxAutoSizeWidth: maxAutoSizeWidth,
        resizable: resizable,
        cellValue: (params) => params.data.name);

void main() {
  group('initialAutoSize', () {
    testWidgets('widens a column to fit a long value',
        (WidgetTester tester) async {
      final DaviColumn<_Row> column = _nameColumn();
      final DaviModel<_Row> model =
          DaviModel(rows: [_Row('a'), _Row(_long)], columns: [column]);
      await tester.pumpWidget(_table(Davi<_Row>(model)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(column.width, greaterThan(200));
    });

    testWidgets('narrows a column with short values',
        (WidgetTester tester) async {
      final DaviColumn<_Row> column = _nameColumn(name: 'N');
      final DaviModel<_Row> model =
          DaviModel(rows: [_Row('a'), _Row('b')], columns: [column]);
      await tester.pumpWidget(_table(Davi<_Row>(model)));
      await tester.pumpAndSettle();
      expect(column.width, lessThan(100));
    });

    testWidgets('considers the header', (WidgetTester tester) async {
      final DaviColumn<_Row> column = _nameColumn(name: _long);
      final DaviModel<_Row> model =
          DaviModel(rows: [_Row('a')], columns: [column]);
      await tester.pumpWidget(_table(Davi<_Row>(model)));
      await tester.pumpAndSettle();
      expect(column.width, greaterThan(200));
    });

    testWidgets('is limited by maxAutoSizeWidth', (WidgetTester tester) async {
      final DaviColumn<_Row> column = _nameColumn(maxAutoSizeWidth: 150);
      final DaviModel<_Row> model =
          DaviModel(rows: [_Row(_long)], columns: [column]);
      await tester.pumpWidget(_table(Davi<_Row>(model)));
      await tester.pumpAndSettle();
      expect(column.width, 150);
    });

    testWidgets('waits for rows and happens only once',
        (WidgetTester tester) async {
      final DaviColumn<_Row> column = _nameColumn();
      final DaviModel<_Row> model = DaviModel(columns: [column]);
      await tester.pumpWidget(_table(Davi<_Row>(model)));
      await tester.pumpAndSettle();
      expect(column.width, 100);

      model.addRow(_Row('a'));
      await tester.pumpAndSettle();
      final double autoSized = column.width;
      expect(autoSized, lessThan(100));

      model.addRow(_Row(_long));
      await tester.pumpAndSettle();
      expect(column.width, autoSized);
    });

    testWidgets('is canceled by an explicit width',
        (WidgetTester tester) async {
      final DaviColumn<_Row> column = _nameColumn();
      final DaviModel<_Row> model = DaviModel(columns: [column]);
      await tester.pumpWidget(_table(Davi<_Row>(model)));
      await tester.pumpAndSettle();
      column.width = 120;
      model.addRow(_Row(_long));
      await tester.pumpAndSettle();
      expect(column.width, 120);
    });

    testWidgets('does nothing in fit mode', (WidgetTester tester) async {
      final DaviColumn<_Row> column = _nameColumn();
      final DaviModel<_Row> model =
          DaviModel(rows: [_Row(_long)], columns: [column]);
      await tester.pumpWidget(_table(
          Davi<_Row>(model, columnWidthBehavior: ColumnWidthBehavior.fit)));
      await tester.pumpAndSettle();
      expect(column.width, 100);
    });

    testWidgets('grow distributes the space remaining after it',
        (WidgetTester tester) async {
      final DaviColumn<_Row> autoSized = _nameColumn(name: 'N');
      final DaviColumn<_Row> growing = DaviColumn<_Row>(name: 'Grow', grow: 1);
      final DaviModel<_Row> model =
          DaviModel(rows: [_Row('a')], columns: [autoSized, growing]);
      await tester.pumpWidget(_table(Davi<_Row>(model)));
      await tester.pumpAndSettle();
      expect(autoSized.width, lessThan(100));
      // Without the deferral, grow would consider the initial 100.
      expect(autoSized.width + growing.width, greaterThan(560));
    });

    testWidgets('leaves the table painted', (WidgetTester tester) async {
      final DaviModel<_Row> model =
          DaviModel(rows: [_Row('a')], columns: [_nameColumn()]);
      await tester.pumpWidget(_table(Davi<_Row>(model)));
      await tester.pumpAndSettle();
      final TableContent content = tester.widget<TableContent>(
          find.byWidgetPredicate((widget) => widget is TableContent));
      expect(content.daviContext.autoSizer.hidePaint, isFalse);
    });
  });

  group('autoSizeColumns', () {
    testWidgets('model: auto sizes resizable columns with the visible rows',
        (WidgetTester tester) async {
      final DaviColumn<_Row> resizable = _nameColumn(initialAutoSize: false);
      final DaviColumn<_Row> fixed =
          _nameColumn(initialAutoSize: false, resizable: false);
      final DaviModel<_Row> model = DaviModel(
          rows: [_Row('a'), _Row(_long)], columns: [resizable, fixed]);
      await tester.pumpWidget(_table(Davi<_Row>(model)));
      await tester.pumpAndSettle();
      expect(resizable.width, 100);

      model.autoSizeColumns();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(resizable.width, greaterThan(200));
      expect(fixed.width, 100);
    });

    testWidgets('controller: works in builder mode',
        (WidgetTester tester) async {
      final DaviColumn<_Row> column = _nameColumn(initialAutoSize: false);
      final DaviController<_Row> controller = DaviController(columns: [column]);
      await tester.pumpWidget(_table(
          Davi<_Row>.builder(controller: controller, rows: [_Row(_long)])));
      await tester.pumpAndSettle();
      controller.autoSizeColumns();
      await tester.pumpAndSettle();
      expect(column.width, greaterThan(200));
    });

    testWidgets('builder mode: initial auto size waits for rows',
        (WidgetTester tester) async {
      final DaviColumn<_Row> column = _nameColumn();
      final DaviController<_Row> controller = DaviController(columns: [column]);
      await tester.pumpWidget(
          _table(Davi<_Row>.builder(controller: controller, rows: const [])));
      await tester.pumpAndSettle();
      expect(column.width, 100);
      await tester.pumpWidget(_table(
          Davi<_Row>.builder(controller: controller, rows: [_Row(_long)])));
      await tester.pumpAndSettle();
      expect(column.width, greaterThan(200));
    });
  });

  testWidgets('double click on the resize area auto sizes the column',
      (WidgetTester tester) async {
    final DaviColumn<_Row> column = _nameColumn(initialAutoSize: false);
    final DaviModel<_Row> model =
        DaviModel(rows: [_Row(_long)], columns: [column]);
    await tester.pumpWidget(_table(Davi<_Row>(model)));
    await tester.pumpAndSettle();

    final Finder resizeArea = find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.onDoubleTap != null);
    expect(resizeArea, findsOneWidget);
    await tester.tap(resizeArea, kind: PointerDeviceKind.mouse);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(resizeArea, kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    expect(column.width, greaterThan(200));
  });
}
