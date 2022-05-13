import 'dart:collection';

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/table_row_layout_delegate.dart';
import 'package:easy_table/src/internal/table_row_widget.dart';
import 'package:easy_table/src/model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TableRowApp());
}

class _Row {
  _Row(this.value1, this.value2, this.value3, this.value4);

  final String value1;
  final String value2;
  final String value3;
  final int value4;
}

class TableRowApp extends StatelessWidget {
  const TableRowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TableRow QA',
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
  final EasyTableColumn<_Row> column1 =
      EasyTableColumn(stringValue: (row) => row.value1);
  final EasyTableColumn<_Row> column2 =
      EasyTableColumn(stringValue: (row) => row.value2);
  final EasyTableColumn<_Row> column3 =
      EasyTableColumn(stringValue: (row) => row.value3);
  final EasyTableColumn<_Row> column4 =
      EasyTableColumn(intValue: (row) => row.value4);
  late EasyTableModel<_Row> model = EasyTableModel(
      columns: [column1, column2, column3, column4], rows: [row]);

  @override
  Widget build(BuildContext context) {
    const ColumnFilter columnFilter = ColumnFilter.all;
    UnmodifiableListView<EasyTableColumn<_Row>> columns =
        UnmodifiableListView([column1, column2, column3, column4]);
    ColumnsMetrics columnsMetrics = ColumnsMetrics.resizable(
        model: model, columnDividerThickness: 1, filter: columnFilter);
    //TODO danger: columnsMetrics and TableRowWidget with different column filter.
    TableRowLayoutDelegate delegate =
        TableRowLayoutDelegate(columnsMetrics: columnsMetrics);
    Widget widget = TableRowWidget<_Row>(
        model: model,
        delegate: delegate,
        columnsMetrics: columnsMetrics,
        visibleRowIndex: 0,
        columns: columns,
        setHoveredRowIndex: _setHoveredRowIndex,
        hoveredRowIndex: 0,
        contentHeight: 32,
        onRowTap: null,
        onRowSecondaryTap: null,
        onRowDoubleTap: null);

    return Scaffold(
        appBar: AppBar(
          title: const Text('TableRow QA'),
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
