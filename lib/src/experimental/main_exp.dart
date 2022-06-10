import 'dart:math';

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/experimental/table_callbacks.dart';
import 'package:easy_table/src/experimental/table_exp.dart';
import 'package:easy_table/src/experimental/table_layout_builder.dart';
import 'package:easy_table/src/experimental/table_layout_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/model.dart';
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
  Row({required this.string1, required this.string2, required this.int1});

  final String string1;
  final String string2;
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
            string1: random.nextInt(9999999).toRadixString(16),
            string2: random.nextInt(9999999).toRadixString(16),
            int1: random.nextInt(999)));
    _model = EasyTableModel(columns: [
      EasyTableColumn(name: 'string1', stringValue: (row) => row.string1),
      EasyTableColumn(
          name: 'string2',
          cellBuilder: (context, row, visibleRowIndex) => Text(row.string2)),
      EasyTableColumn(name: 'int1', intValue: (row) => row.int1)
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
                child: EasyTableExp(_model, columnsFit: true))));
  }
}
