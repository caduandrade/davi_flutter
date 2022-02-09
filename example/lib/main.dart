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
  List<Character>? rows;

  @override
  void initState() {
    super.initState();
    Character.loadCharacters().then((characters) {
      setState(() {
        rows = characters;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? body;
    if (rows == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = EasyTableTheme(child: _table(), data: EasyTableThemeData());
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('EasyTable Example'),
        ),
        body: Padding(child: body, padding: const EdgeInsets.all(32)));
  }

  Widget _table() {
    return EasyTable<Character>(
        rows: rows,
        columns: [
          EasyTableColumn.auto((row) => row.name,
              name: 'Name', initialWidth: 140),
          EasyTableColumn.builder(
              (context, row) => Align(
                  child: row.male
                      ? const Icon(Icons.male)
                      : const Icon(Icons.female),
                  alignment: Alignment.centerLeft),
              name: 'Gender',
              initialWidth: 70),
          EasyTableColumn.auto((row) => row.race,
              name: 'Race', initialWidth: 100),
          EasyTableColumn.auto((row) => row.cls,
              name: 'Class', initialWidth: 110),
          EasyTableColumn.auto((row) => row.level,
              name: 'Level', initialWidth: 80),
          EasyTableColumn.builder(
              (context, row) => SkillsWidget(skills: row.skills),
              name: 'Skills',
              initialWidth: 100),
          EasyTableColumn.auto((row) => row.strength,
              name: 'Strength', initialWidth: 80),
          EasyTableColumn.auto((row) => row.dexterity,
              name: 'Dexterity', initialWidth: 80),
          EasyTableColumn.auto((row) => row.intelligence,
              name: 'Intelligence', initialWidth: 90),
          EasyTableColumn.auto((row) => row.life,
              name: 'Life', initialWidth: 80),
          EasyTableColumn.auto((row) => row.mana,
              name: 'Mana', initialWidth: 70),
          EasyTableColumn.auto((row) => row.gold,
              name: 'Gold', initialWidth: 110, fractionDigits: 2)
        ],
        rowColor: RowColors.evenOdd());
  }
}
