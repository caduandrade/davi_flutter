import 'package:easy_table/easy_table.dart';
import 'package:easy_table_example/character.dart';
import 'package:easy_table_example/skills_widget.dart';
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
      title: 'EasyTable Example',
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
  EasyTableModel<Character>? _model;

  @override
  void initState() {
    super.initState();

    Character.loadCharacters().then((characters) {
      EasyTableModel<Character> model =
          EasyTableModel(rows: characters, columns: [
        EasyTableColumn(
            name: 'Name', width: 100, stringValue: (row) => row.name),
        EasyTableColumn(
            name: 'Gender',
            width: 80,
            cellBuilder: (context, row) => EasyTableCell(
                child: row.male
                    ? const Icon(Icons.male)
                    : const Icon(Icons.female))),
        EasyTableColumn(
            name: 'Race', width: 100, stringValue: (row) => row.race),
        EasyTableColumn(
            name: 'Class', width: 110, stringValue: (row) => row.cls),
        EasyTableColumn(name: 'Level', width: 70, intValue: (row) => row.level),
        EasyTableColumn(
            name: 'Skills',
            width: 100,
            cellBuilder: (context, row) => SkillsWidget(skills: row.skills)),
        EasyTableColumn(
            name: 'Strength', width: 80, intValue: (row) => row.strength),
        EasyTableColumn(
            name: 'Dexterity', width: 80, intValue: (row) => row.dexterity),
        EasyTableColumn(
            name: 'Intelligence',
            width: 90,
            intValue: (row) => row.intelligence),
        EasyTableColumn(name: 'Life', width: 70, intValue: (row) => row.life),
        EasyTableColumn(name: 'Mana', width: 70, intValue: (row) => row.mana),
        EasyTableColumn(
            name: 'Gold',
            width: 110,
            doubleValue: (row) => row.gold,
            fractionDigits: 2)
      ]);
      setState(() {
        _model = model;
      });
    });
  }

  double size = 4000;
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    Widget? body;
    if (_model == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = EasyTableTheme(
          child: _table(),
          data:
              EasyTableThemeData(row:RowThemeData(hoveredColor: (index) => Colors.blue[50])));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('EasyTable Example'),
        ),
        body: Column(children: [
          _buttons(),
          Expanded(
              child: Padding(child: body, padding: const EdgeInsets.all(16)))
        ], crossAxisAlignment: CrossAxisAlignment.stretch));
  }

  Widget _table() {
    return EasyTable<Character>(_model,
        onRowTap: (row) => print(row.name), columnsFit: true);
  }

  Widget _buttons() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
            child: Row(children: [
              ElevatedButton(
                  onPressed: _removeFirstRow,
                  child: const Text('Remove first row')),
              const SizedBox(width: 16),
              ElevatedButton(
                  onPressed: _removeFirstColumn,
                  child: const Text('Remove first column'))
            ]),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0)));
  }

  void _removeFirstRow() {
    if (_model != null && _model!.isRowsNotEmpty) {
      _model!.removeVisibleRowAt(0);
    }
  }

  void _removeFirstColumn() {
    if (_model != null && _model!.isColumnsNotEmpty) {
      _model!.removeColumnAt(0);
    }
  }
}
