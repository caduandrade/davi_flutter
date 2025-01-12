import 'dart:math';

import 'package:davi/davi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class Data {
  Data({required this.stringValue, required this.intValue, required this.bar});

  final String stringValue;
  final int? intValue;

  final double? bar;

  bool get valid => editable.length < 6;

  String editable = '';
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

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
    Random random = Random();
    List<Data> rows = [];
    for (int i = 1; i < 200; i++) {
      String stringValue =
          random.nextInt(0xFFFFFF).toRadixString(16).toUpperCase();
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
              cellValue: (params) => params.data.stringValue,
              pinStatus: PinStatus.left),
          DaviColumn(
              name: 'Int 1',
              cellValue: (params) => params.data.intValue,
              summary: (context) => const Text('summary')),
          DaviColumn(
              name: 'Int 2',
              cellValue: (params) =>
                  params.rowIndex == 2 ? 'SPAN' : params.data.intValue,
              columnSpan: (params) => params.rowIndex == 2 ? 2 : 1,
              cellBackground: (params) =>
                  params.data.intValue == 10 ? Colors.green : null),
          DaviColumn(
              name: 'Widget',
              cellWidget: (params) => params.rowIndex == 10
                  ? Container(color: Colors.white, child: const Placeholder())
                  : null,
              rowSpan: (params) => params.rowIndex == 10 ? 6 : 1),
          DaviColumn(name: 'Bar', cellBarValue: (params) => params.data.bar),
          DaviColumn(
              name: 'Editable',
              sortable: false,
              cellWidget: _buildField,
              //cellListenable: (d,i)=>d,
              cellBackground: (params) =>
                  params.data.valid ? null : Colors.red[800])
        ],
        multiSortEnabled: true);
  }

  Widget _buildField(WidgetBuilderParams<Data> params) {
    return TextFormField(
        key: params.localKey,
        initialValue: params.data.editable,
        onChanged: (value) =>
            _onFieldChange(value, params.data, params.rebuildCallback));
  }

  void _onFieldChange(String value, Data person, VoidCallback rebuild) {
    final wasValid = person.valid;
    person.editable = value;
    if (wasValid != person.valid) {
      rebuild.call();
    }
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
        child: Davi<Data>(_model, onRowTap: _onRowTap));

    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(
          child: TextButton(
              onPressed: _onTextButtonClick, child: const Text('rebuild'))),
      Expanded(child: Padding(padding: const EdgeInsets.all(32), child: theme))
    ]));
  }

  void _onRowTap(Data p) {
    // print('tap: ${p.intValue}');
  }

  void _onTextButtonClick() {
    setState(() {
      _buildModel();
    });
  }
}
