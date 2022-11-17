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
  bool _headerVisible = HeaderThemeDataDefaults.visible;
  bool _fewRows = false;
  bool _leftPinned = false;
  bool _rowColor = false;
  bool _hoverBackground = false;
  bool _hoverForeground = true;
  bool _rowFillHeight = RowThemeDataDefaults.fillHeight;
  bool _nullValueColor = true;
  bool _lastRowWidget = false;
  bool _lastRowDividerVisible = RowThemeDataDefaults.lastDividerVisible;
  bool _columnDividerFillHeight =
      EasyTableThemeDataDefaults.columnDividerFillHeight;
  RowThemeColor _demoBackground = RowThemeColor.none;

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
          pinStatus: _leftPinned ? PinStatus.left : PinStatus.none,
          name: 'Gender',
          width: 80,
          cellClip: true,
          iconValue: (row) => row.male
              ? CellIcon(icon: Icons.male, color: Colors.blue[700]!)
              : CellIcon(icon: Icons.female, color: Colors.pink[600]!)),
      EasyTableColumn(name: 'Race', width: 100, stringValue: (row) => row.race),
      EasyTableColumn(name: 'Class', width: 110, stringValue: (row) => row.cls),
      EasyTableColumn(name: 'Level', width: 70, intValue: (row) => row.level),
      EasyTableColumn(
          name: 'Skills',
          width: 100,
          cellClip: true,
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
        child: EasyTable<Character>(_model,
            rowColor: _rowColor
                ? (data) => data.row.life < 1000 ? Colors.red[200] : null
                : null,
            lastRowWidget: _lastRowWidget
                ? const Center(child: Text('LAST ROW WIDGET'))
                : null,
            onLastRowWidget: _lastRowWidget ? _onLastRowWidget : null),
        data: EasyTableThemeData(
            columnDividerFillHeight: _columnDividerFillHeight,
            header: HeaderThemeData(visible: _headerVisible),
            cell: CellThemeData(
                nullValueColor: _nullValueColor
                    ? (index, hovered) => Colors.grey[200]
                    : null),
            row: _rowThemeData()));

    return Row(children: [
      _options(),
      Expanded(child: Padding(child: table, padding: const EdgeInsets.all(16)))
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  RowThemeData _rowThemeData() {
    ThemeRowColor? color;
    if (_demoBackground == RowThemeColor.zebra) {
      color = RowThemeData.zebraColor();
    } else if (_demoBackground == RowThemeColor.simple) {
      color = (index) => Colors.green[50];
    }
    return RowThemeData(
        color: color,
        lastDividerVisible: _lastRowDividerVisible,
        fillHeight: _rowFillHeight,
        hoverBackground: _hoverBackground ? (index) => Colors.blue[50] : null,
        hoverForeground:
            _hoverForeground ? (index) => Colors.black.withOpacity(.1) : null);
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
                  value: _headerVisible,
                  onChanged: _onHeaderVisible,
                  text: 'Header visible'),
              CheckboxUtil.build(
                  value: _leftPinned,
                  onChanged: _onLeftPinned,
                  text: 'Left pinned'),
              CheckboxUtil.build(
                  value: _lastRowWidget,
                  onChanged: _onLastRowWidgetSwitch,
                  text: 'Last row widget'),
              CheckboxUtil.build(
                  value: _columnDividerFillHeight,
                  onChanged: _onColumnDividerFillHeight,
                  text: 'Column divider fill height'),
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
                  text: 'Null value color'),
              CheckboxUtil.build(
                  value: _rowColor, onChanged: _onRowColor, text: 'Row color'),
              CheckboxUtil.build(
                  value: _lastRowDividerVisible,
                  onChanged: _onLastRowDividerVisible,
                  text: 'Last row divider visible'),
              const Text('Row theme color'),
              IntrinsicWidth(
                  child: ListTile(
                      title: const Text('None'),
                      leading: Radio<RowThemeColor>(
                          value: RowThemeColor.none,
                          groupValue: _demoBackground,
                          onChanged: _onBackgroundChanged))),
              IntrinsicWidth(
                  child: ListTile(
                      title: const Text('Simple'),
                      leading: Radio<RowThemeColor>(
                          value: RowThemeColor.simple,
                          groupValue: _demoBackground,
                          onChanged: _onBackgroundChanged))),
              IntrinsicWidth(
                  child: ListTile(
                      title: const Text('Zebra'),
                      leading: Radio<RowThemeColor>(
                          value: RowThemeColor.zebra,
                          groupValue: _demoBackground,
                          onChanged: _onBackgroundChanged)))
            ]),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0)));
  }

  void _onColumnDividerFillHeight() {
    setState(() {
      _columnDividerFillHeight = !_columnDividerFillHeight;
    });
  }

  void _onHeaderVisible() {
    setState(() {
      _headerVisible = !_headerVisible;
    });
  }

  void _onBackgroundChanged(RowThemeColor? value) {
    if (value != null) {
      setState(() {
        _demoBackground = value;
      });
    }
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

  void _onLastRowDividerVisible() {
    setState(() {
      _lastRowDividerVisible = !_lastRowDividerVisible;
    });
  }

  void _onRowColor() {
    setState(() {
      _rowColor = !_rowColor;
    });
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

  void _onLastRowWidget(bool visible) {
    print('last row widget visible: $visible');
  }

  void _onLastRowWidgetSwitch() {
    setState(() {
      _lastRowWidget = !_lastRowWidget;
    });
  }

  void _onNullValueColor() {
    setState(() {
      _nullValueColor = !_nullValueColor;
    });
  }
}

enum RowThemeColor { none, zebra, simple }
