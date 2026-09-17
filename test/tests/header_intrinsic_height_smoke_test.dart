import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

Widget _buildTable({
  required List<DaviColumn<_Row>> columns,
  required DaviThemeData theme,
  double height = 300,
}) {
  final DaviModel<_Row> model = DaviModel<_Row>(
      rows: [_Row('a'), _Row('b'), _Row('c')], columns: columns);
  return MaterialApp(
      home: Scaffold(
          body: SizedBox(
              height: height,
              child: DaviTheme(
                  data: theme, child: Davi<_Row>(model)))));
}

void main() {
  testWidgets('default resizable columns render without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTable(columns: [
      DaviColumn<_Row>(name: 'Name', cellValue: (r) => r.data.name, resizable: true),
    ], theme: const DaviThemeData()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('taller header text style grows the header instead of clipping',
      (WidgetTester tester) async {
    const DaviThemeData theme = DaviThemeData(
        headerCell: HeaderCellThemeData(
            textStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)));
    await tester.pumpWidget(_buildTable(columns: [
      DaviColumn<_Row>(name: 'Name', cellValue: (r) => r.data.name, resizable: true),
    ], theme: theme));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final Size headerCellSize = tester.getSize(find.text('Name'));
    // A 40px font should force the header row to be noticeably taller than
    // the old fixed default (32).
    expect(headerCellSize.height, greaterThan(32));
  });

  testWidgets('non-resizable (fit) columns still render without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTable(columns: [
      DaviColumn<_Row>(name: 'Name', cellValue: (r) => r.data.name),
    ], theme: const DaviThemeData()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('headerBuilder replaces the default Text(name) content',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTable(columns: [
      DaviColumn<_Row>(
          name: 'Name',
          cellValue: (r) => r.data.name,
          resizable: true,
          headerBuilder: (params) =>
              Text('Custom: ${params.column.name}')),
    ], theme: const DaviThemeData()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Name'), findsNothing);
    expect(find.text('Custom: Name'), findsOneWidget);
  });

  testWidgets(
      'header theme text style is inherited by headerBuilder content without an explicit style',
      (WidgetTester tester) async {
    const DaviThemeData theme = DaviThemeData(
        headerCell: HeaderCellThemeData(
            textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
    await tester.pumpWidget(_buildTable(columns: [
      DaviColumn<_Row>(
          name: 'Name',
          cellValue: (r) => r.data.name,
          resizable: true,
          headerBuilder: (params) => const Text('Custom')),
    ], theme: theme));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final Text textWidget = tester.widget<Text>(find.text('Custom'));
    // The builder didn't set its own style, so it must inherit the
    // ambient DefaultTextStyle set up for the header row.
    expect(textWidget.style, isNull);
    final Size textSize = tester.getSize(find.text('Custom'));
    expect(textSize.height, greaterThan(30));
  });

  testWidgets(
      'header height measurement uses the real column width, not a zero-width probe',
      (WidgetTester tester) async {
    // A headerBuilder building a plain Text without overflow/maxLines: the
    // header must still size itself based on the real available width, not
    // some degenerate zero-width layout pass (which would force multi-line
    // wrapping and inflate the header height).
    await tester.pumpWidget(_buildTable(columns: [
      DaviColumn<_Row>(
          name: 'Name',
          width: 300,
          cellValue: (r) => r.data.name,
          resizable: true,
          headerBuilder: (params) =>
              Text(params.column.name ?? '', style: const TextStyle(fontSize: 29))),
    ], theme: const DaviThemeData()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final Size textSize = tester.getSize(find.text('Name'));
    // A single line at fontSize 29 is roughly 40-50px tall; a zero-width
    // probe bug would wrap "Name" into several lines and inflate this well
    // past 100px.
    expect(textSize.height, lessThan(60));
  });

  testWidgets('header with summary and both scrollbars renders without crashing',
      (WidgetTester tester) async {
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: List.generate(50, (i) => _Row('row $i')),
        columns: List.generate(
            10,
            (i) => DaviColumn<_Row>(
                name: 'Col $i',
                cellValue: (r) => r.data.name,
                width: 150,
                resizable: true)));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 400,
                height: 300,
                child: Davi<_Row>(model,
                    trailingWidget: const SizedBox(height: 20))))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
