import 'package:easy_table/easy_table.dart';
import 'package:easy_table_example/demo/character.dart';
import 'package:easy_table_example/demo/demo_checkbox.dart';
import 'package:easy_table_example/demo/skills_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EasyTable Demo',
        home: Scaffold(body: HomePage()));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  EasyTableModel<Character>? _model;
  bool _fewRows = false;
  bool _leftPinned = false;
  bool _hoverBackground = false;
  bool _hoverForeground = true;
  bool _rowFillHeight = false;
  bool _nullValueColor = true;

  @override
  void initState() {
    super.initState();
    _buildModel().then((model) {
      setState(() {
        _model = model;
      });
    });
  }

  Future<EasyTableModel<Character>> _buildModel() async {
    List<Character> characters = await Character.loadCharacters();
    if (_fewRows) {
      characters = characters.sublist(0, 5);
    }
    return EasyTableModel(rows: characters, columns: _buildColumns());
  }

  List<EasyTableColumn<Character>> _buildColumns() {
    return [
      EasyTableColumn(
          pinStatus: _leftPinned ? PinStatus.left : PinStatus.none,
          leading: const Icon(Icons.person, size: 16),
          name: 'Name',
          width: 100,
          stringValue: (row) => row.name),
      EasyTableColumn(
          name: 'Gender',
          width: 80,
          iconValue: (row) => row.male
              ? CellIcon(icon: Icons.male, color: Colors.blue[700]!)
              : CellIcon(icon: Icons.female, color: Colors.pink[600]!)),
      EasyTableColumn(name: 'Race', width: 100, stringValue: (row) => row.race),
      EasyTableColumn(name: 'Class', width: 110, stringValue: (row) => row.cls),
      EasyTableColumn(name: 'Level', width: 70, intValue: (row) => row.level),
      EasyTableColumn(
          name: 'Skills',
          width: 100,
          cellBuilder: (context, data) =>
              SkillsWidget(skills: data.row.skills)),
      EasyTableColumn(
          name: 'Strength', width: 80, intValue: (row) => row.strength),
      EasyTableColumn(
          name: 'Dexterity', width: 80, intValue: (row) => row.dexterity),
      EasyTableColumn(
          name: 'Intelligence', width: 90, intValue: (row) => row.intelligence),
      EasyTableColumn(name: 'Life', width: 70, intValue: (row) => row.life),
      EasyTableColumn(name: 'Mana', width: 70, intValue: (row) => row.mana),
      EasyTableColumn(
          name: 'Gold',
          width: 110,
          doubleValue: (row) => row.gold, //row.gold,
          fractionDigits: 2)
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_model == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget table = EasyTableTheme(
        child: EasyTable<Character>(_model, multiSortEnabled: true),
        data: EasyTableThemeData(
            cell: CellThemeData(
                nullValueColor: _nullValueColor
                    ? (index, hovered) => Colors.grey[200]
                    : null),
            row: RowThemeData(
                fillHeight: _rowFillHeight,
                hoverBackground:
                    _hoverBackground ? (index) => Colors.blue[50] : null,
                hoverForeground: _hoverForeground
                    ? (index) => Colors.black.withOpacity(.1)
                    : null)));

    return Row(children: [
      _options(),
      Expanded(child: Padding(child: table, padding: const EdgeInsets.all(16)))
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  Widget _options() {
    return SingleChildScrollView(
        child: Padding(
            child: Wrap(direction: Axis.vertical, spacing: 8, children: [
              ElevatedButton(
                  onPressed: _removeFirstRow,
                  child: const Text('Remove first row')),
              ElevatedButton(
                  onPressed: _removeFirstColumn,
                  child: const Text('Remove first column')),
              CheckboxUtil.build(
                  value: _fewRows, onChanged: _onFewRows, text: 'Few rows'),
              CheckboxUtil.build(
                  value: _leftPinned,
                  onChanged: _onLeftPinned,
                  text: 'Left pinned'),
              CheckboxUtil.build(
                  value: _rowFillHeight,
                  onChanged: _onRowFillHeight,
                  text: 'Row fill height'),
              CheckboxUtil.build(
                  value: _hoverBackground,
                  onChanged: _onHoverBackground,
                  text: 'Hover background'),
              CheckboxUtil.build(
                  value: _hoverForeground,
                  onChanged: _onHoverForeground,
                  text: 'Hover foreground'),
              CheckboxUtil.build(
                  value: _nullValueColor,
                  onChanged: _onNullValueColor,
                  text: 'Null value color')
            ]),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0)));
  }

  void _removeFirstRow() {
    if (_model != null && _model!.isOriginalRowsNotEmpty) {
      _model!.removeRowAt(0);
    }
  }

  void _removeFirstColumn() {
    if (_model != null && _model!.isColumnsNotEmpty) {
      _model!.removeColumnAt(0);
    }
  }

  void _onRowFillHeight() {
    setState(() {
      _rowFillHeight = !_rowFillHeight;
    });
  }

  void _onHoverBackground() {
    setState(() {
      _hoverBackground = !_hoverBackground;
    });
  }

  void _onHoverForeground() {
    setState(() {
      _hoverForeground = !_hoverForeground;
    });
  }

  void _onFewRows() {
    _fewRows = !_fewRows;
    _buildModel().then((model) {
      setState(() {
        _model = model;
      });
    });
  }

  void _onLeftPinned() {
    setState(() {
      _leftPinned = !_leftPinned;
      _model?.removeColumns();
      _model?.addColumns(_buildColumns());
    });
  }

  void _onNullValueColor() {
    setState(() {
      _nullValueColor = !_nullValueColor;
    });
  }
}
