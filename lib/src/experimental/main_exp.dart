import 'dart:math';

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/experimental/table_exp.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/theme/header_cell_theme_data.dart';
import 'package:easy_table/src/theme/row_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Experimental',
      home: HomePage(),
    );
  }
}

class Value {
  Value(
      {required this.index,
      required this.string1,
      required this.string2,
      required this.string3,
      required this.string4,
      required this.string5,
      required this.string6,
      required this.string7,
      required this.int1});

  final int index;
  final String string1;
  final String string2;
  final String string3;
  final String string4;
  final String string5;
  final String string6;
  final String string7;
  final int int1;
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final EasyTableModel<Value> _model;
  late final List<Value> rows;

  Color _columnDividerColor = EasyTableThemeDataDefaults.columnDividerColor;
  double _columnDividerThickness =
      EasyTableThemeDataDefaults.columnDividerThickness;
  double _headerCellHeight = HeaderCellThemeDataDefaults.height;

  @override
  void initState() {
    Random random = Random();
    List<Value> rows = List<Value>.generate(
        100,
        (index) => Value(
            index: index,
            string1: random.nextInt(9999999).toRadixString(16),
            string2: random.nextInt(9999999).toRadixString(16),
            string3: random.nextInt(9999999).toRadixString(16),
            string4: random.nextInt(9999999).toRadixString(16),
            string5: random.nextInt(9999999).toRadixString(16),
            string6: random.nextInt(9999999).toRadixString(16),
            string7: random.nextInt(9999999).toRadixString(16),
            int1: random.nextInt(999)));
    _model = EasyTableModel(columns: [
      EasyTableColumn(
          name: 'index',
          cellBuilder: (context, row, visibleRowIndex) =>
              Text(row.index.toString())),
      EasyTableColumn(
          name: 'string1',
          cellBuilder: (context, row, visibleRowIndex) => Text(row.string1)),
      EasyTableColumn(
          name: 'string2',
          cellBuilder: (context, row, visibleRowIndex) => Text(row.string2)),
      EasyTableColumn(
          name: 'string3',
          cellBuilder: (context, row, visibleRowIndex) => Text(row.string3)),
      EasyTableColumn(
          name: 'string4',
          cellBuilder: (context, row, visibleRowIndex) => Text(row.string4)),
      EasyTableColumn(
          name: 'string5',
          cellBuilder: (context, row, visibleRowIndex) => Text(row.string5)),
      EasyTableColumn(
          name: 'string6',
          cellBuilder: (context, row, visibleRowIndex) => Text(row.string6)),
      EasyTableColumn(
          name: 'string7',
          cellBuilder: (context, row, visibleRowIndex) => Text(row.string7)),
      EasyTableColumn(
          name: 'int1',
          cellBuilder: (context, row, visibleRowIndex) =>
              Text(row.int1.toString()))
    ], rows: rows);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Experimental'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(spacing: 8, children: [
                  ElevatedButton(
                      onPressed: _changeColumnDividerThickness,
                      child: const Text('columnDividerThickness')),
                  ElevatedButton(
                      onPressed: _changeColumnDividerColor,
                      child: const Text('columnDividerColor')),
                  ElevatedButton(
                      onPressed: _changeHeaderCellHeight,
                      child: const Text('headerCellHeight'))
                ])),
            Expanded(child: _tableArea())
          ],
        ));
  }

  Widget _tableArea() {
    return Padding(
        padding: const EdgeInsets.all(64),
        child: Container(
            decoration: BoxDecoration(border: Border.all()),
            child: EasyTableTheme(
                data: EasyTableThemeData(
                    columnDividerThickness: _columnDividerThickness,
                    columnDividerColor: _columnDividerColor,
                    headerCell: HeaderCellThemeData(height: _headerCellHeight),
                    row:
                        RowThemeData(hoveredColor: (index) => Colors.blue[50])),
                child: EasyTableExp(_model))));
  }

  void _changeColumnDividerThickness() {
    setState(() => _columnDividerThickness = _columnDividerThickness ==
            EasyTableThemeDataDefaults.columnDividerThickness
        ? 3
        : EasyTableThemeDataDefaults.columnDividerThickness);
  }

  void _changeColumnDividerColor() {
    setState(() => _columnDividerColor =
        _columnDividerColor == EasyTableThemeDataDefaults.columnDividerColor
            ? Colors.red
            : EasyTableThemeDataDefaults.columnDividerColor);
  }

  void _changeHeaderCellHeight() {
    setState(() => _headerCellHeight =
        _headerCellHeight == HeaderCellThemeDataDefaults.height
            ? 40
            : HeaderCellThemeDataDefaults.height);
  }
}
