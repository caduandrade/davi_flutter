import 'package:davi/davi.dart';
import 'package:davi/src/internal/text_cell_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

void main() {
  testWidgets(
      'default theme does not leave cell text with a null/white color',
      (WidgetTester tester) async {
    final DaviModel<_Row> model = DaviModel<_Row>(rows: [
      _Row('Alice')
    ], columns: [
      DaviColumn<_Row>(name: 'Name', cellValue: (params) => params.data.name),
    ]);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(height: 200, child: Davi<_Row>(model)))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final TextCellPainter painter =
        tester.widget<TextCellPainter>(find.byType(TextCellPainter));
    expect(painter.textStyle, isNotNull);
    expect(painter.textStyle!.color, isNotNull);
    expect(painter.textStyle!.color, isNot(Colors.white));
  });

  testWidgets('an explicit cellTextStyle color is preserved as-is',
      (WidgetTester tester) async {
    final DaviModel<_Row> model = DaviModel<_Row>(rows: [
      _Row('Alice')
    ], columns: [
      DaviColumn<_Row>(
          name: 'Name',
          cellValue: (params) => params.data.name,
          cellTextStyle: (params) => const TextStyle(color: Colors.red)),
    ]);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(height: 200, child: Davi<_Row>(model)))));
    await tester.pumpAndSettle();

    final TextCellPainter painter =
        tester.widget<TextCellPainter>(find.byType(TextCellPainter));
    expect(painter.textStyle!.color, Colors.red);
  });
}
