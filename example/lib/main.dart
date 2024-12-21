import 'dart:math';

import 'package:davi/davi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class Person {
  Person(this.name, this.age, this.value, this.bar);

  final String name;
  final int age;
  final int? value;

  final double? bar;

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
    for (int i = 1; i < 200; i++) {
      String name = 'User $i';
      if (i == 4) {
        name += ' 12345678901234567890';
      }
      rows.add(Person(name, 20 + random.nextInt(50), i == 1 ? null : i, random.nextDouble()));
    }
    // rows.shuffle();

    _model = DaviModel<Person>(
        rows: rows,
        columns: [
          DaviColumn(
              name: 'Name',
              cellValue: (data, rowIndex) =>
                  rowIndex == 0 ? 'SPAN 1234567890123456789' : data.name,
             //rowSpan: (data, rowIndex) => rowIndex==1?2:1,
              columnSpan: (data, rowIndex) => rowIndex == 0 ? 2 : 1,
              pinStatus: PinStatus.left),
          DaviColumn(
              name: 'Age',
              cellValue: (data, rowIndex) => data.age,
              pinStatus: PinStatus.left,
              summary: (context) => const Text('test')),
          DaviColumn(
              name: 'Value',
              cellValue: (data, rowIndex) => data.value,
              pinStatus: PinStatus.left),
          DaviColumn(
              name: 'Painter',
              cellPainter: _cellPainter),
          DaviColumn(
              name: 'Value 3',
              cellWidget: (w,c,i)=>i==10?Placeholder():null,
              //cellValue: (data, rowIndex) =>  rowIndex == 4 ? 'SPAN R4C4' : data.value?.toString(),
              rowSpan: (data, rowIndex) => rowIndex == 10 ? 6 : 1
    ),

          DaviColumn(
              name: 'Value 4',
              cellValue: (data, rowIndex) =>
                  rowIndex == 2 ? 'SPANNNNNNN R2C5' : data.value,
              cellTextStyle: (data, rowIndex, hovered)=>const TextStyle(fontWeight: FontWeight.bold),
              columnSpan: (data, rowIndex) => rowIndex == 2 ?2 : 1,
              cellBackground: (data, index, hovered) =>
                  data.value == 12 ? Colors.green : null),
          DaviColumn(
              name: 'Bar',
              cellBarValue: (data, rowIndex) => data.bar),
          DaviColumn(
              name: 'Value 6',
              cellValue: (data, rowIndex) => data.value),
          DaviColumn(
              name: 'Value 7',
              cellValue: (data, rowIndex) => data.value
          ),

            DaviColumn(
              name: 'Editable',
              sortable: false,
              cellWidget: _buildField,
              //cellBackground: (row, index, hover) => data.valid ? null : Colors.red[800]
            )
        ],
      //  alwaysSorted: true,
        multiSortEnabled: true
    );
  }

  Widget _buildField(
      BuildContext context, Person data, int index) {
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
            header: const HeaderThemeData(bottomBorderThickness: 5),
            row: RowThemeData(
              fillHeight: true,
              dividerThickness: 10,
              dividerColor: Colors.pink,
              color: RowThemeData.zebraColor(
                  evenColor: Colors.pink[100], oddColor: Colors.yellow[100]),
                //hoverBackground: (index) => Colors.blue[300],
             // hoverForeground: (index) => Colors.blue[300]!.withOpacity(.5),
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
           trailingWidget: MouseRegion(onHover: (h)=>print('hover on trailing ${DateTime.now()}'), child: const Center(child: Text('trailing widget')))
        ));

    return Scaffold(
        body: Row(children: [SizedBox(width: 50),Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextButton(onPressed: _onclick, child: Text('ok')),
      Expanded(child: theme)
    ]))]));
  }

  void _onHover(int? index) {
    print('onHover: $index');
  }

  void _onRowTap(Person p) {
    print('tap: ${p.value}');
  }

  void _cellPainter(Canvas canvas, Size size, Person person) {
    final Paint paint = Paint()..color = Colors.blue;
      canvas.drawLine(Offset.zero, Offset(size.width, size.height),
         paint,
      );
  }

  void _onclick() {
    setState(() {
      _buildModel();
    });
  }
}


