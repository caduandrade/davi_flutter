import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'package:easy_table/easy_table.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(const ExampleApp());
}

class User {
  User(
      {required this.name,
      required this.male,
      required this.age,
      required this.mobile,
      required this.accountBalance,
      required this.id});

  final String name;
  final bool male;
  final int age;
  final String mobile;
  final String id;
  final double accountBalance;

  static Future<List<User>> loadUsers() async {
    math.Random random = math.Random();
    List<User> users = [];

    for (String name in await _readNames('data/females.txt')) {
      users.add(_user(name: name, male: false, random: random));
    }
    for (String name in await _readNames('data/males.txt')) {
      users.add(_user(name: name, male: true, random: random));
    }
    users.shuffle();
    return users;
  }

  static Future<List<String>> _readNames(String filePath) async {
    String names = await rootBundle.loadString(filePath);
    LineSplitter ls = const LineSplitter();
    return ls.convert(names);
  }

  static User _user(
      {required String name, required bool male, required math.Random random}) {
    String mobile =
        '+${100 + random.nextInt(9800)} ${100 + random.nextInt(9800)} ${100 + random.nextInt(9800)} ${100 + random.nextInt(9800)}';
    int age = 20 + random.nextInt(80);
    String id =
        '${(100000 + random.nextInt(899999)).toRadixString(16)}-${(100000 + random.nextInt(899999)).toRadixString(16)}-${(100000 + random.nextInt(899999)).toRadixString(16)}';
    double accountBalance = random.nextInt(500000) * random.nextDouble();
    return User(
        id: id,
        name: name,
        mobile: mobile,
        age: age,
        male: male,
        accountBalance: accountBalance);
  }
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
  List<User>? rows;

  @override
  void initState() {
    super.initState();
    User.loadUsers().then((users) {
      setState(() {
        rows = users;
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
    return EasyTable<User>(
        rows: rows!,
        columns: [
          EasyTableColumn(
              name: 'Id',
              initialWidth: 150,
              cellBuilder: (context, user, rowIndex) =>
                  EasyTableCell(value: user.id)),
          EasyTableColumn(
              name: 'Name',
              cellBuilder: (context, user, rowIndex) =>
                  EasyTableCell(value: user.name)),
          EasyTableColumn(
              name: 'Age',
              cellBuilder: (context, user, rowIndex) =>
                  EasyTableCell.int(value: user.age)),
          EasyTableColumn(
              name: 'Account balance',
              initialWidth: 150,
              cellBuilder: (context, user, rowIndex) => EasyTableCell.double(
                  value: user.accountBalance, fractionDigits: 2)),
          EasyTableColumn(
              name: 'Mobile',
              initialWidth: 150,
              cellBuilder: (context, user, rowIndex) =>
                  EasyTableCell(value: user.mobile)),
        ],
        rowColor: RowColors.evenOdd());
  }
}
