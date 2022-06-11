import 'dart:math';

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/experimental/table_callbacks.dart';
import 'package:easy_table/src/experimental/table_exp.dart';
import 'package:easy_table/src/experimental/table_layout_builder.dart';
import 'package:easy_table/src/experimental/table_layout_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/model.dart';
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

class Row {
  Row(
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
  late final EasyTableModel<Row> _model;
  late final List<Row> rows;

  @override
  void initState() {
    Random random = Random();
    List<Row> rows = List<Row>.generate(
        100,
        (index) => Row(
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
        body: Padding(
            padding: const EdgeInsets.all(64),
            child: Container(
                decoration: BoxDecoration(border: Border.all()),
                child: EasyTableTheme(
                    data: EasyTableThemeData(
                        row: RowThemeData(
                            hoveredColor: (index) => Colors.blue[50])),
                    child: EasyTableExp(_model)))));
  }
}
