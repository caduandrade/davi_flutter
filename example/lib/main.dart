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
        EasyTableColumn(pinned: true,
            leading: const Icon(Icons.person, size: 16),
            name: 'Name',
            width: 100,
            stringValue: (row) => row.name),
        EasyTableColumn(pinned: true,
            name: 'Gender',
            width: 80,
            cellBuilder: (context, row) => EasyTableCell(
                child: row.male
                    ? const Icon(Icons.male)
                    : const Icon(Icons.female))),
        EasyTableColumn(pinned: true,
            name: 'Race', width: 100, stringValue: (row) => row.race),
        EasyTableColumn(pinned: true,
            name: 'Class', width: 110, stringValue: (row) => row.cls),
        EasyTableColumn(name: 'Level', width: 70, intValue: (row) => row.level),
        EasyTableColumn(pinned: true,
            name: 'Skills',
            width: 100,
            cellBuilder: (context, row) =>
                EasyTableCell(child: SkillsWidget(skills: row.skills))),
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

    scrollController2.addListener(() {
      scrollController.jumpTo(scrollController2.offset);
    });
    scrollController.addListener(() {
      scrollController2.jumpTo(scrollController.offset);
    });
  }
  
  ScrollController scrollController = ScrollController();
  ScrollController scrollController2 = ScrollController();

  @override
  Widget build(BuildContext context) {
    Widget? body;


    if (_model == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = EasyTableTheme(
          child: _table(),
          data: EasyTableThemeData(
              row: RowThemeData(hoveredColor: (index) => Colors.blue[50])));
    }

    /*
    ThemeData themeData = Theme.of(context);
    print(themeData.scrollbarTheme.crossAxisMargin);


    
    Widget listView = ListView.builder(controller:scrollController,itemBuilder: ((context, index) => Container(child: Text('$index'),color: Colors.yellow)),itemCount: 100, itemExtent: 20);

    listView= ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child:listView);


    Widget scrollTest =Container(color:Colors.green[300],width: 11,height: 2000);
    scrollTest = SingleChildScrollView(child:scrollTest,controller: scrollController2);
    scrollTest=ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child:scrollTest);
    scrollTest =Scrollbar(isAlwaysShown: true, child:scrollTest,controller: scrollController2, thickness: 5, hoverThickness: 5,radius: null);


    body = Row(children: [Expanded(child: listView), scrollTest]);
    //body = Row(children: [Expanded(child: listView), Container(color:Colors.pink,width: 20, child: ElevatedButton(child: Text('x'),onPressed: _on))]);
*/


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

  void _on(){
    scrollController.jumpTo(300);
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
