import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/table_header_widget.dart';
import 'package:easy_table/src/model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TableHeaderApp());
}

class _Row {
  _Row(this.value1, this.value2, this.value3, this.value4);

  final String value1;
  final String value2;
  final String value3;
  final int value4;
}

class TableHeaderApp extends StatelessWidget {
  const TableHeaderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TableHeader QA',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _Row row = _Row('Cadu', 'Eduardo', 'Andrade', 10);
  final EasyTableColumn<_Row> column1 = EasyTableColumn(name: 'Column 1');
  final EasyTableColumn<_Row> column2 = EasyTableColumn(name: 'Column 2');
  final EasyTableColumn<_Row> column3 = EasyTableColumn(name: 'Column 3');
  final EasyTableColumn<_Row> column4 = EasyTableColumn(name: 'Column 4');
  late EasyTableModel<_Row> model = EasyTableModel(
      columns: [column1, column2, column3, column4], rows: [row]);

  final ScrollController horizontalScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    const ColumnFilter columnFilter = ColumnFilter.all;

    ColumnsMetrics columnsMetrics = ColumnsMetrics.resizable(
        model: model, columnDividerThickness: 1, filter: columnFilter);
    //TODO danger: columnsMetrics, columnsFit and TableHeaderWidget with different column filter.
    Widget widget = TableHeaderWidget(
        model: model,
        columnsMetrics: columnsMetrics,
        columnFilter: columnFilter,
        contentWidth: 500,
        columnsFit: false,
        horizontalScrollController: horizontalScrollController);

    return Scaffold(
        appBar: AppBar(
          title: const Text('TableHeader QA'),
        ),
        body: Center(
            child: Container(
                decoration: BoxDecoration(border: Border.all(width: 1)),
                child: ConstrainedBox(
                    child: widget,
                    constraints: const BoxConstraints.tightFor(
                        width: 500, height: 50)))));
  }

  void _setHoveredRowIndex(int? value) {}
}
