import 'dart:math';

import 'package:easy_table/easy_table.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class Person {
  Person(this.name, this.value);

  final String name;
  final int value;

  bool _valid = true;

  bool get valid => _valid;

  String _editable = '';

  String get editable => _editable;

  set editable(String value) {
    _editable = value;
    _valid = _editable.length < 6;
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyTable Example',
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
  EasyTableModel<Person>? _model;

  @override
  void initState() {
    super.initState();

    List<Person> rows = [];

    Random random = Random();
    for (int i = 1; i < 500; i++) {
      rows.add(Person('User $i', random.nextInt(100)));
    }

    _model = EasyTableModel<Person>(rows: rows, columns: [
      EasyTableColumn(name: 'Name', stringValue: (row) => row.name),
      EasyTableColumn(name: 'Value', intValue: (row) => row.value),
      EasyTableColumn(
          name: 'Editable',
          cellBuilder: _buildField,
          cellBackground: (rowData) =>
              rowData.row.valid ? Colors.transparent : Colors.red[800]),
    ]);
  }

  Widget _buildField(BuildContext context, RowData<Person> rowData) {
    return TextFormField(
        initialValue: rowData.row.editable,
        style:
            TextStyle(color: rowData.row.valid ? Colors.black : Colors.white),
        onChanged: (value) => _onFieldChange(value, rowData.row));
  }

  void _onFieldChange(String value, Person person) {
    final wasValid = person.valid;
    person.editable = value;
    if (wasValid != person.valid) {
      setState(() {
        // rebuild
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: EasyTable<Person>(_model));
  }
}
