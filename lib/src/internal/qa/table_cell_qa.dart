import 'package:easy_table/src/cell.dart';
import 'package:easy_table/src/column.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TableCellApp());
}

class _Row {
  _Row(this.value);

  final String value;
}

class TableCellApp extends StatelessWidget {
  const TableCellApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TableCell QA',
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
  final _Row row = _Row('Cadu Andrade');
  final EasyTableColumn<_Row> column =
      EasyTableColumn(stringValue: (row) => row.value);

  @override
  Widget build(BuildContext context) {
    Widget cellWidget = EasyTableCell.string(
        value: 'Cadu Andrade', textStyle: const TextStyle());

    return Scaffold(
        appBar: AppBar(
          title: const Text('TableCell QA'),
        ),
        body: Center(
            child: Container(
                decoration: BoxDecoration(border: Border.all(width: 1)),
                child: ConstrainedBox(
                    child: cellWidget,
                    constraints: const BoxConstraints.tightFor(
                        width: 150, height: 50)))));
  }
}
