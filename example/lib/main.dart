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
          EasyTableColumn(
              name: 'Name',
              initialWidth: 150,
              valueMapper: (character) => character.name),
          EasyTableColumn(
              name: 'Race',
              initialWidth: 100,
              valueMapper: (character) => character.race),
          EasyTableColumn(
              name: 'Class',
              initialWidth: 130,
              valueMapper: (character) => character.cls),
          EasyTableColumn(
              name: 'Level',
              initialWidth: 80,
              valueMapper: (character) => character.level),
          EasyTableColumn(
              name: 'Skills',
              initialWidth: 100,
              cellBuilder: (context, character) =>
                  SkillsWidget(skills: character.skills)),
          EasyTableColumn(
              name: 'Strength',
              initialWidth: 80,
              valueMapper: (character) => character.strength),
          EasyTableColumn(
              name: 'Dexterity',
              initialWidth: 80,
              valueMapper: (character) => character.dexterity),
          EasyTableColumn(
              name: 'Intelligence',
              initialWidth: 100,
              valueMapper: (character) => character.intelligence),
          EasyTableColumn(
              name: 'Life',
              initialWidth: 80,
              valueMapper: (character) => character.life),
          EasyTableColumn(
              name: 'Mana',
              initialWidth: 80,
              valueMapper: (character) => character.mana),
          EasyTableColumn(
              name: 'Gold',
              initialWidth: 130,
              fractionDigits: 2,
              valueMapper: (character) => character.gold),
        ],
        rowColor: RowColors.evenOdd());
  }
}
