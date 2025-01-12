import 'dart:math';

import 'package:davi/davi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

final Random random = Random();

DateTime randomDate() {
  DateTime start = DateTime(2025, 1, 1);
  DateTime end = DateTime(2025, 1, 25);
  final difference = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
  final randomMilliseconds = random.nextInt(difference);
  return start.add(Duration(milliseconds: randomMilliseconds));
}

String randomID() {
  return random.nextInt(0xFFFFFF).toRadixString(16).toUpperCase();
}

Status randomStatus() {
  return Status.values[random.nextInt(Status.values.length)];
}

enum Status {
  approved('Approved', Colors.green),
  processing('Processing', Colors.blue),
  canceled('Canceled', Colors.red);

  final String text;
  final Color color;

  const Status(this.text, this.color);

  @override
  String toString() => text;
}

class Data {
  Data({required this.orderId, required this.status, required this.orderDate});

  final String orderId;
  final Status status;
  final DateTime orderDate;
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DaviModel<Data> _model;

  @override
  void initState() {
    super.initState();
    _buildModel();
  }

  void _buildModel() {
    List<Data> rows = List.generate(
        50,
        (index) => Data(
            orderId: randomID(),
            status: randomStatus(),
            orderDate: randomDate()));

    _model = DaviModel<Data>(
        rows: rows,
        columns: [
          DaviColumn(
              name: 'Order ID', cellValue: (params) => params.data.orderId),
          DaviColumn(
              name: 'Status',
              cellValue: (params) => params.data.status,
              cellTextStyle: (params) =>
                  TextStyle(color: params.data.status.color)),
          DaviColumn(
              name: 'Order data',
              cellValue: (params) => params.data.orderDate,
              cellValueStringify: (value) {
                DateTime date = value as DateTime;
                return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              })
        ],
        multiSortEnabled: true);
  }

  @override
  Widget build(BuildContext context) {
    DaviTheme theme = DaviTheme(
        data: DaviThemeData(
            row: RowThemeData(
              fillHeight: true,
              color: RowThemeData.zebraColor(),
              hoverForeground: (index) =>
                  Colors.blue[300]!.withValues(alpha: .2),
            ),
            cell: CellThemeData(nullValueColor: (index, hover) => Colors.grey)),
        child: Davi<Data>(_model,
            columnWidthBehavior: ColumnWidthBehavior.fit, visibleRowsCount: 6));

    return Scaffold(
        body: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(32),
            child: theme));
  }
}
