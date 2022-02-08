import 'package:easy_table/easy_table.dart';
import 'package:easy_table_example/character.dart';
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

class _HomePageState extends State<HomePage> {
  List<Character>? rows;

  @override
  void initState() {
    super.initState();
    Character.loadCharacters().then((characters) {
      setState(() {
        rows = characters;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? body;
    if (rows == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = _table();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('EasyTable example'),
        ),
        body: body);
  }

  Widget _table() {
    return EasyTable<Character>(
        rows: rows,
        columns: [
          EasyTableColumn(
              name: 'Name',
              initialWidth: 150,
              cellBuilder: (context, user, rowIndex) =>
                  EasyTableCell(value: user.name)),
          EasyTableColumn(
              name: 'Race',
              initialWidth: 100,
              cellBuilder: (context, user, rowIndex) =>
                  EasyTableCell(value: user.race)),
          EasyTableColumn(
              name: 'Class',
              initialWidth: 130,
              cellBuilder: (context, user, rowIndex) =>
                  EasyTableCell(value: user.cls)),
          EasyTableColumn(
              name: 'Level',
              initialWidth: 80,
              cellBuilder: (context, user, rowIndex) =>
                  EasyTableCell.int(value: user.level)),
          EasyTableColumn(
              name: 'Gold',
              initialWidth: 150,
              cellBuilder: (context, user, rowIndex) =>
                  EasyTableCell.double(value: user.gold, fractionDigits: 2)),
        ],
        rowColor: RowColors.evenOdd());
  }
}
