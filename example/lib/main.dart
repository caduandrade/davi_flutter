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
    for (int i = 1; i < 500; i++) {
      rows.add(User(name: 'Name $i', age: i));
    }

    EasyTable<User> table = EasyTable<User>(
        rows: rows,
        columns: [
          EasyTableColumn<User>(
              cellBuilder: (context, user, rowIndex) =>
                  _cellWidget(user.name, rowIndex.isOdd)),
          EasyTableColumn<User>(
              cellBuilder: (context, user, rowIndex) =>
                  _cellWidget(user.age.toString(), rowIndex.isOdd))
        ],
        easyTableRowColor: (rowIndex) {
          return rowIndex.isOdd ? Colors.white : Colors.grey[200];
        });

    return Scaffold(
        appBar: AppBar(
          title: const Text('EasyTable example'),
        ),
        body: table);
  }

  Widget _cellWidget(String value, bool odd) {
    return Text(value);
  }
}
