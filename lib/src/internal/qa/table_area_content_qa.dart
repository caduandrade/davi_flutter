import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/table_area_content_widget.dart';
import 'package:easy_table/src/model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ContentApp());
}

class _Row {
  _Row(this.value1, this.value2, this.value3, this.value4);

  final String value1;
  final String value2;
  final int value3;
  final int value4;
}

class ContentApp extends StatelessWidget {
  const ContentApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TableAreaContent QA',
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
  final EasyTableColumn<_Row> column1 =
      EasyTableColumn(stringValue: (row) => row.value1);
  final EasyTableColumn<_Row> column2 =
      EasyTableColumn(stringValue: (row) => row.value2);
  final EasyTableColumn<_Row> column3 =
      EasyTableColumn(intValue: (row) => row.value3);
  final EasyTableColumn<_Row> column4 =
      EasyTableColumn(intValue: (row) => row.value4);
  late EasyTableModel<_Row> model;

  final ScrollController verticalScrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();

  @override
  void initState() {
    List<_Row> rows = [];
    for (int i = 0; i < 50; i++) {
      rows.add(_Row('r${i}c1', 'r${i}c2', i, i * 2));
    }
    model = EasyTableModel(
        columns: [column1, column2, column3, column4], rows: rows);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScrollBehavior scrollBehavior =
        ScrollConfiguration.of(context).copyWith(scrollbars: false);
    const ColumnFilter columnFilter = ColumnFilter.all;

    ColumnsMetrics columnsMetrics = ColumnsMetrics.resizable(
        model: model, columnDividerThickness: 1, filter: columnFilter);
    //TODO danger: columnsMetrics, columnsFit and ContentWidget can be different column filter.
    Widget widget = TableAreaContentWidget<_Row>(
        model: model,
        verticalScrollController: verticalScrollController,
        horizontalScrollController: horizontalScrollController,
        columnsMetrics: columnsMetrics,
        columnFilter: columnFilter,
        columnsFit: false,
        rowHeight: 30,
        cellContentHeight: 32,
        contentWidth: 500,
        setHoveredRowIndex: _setHoveredRowIndex,
        hoveredRowIndex: 0,
        onRowTap: null,
        onRowSecondaryTap: null,
        onRowDoubleTap: null,
        scrollBehavior: scrollBehavior);

    return Scaffold(
        appBar: AppBar(
          title: const Text('TableAreaContent QA'),
        ),
        body: widget);
  }

  void _setHoveredRowIndex(int? value) {}
}
