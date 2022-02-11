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
      EasyTableModel<Character> model = EasyTableModel(rows: characters);
      model.columnAppender()
        ..valueMapper((row) => row.name,
            name: 'Name',
            width: 140,
            sortFunction: (a, b) => a.name.compareTo(b.name))
        ..cellBuilder(
            (context, row) => Align(
                child: row.male
                    ? const Icon(Icons.male)
                    : const Icon(Icons.female),
                alignment: Alignment.centerLeft),
            name: 'Gender',
            width: 70)
        ..valueMapper((row) => row.race, name: 'Race', width: 100)
        ..valueMapper((row) => row.cls, name: 'Class', width: 110)
        ..valueMapper((row) => row.level, name: 'Level', width: 80)
        ..cellBuilder((context, row) => SkillsWidget(skills: row.skills),
            name: 'Skills', width: 100)
        ..valueMapper((row) => row.strength, name: 'Strength', width: 80)
        ..valueMapper((row) => row.dexterity, name: 'Dexterity', width: 80)
        ..valueMapper((row) => row.intelligence,
            name: 'Intelligence', width: 90)
        ..valueMapper((row) => row.life, name: 'Life', width: 80)
        ..valueMapper((row) => row.mana, name: 'Mana', width: 70)
        ..valueMapper((row) => row.gold,
            name: 'Gold', width: 110, fractionDigits: 2);
      setState(() {
        _model = model;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? body;
    if (_model == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      // body = EasyTableTheme(child: _table(), data: EasyTableThemeData();
      body = _table();
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
    return EasyTable<Character>(_model);
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
