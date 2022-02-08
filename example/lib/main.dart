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

class User {
  User({required this.name, required this.age});

  final String name;
  final int age;
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    List<User> rows = [];
    for (int i = 1; i < 5000; i++) {
      rows.add(User(name: 'Name $i', age: i));
    }

     EasyTable table = EasyTable<User>(
        rows: rows,
        columns: [
          EasyTableColumn(
              name: 'Name',
              cellBuilder: (context, user, rowIndex) => _cellWidget(user.name)),
          EasyTableColumn(
              name: 'Age',
              cellBuilder: (context, user, rowIndex) =>
                  _cellWidget(user.age.toString()))
        ],
        rowColor: RowColors.evenOdd());

    return Scaffold(
        appBar: AppBar(
          title: const Text('EasyTable example'),
        ),
        body: table);
  }

  Widget _cellWidget(String value) {
    return Center(child: Text(value));
  }
}
