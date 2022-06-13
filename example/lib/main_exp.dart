import 'dart:math';

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
      debugShowCheckedModeBanner: false,
      title: 'Experimental',
      home: HomePage(),
    );
  }
}

class Value {
  Value(
      {required this.index,
      required this.string1,
      required this.string2,
      required this.string3,
      required this.string4,
      required this.string5,
      required this.string6,
      required this.string7,
      required this.int1});

  final int index;
  final String string1;
  final String string2;
  final String string3;
  final String string4;
  final String string5;
  final String string6;
  final String string7;
  final int int1;
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final EasyTableModel<Value> _model;
  late final List<Value> rows;

  bool _columnsFit = false;

  final bool _pinned = true;

  Color _columnDividerColor = EasyTableThemeDataDefaults.columnDividerColor;
  double _columnDividerThickness =
      EasyTableThemeDataDefaults.columnDividerThickness;
  double _headerCellHeight = HeaderCellThemeDataDefaults.height;
  Color _headerColumnDividerColor = HeaderThemeDataDefaults.columnDividerColor;

  Color _bottomBorderColor = HeaderThemeDataDefaults.bottomBorderColor;
  double _bottomBorderHeight = HeaderThemeDataDefaults.bottomBorderHeight;

  @override
  void initState() {
    Random random = Random();
    List<Value> rows = List<Value>.generate(
        100,
        (index) => Value(
            index: index,
            string1: random.nextInt(9999999).toRadixString(16),
            string2: random.nextInt(9999999).toRadixString(16),
            string3: random.nextInt(9999999).toRadixString(16),
            string4: random.nextInt(9999999).toRadixString(16),
            string5: random.nextInt(9999999).toRadixString(16),
            string6: random.nextInt(9999999).toRadixString(16),
            string7: random.nextInt(9999999).toRadixString(16),
            int1: random.nextInt(999)));
    _model = EasyTableModel(columns: [
      EasyTableColumn(
          name: 'index', pinned: _pinned, intValue: (row) => row.index),
      EasyTableColumn(
          name: 'string1', pinned: _pinned, stringValue: (row) => row.string1),
      EasyTableColumn(name: 'string2', stringValue: (row) => row.string2),
      EasyTableColumn(name: 'string3', stringValue: (row) => row.string3),
      EasyTableColumn(name: 'string4', stringValue: (row) => row.string4),
      EasyTableColumn(name: 'string5', stringValue: (row) => row.string5),
      EasyTableColumn(name: 'string6', stringValue: (row) => row.string6),
      EasyTableColumn(name: 'string7', stringValue: (row) => row.string7),
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  IntrinsicWidth(
                      child: CheckboxListTile(
                          title: const Text('columnsFit'),
                          value: _columnsFit,
                          onChanged: (newValue) => _changeColumnsFit(),
                          controlAffinity: ListTileControlAffinity.leading)),
                  ElevatedButton(
                      onPressed: _changeColumnDividerThickness,
                      child: const Text('columnDividerThickness')),
                  ElevatedButton(
                      onPressed: _changeColumnDividerColor,
                      child: const Text('columnDividerColor')),
                  ElevatedButton(
                      onPressed: _changeHeaderCellHeight,
                      child: const Text('headerCellHeight')),
                  ElevatedButton(
                      onPressed: _changeHeaderColumnDividerColor,
                      child: const Text('headerColumnDividerColor')),
                  ElevatedButton(
                      onPressed: _changeHeaderBottomBorder,
                      child: const Text('headerBottomBorder'))
                ])),
            Expanded(child: _tableArea())
          ],
        ));
  }

  Widget _tableArea() {
    return Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
            decoration: BoxDecoration(border: Border.all()),
            child: EasyTableTheme(
                data: EasyTableThemeData(
                    columnDividerThickness: _columnDividerThickness,
                    columnDividerColor: _columnDividerColor,
                    header: HeaderThemeData(
                        bottomBorderColor: _bottomBorderColor,
                        bottomBorderHeight: _bottomBorderHeight,
                        columnDividerColor: _headerColumnDividerColor),
                    headerCell: HeaderCellThemeData(height: _headerCellHeight),
                    row:
                        RowThemeData(hoveredColor: (index) => Colors.blue[50])),
                child: EasyTableExp(_model, columnsFit: _columnsFit))));
  }

  void _changeColumnsFit() {
    setState(() => _columnsFit = !_columnsFit);
  }

  void _changeColumnDividerThickness() {
    setState(() => _columnDividerThickness = _columnDividerThickness ==
            EasyTableThemeDataDefaults.columnDividerThickness
        ? 20
        : EasyTableThemeDataDefaults.columnDividerThickness);
  }

  void _changeColumnDividerColor() {
    setState(() => _columnDividerColor =
        _columnDividerColor == EasyTableThemeDataDefaults.columnDividerColor
            ? Colors.red
            : EasyTableThemeDataDefaults.columnDividerColor);
  }

  void _changeHeaderCellHeight() {
    setState(() => _headerCellHeight =
        _headerCellHeight == HeaderCellThemeDataDefaults.height
            ? 40
            : HeaderCellThemeDataDefaults.height);
  }

  void _changeHeaderColumnDividerColor() {
    setState(() => _headerColumnDividerColor =
        _headerColumnDividerColor == HeaderThemeDataDefaults.columnDividerColor
            ? Colors.green
            : HeaderThemeDataDefaults.columnDividerColor);
  }

  void _changeHeaderBottomBorder() {
    setState(() {
      _bottomBorderColor =
          _bottomBorderColor == HeaderThemeDataDefaults.bottomBorderColor
              ? Colors.blue
              : HeaderThemeDataDefaults.bottomBorderColor;

      _bottomBorderHeight =
          _bottomBorderHeight == HeaderThemeDataDefaults.bottomBorderHeight
              ? 4
              : HeaderThemeDataDefaults.bottomBorderHeight;
    });
  }
}
