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
      setState(() {
        _model = EasyTableModel(rows: characters, columns: [
          EasyTableColumn.auto((row) => row.name, name: 'Name', width: 140),
          EasyTableColumn.builder(
              (context, row) => Align(
                  child: row.male
                      ? const Icon(Icons.male)
                      : const Icon(Icons.female),
                  alignment: Alignment.centerLeft),
              name: 'Gender',
              width: 70),
          EasyTableColumn.auto((row) => row.race, name: 'Race', width: 100),
          EasyTableColumn.auto((row) => row.cls, name: 'Class', width: 110),
          EasyTableColumn.auto((row) => row.level, name: 'Level', width: 80),
          EasyTableColumn.builder(
              (context, row) => SkillsWidget(skills: row.skills),
              name: 'Skills',
              width: 100),
          EasyTableColumn.auto((row) => row.strength,
              name: 'Strength', width: 80),
          EasyTableColumn.auto((row) => row.dexterity,
              name: 'Dexterity', width: 80),
          EasyTableColumn.auto((row) => row.intelligence,
              name: 'Intelligence', width: 90),
          EasyTableColumn.auto((row) => row.life, name: 'Life', width: 80),
          EasyTableColumn.auto((row) => row.mana, name: 'Mana', width: 70),
          EasyTableColumn.auto((row) => row.gold,
              name: 'Gold', width: 110, fractionDigits: 2)
        ]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? body;
    if (_model == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      // body = EasyTableTheme(child: _table(), data: EasyTableThemeData());
      body = _table();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('EasyTable Example'),
        ),
        body: Column(children: [
          _buttons(),
          Expanded(
              child: Padding(child: body, padding: const EdgeInsets.all(32)))
        ], crossAxisAlignment: CrossAxisAlignment.stretch));
  }

  Widget _table() {
    return EasyTable<Character>(model: _model!);
  }

  Widget _buttons() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
            child: Row(children: [
              ElevatedButton(
                  onPressed: _removeFirst, child: const Text('Remove first'))
            ]),
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 0)));
  }

  void _removeFirst() {
    if (_model != null && _model!.isRowsNotEmpty) {
      _model!.removeRowAt(0);
    }
  }
}
