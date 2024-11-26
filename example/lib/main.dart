import 'dart:math';

import 'package:davi/davi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class Person {
  Person(this.name, this.age, this.value);

  final String name;
  final int age;
  final int? value;

  bool _valid = true;

  bool get valid => _valid;

  String _editable = '';

  String get editable => _editable;

  TextEditingController c = TextEditingController();

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
  late DaviModel<Person> _model;

  @override
  void initState() {
    super.initState();
    _buildModel();
  }

  void _buildModel() {
    List<Person> rows = [];

    Random random = Random();
    for (int i = 1; i < 215; i++) {
      rows.add(Person('User $i', 20 + random.nextInt(50), i == 1 ? null : i));
    }
    // rows.shuffle();

    _model = DaviModel<Person>(
        rows: rows,
        columns: [
          DaviColumn(
              name: 'Name',
              stringValue: (data) => data.name,
              pinStatus: PinStatus.left),
          DaviColumn(
              name: 'Age',
              intValue: (data) => data.age,
              pinStatus: PinStatus.left,
              summaryValue: (data) => 'test'),
          DaviColumn(
              name: 'Value',
              intValue: (data) => data.value,
              pinStatus: PinStatus.left),
          DaviColumn(
              name: 'Value 2',
              intValue: (data) => data.value,
              cellTextStyle: TextStyle(fontWeight: FontWeight.bold),
              cellBackground: (data, index, hovered) =>
                  data.value == 12 ? Colors.green : null),
          DaviColumn(name: 'Value 3', intValue: (data) => data.value),
          DaviColumn(name: 'Value 4', intValue: (data) => data.value),
          DaviColumn(name: 'Value 5', intValue: (data) => data.value),
          DaviColumn(name: 'Value 6', intValue: (data) => data.value),
          DaviColumn(name: 'Value 7', intValue: (data) => data.value),

          /*  DaviColumn(
              name: 'Editable',
              sortable: false,
              cellBuilder: _buildField,
              cellBackground: (row) => row.data.valid ? null : Colors.red[800])*/
        ],
        alwaysSorted: true,
        multiSortEnabled: true);
  }

  Widget _buildField(
      BuildContext context, Person data, int index, bool hovered) {
    if (true) {
      return TextFormField(
          controller: data.c,
          //key: ValueKey(rowData.index),
          //initialValue: rowData.data.editable,
          onChanged: (value) => _onFieldChange(value, data));
    }
    return TextFormField(
        initialValue: data.editable,
        style: TextStyle(color: data.valid ? Colors.black : Colors.white),
        onChanged: (value) => _onFieldChange(value, data));
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
    DaviTheme theme = DaviTheme(
        data: DaviThemeData(
            columnDividerThickness: 10,
            columnDividerColor: Colors.yellow,
            row: RowThemeData(
              fillHeight: true,
              dividerThickness: 10,
              dividerColor: Colors.pink,
              color: RowThemeData.zebraColor(
                  evenColor: Colors.pink[100], oddColor: Colors.yellow[100]),
              //  hoverBackground: (index) => Colors.blue[300],
              hoverForeground: (index) => Colors.blue[300]!.withOpacity(.5),
            ),
            cell: CellThemeData(
                nullValueColor: (index, hover) =>
                    hover ? Colors.yellow : Colors.orange)),
        child: Davi<Person>(
          _model,
          // onHover: (index) => print('hover: $index'),
          onRowTap: _onRowTap,
          //  onLastVisibleRow: (index)=>print('last visible row: $index ${DateTime.now()}'),
          //  onTrailingWidget: (visible)=>print('trailing widget: $visible ${DateTime.now()}'),
          // trailingWidget: const Center(child: Text('last widget'))
        ));

    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextButton(onPressed: _onclick, child: Text('ok')),
      Expanded(child: theme)
    ]));
  }

  void _onHover(int? index) {
    print('onHover: $index');
  }

  void _onRowTap(Person p) {
    print('tap: ${p.value}');
  }

  void _onclick() {
    setState(() {
      _buildModel();
    });
  }
}

class MM extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => St();
}

class St extends State<MM> {
  Color color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(50),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: _onEnter,
            onExit: _onExit,
            child: GestureDetector(
                onTap: _onTap,
                child: Container(
                    color: color,
                    child: Column(children: [
                      TextField(),
                      Expanded(child: Container())
                    ])))));
    //return Stack(children: [Positioned.fill(child: MouseRegion(onEnter: _onEnter, onExit: _onExit, child: Container(color:color))), TextField()]);
  }

  void _onEnter(e) {
    print('onenter');
    setState(() {
      color = Colors.blue;
    });
  }

  void _onTap() {
    print('tap');
  }

  void _onExit(e) {
    print('onExit');
    setState(() {
      color = Colors.white;
    });
  }
}
