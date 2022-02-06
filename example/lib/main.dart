import 'dart:math' as math;
import 'package:easy_table/easy_table.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'EasyTable example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class Row {
  Row(this.name, this.value);

  final String name;
  final String value;
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    List<Row> rows = [];
    math.Random random = math.Random();
    for (int i = 1; i < 500; i++) {
      int value = random.nextInt(90000);
      rows.add(Row('Name $i', value.toString()));
    }

    EasyTable<int, Row> table = EasyTable<int, Row>(
      cellBuilder: _cellBuilder,
      rows: rows,
      columns: [1, 2],
    );

    return Scaffold(
        appBar: AppBar(
          title: const Text('EasyTable example'),
        ),
        body: Center(child: table));
  }

  Widget _cellBuilder(BuildContext context, int column, Row row) {
    if (column == 1) {
      return Text(row.name);
    }
    return Text(row.value);
  }
}
