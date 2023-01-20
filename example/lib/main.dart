import 'dart:math';

import 'package:davi/davi.dart';
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
      title: 'Davi Example',
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
  DaviModel<Person>? _model;

  @override
  void initState() {
    super.initState();

    List<Person> rows = [];

    Random random = Random();
    for (int i = 1; i < 500; i++) {
      rows.add(Person('User $i', random.nextInt(100)));
    }

    _model = DaviModel<Person>(
        rows: rows,
        columns: [
          DaviColumn(name: 'Name', stringValue: (row) => row.name),
          DaviColumn(
              name: 'Value',
              intValue: (row) => row.value)
        ],
       // customSort: _myCustomCompoundSort
    );
  }

  int _myCustomColumnSort(Person a, Person b) {
    // Now I realize that here I could receive the column.
    //TableSortOrder order = _model!.columnAt(1).order!;
    // ...
    return 0;
  }

  /// same default behavior (compound sort)
  int _myCustomCompoundSort(
      Person a, Person b, List<DaviColumn<Person>> sortedColumns) {
    int r = 0;
    for (int i = 0; i < sortedColumns.length; i++) {
      final DaviColumnSort<Person> sort = sortedColumns[i].sort!;
      final TableSortOrder order = sortedColumns[i].order!;

      if (order == TableSortOrder.descending) {
        r = sort(b, a);
      } else {
        r = sort(a, b);
      }
      if (r != 0) {
        break;
      }
    }
    return r;
  }

  Widget _buildField(BuildContext context, DaviRow<Person> rowData) {
    return TextFormField(
        initialValue: rowData.data.editable,
        style:
            TextStyle(color: rowData.data.valid ? Colors.black : Colors.white),
        onChanged: (value) => _onFieldChange(value, rowData.data));
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
    return Scaffold(body: Davi<Person>(_model));
  }
}
