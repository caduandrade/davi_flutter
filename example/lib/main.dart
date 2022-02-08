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
      body = _table();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('EasyTable Example'),
        ),
        body: Padding(
            child: Container(
                child: body,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey))),
            padding: const EdgeInsets.all(32)));
  }

  Widget _table() {
    return EasyTable<Character>(
        rows: rows,
        columns: [
          EasyTableColumn.auto((character) => character.name,
              name: 'Name', initialWidth: 150),
          EasyTableColumn.auto((character) => character.race,
              name: 'Race', initialWidth: 100),
          EasyTableColumn.auto((character) => character.cls,
              name: 'Class', initialWidth: 130),
          EasyTableColumn.auto((character) => character.level,
              name: 'Level', initialWidth: 80),
          EasyTableColumn.builder(
              (context, character) => SkillsWidget(skills: character.skills),
              name: 'Skills',
              initialWidth: 100),
          EasyTableColumn.auto((character) => character.strength,
              name: 'Strength', initialWidth: 80),
          EasyTableColumn.auto((character) => character.dexterity,
              name: 'Dexterity', initialWidth: 80),
          EasyTableColumn.auto((character) => character.intelligence,
              name: 'Intelligence', initialWidth: 100),
          EasyTableColumn.auto((character) => character.life,
              name: 'Life', initialWidth: 80),
          EasyTableColumn.auto((character) => character.mana,
              name: 'Mana', initialWidth: 80),
          EasyTableColumn.auto((character) => character.gold,
              name: 'Gold', initialWidth: 130, fractionDigits: 2),
        ],
        rowColor: RowColors.evenOdd());
  }
}
