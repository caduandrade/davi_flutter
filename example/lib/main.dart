import 'dart:math';

import 'package:davi/davi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class Data extends ChangeNotifier {
  Data({required this.stringValue, required this.intValue,required this.bar});

  final String stringValue;
  final int? intValue;

  final double? bar;

  bool _valid = true;

  bool get valid => _valid;

  String _editable = '';

  String get editable => _editable;

  TextEditingController c = TextEditingController();

  set editable(String value) {
    _editable = value;
    _valid = _editable.length < 6;
    notifyListeners();
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
  late DaviModel<Data> _model;

  @override
  void initState() {
    super.initState();
    _buildModel();
  }

  void _buildModel() {
    Random random = Random();
    List<Data> rows = [];    
    for (int i = 1; i < 200; i++) {    
      String stringValue= random.nextInt(90000).toRadixString(16);
     int intValue = random.nextInt(99);
     double bar = random.nextDouble();      
      rows.add(Data(stringValue: stringValue, intValue: intValue, bar: bar));
    }
    // rows.shuffle();

    _model = DaviModel<Data>(
        rows: rows,
        columns: [
          DaviColumn(
              name: 'String',
              cellValue: (data, rowIndex) => data.stringValue,
              pinStatus: PinStatus.left),
          DaviColumn(
              name: 'Int 1',
              cellValue: (data, rowIndex) => data.intValue,
              summary: (context) => const Text('summary')),
          DaviColumn(
              name: 'Int 2',
              cellValue: (data, rowIndex) =>
              rowIndex == 2 ? 'SPAN' : data.intValue,
              columnSpan: (data, rowIndex) => rowIndex == 2 ?2 : 1,
              cellBackground: (data, index, hovered) =>
              data.intValue == 10 ? Colors.green : null),
          DaviColumn(
              name: 'Widget',
              cellWidget: (context,data,rowIndex)=>rowIndex==10?Container(color:Colors.white, child:const Placeholder()):null,
              rowSpan: (data, rowIndex) => rowIndex == 10 ? 6 : 1
    ),
          DaviColumn(
              name: 'Bar',
              cellBarValue: (data, rowIndex) => data.bar),   
            DaviColumn(
              name: 'Editable',
              sortable: false,
              cellWidget: _buildField,
              cellListenable: (d,i)=>d,
              cellBackground: (data, rowIndex, hover) => data.valid ? null : Colors.red[800]
            )
        ],
        multiSortEnabled: true
    );
  }

  Widget _buildField(
      BuildContext context, Data data, int index) {
    if (true) {
      return TextFormField(
        validator: (s)=>'ds',
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: data.c,
          //key: ValueKey(rowData.index),
          //initialValue: rowData.data.editable,
          onChanged: (value) => _onFieldChange(value, data));
    }
    return TextFormField(
      key: ValueKey(index),
        initialValue: data.editable,
        style: TextStyle(color: data.valid ? Colors.black : Colors.white),
        onChanged: (value) => _onFieldChange(value, data));
  }

  void _onFieldChange(String value, Data person) {
    final wasValid = person.valid;
    person.editable = value;
    if (wasValid != person.valid) {
      /*
      setState(() {
        // rebuild
      });

       */
    }
  }

  @override
  Widget build(BuildContext context) {
    DaviTheme theme = DaviTheme(
        data: DaviThemeData(
            row: RowThemeData(
              fillHeight: true,
              color: RowThemeData.zebraColor(),
              hoverForeground: (index) => Colors.blue[300]!.withOpacity(.2),
            ),
            cell: CellThemeData(
                nullValueColor: (index, hover) => Colors.grey)),
        child: Davi<Data>(
          _model,
          // onHover: (index) => print('hover: $index'),
          onRowTap: _onRowTap
        ));

    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(child: TextButton(onPressed: _onTextButtonClick, child: const Text('rebuild'))),
      Expanded(child: Padding(padding: const EdgeInsets.all(32), child: theme))
    ]));
  }

  void _onRowTap(Data p) {
    print('tap: ${p.intValue}');
  }

  void _onTextButtonClick() {
    setState(() {
      _buildModel();
    });
  }
}


