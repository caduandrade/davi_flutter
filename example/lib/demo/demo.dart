import 'package:davi/davi.dart';
import 'package:davi_example/demo/character.dart';
import 'package:davi_example/demo/demo_checkbox.dart';
import 'package:davi_example/demo/skills_widget.dart';
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
        title: 'Davi Demo',
        home: Scaffold(body: HomePage()));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DaviModel<Character>? _model;
  bool _headerVisible = HeaderThemeDataDefaults.visible;
  bool _fewRows = false;
  bool _leftPinned = false;
  bool _rowColor = false;
  bool _hoverBackground = false;
  bool _multipleSort = false;
  bool _hoverForeground = true;
  bool _rowFillHeight = RowThemeDataDefaults.fillHeight;
  bool _nullValueColor = true;
  bool _trailingWidget = false;
  bool _columnDividerFillHeight = DaviThemeDataDefaults.columnDividerFillHeight;
  RowThemeColor _demoBackground = RowThemeColor.none;
  bool _columnsWithIcon = false;
  bool _customDividerThickness = false;

  @override
  void initState() {
    super.initState();
    _buildModel().then((model) {
      setState(() {
        _model = model;
      });
    });
  }

  Future<DaviModel<Character>> _buildModel() async {
    List<Character> characters = await Character.loadCharacters();
    if (_fewRows) {
      characters = characters.sublist(0, 5);
    }
    return DaviModel(
        rows: characters,
        columns: _buildColumns(),
        multiSortEnabled: _multipleSort);
  }

  List<DaviColumn<Character>> _buildColumns() {
    List<DaviColumn<Character>> list = [];
    list.add(DaviColumn(
        pinStatus: _leftPinned ? PinStatus.left : PinStatus.none,
        leading: const Icon(Icons.person, size: 16),
        name: 'Name',
        width: 100,
        stringValue: (row) => row.name));
    if (_columnsWithIcon) {
      list.add(DaviColumn(
          //pinStatus: _leftPinned ? PinStatus.left : PinStatus.none,
          name: 'Gender',
          width: 80,
          cellClip: true,
          iconValue: (row) => row.male
              ? CellIcon(icon: Icons.male, color: Colors.blue[700]!)
              : CellIcon(icon: Icons.female, color: Colors.pink[600]!)));
    }
    list.add(
        DaviColumn(name: 'Race', width: 100, stringValue: (row) => row.race));
    list.add(
        DaviColumn(name: 'Class', width: 110, stringValue: (row) => row.cls));
    list.add(
        DaviColumn(name: 'Level', width: 70, intValue: (row) => row.level));
    if (_columnsWithIcon) {
      list.add(DaviColumn(
          name: 'Skills',
          width: 100,
          cellClip: true,
          cellBuilder: (context, data, index, hovered) =>
              SkillsWidget(skills: data.skills)));
    }
    list.add(DaviColumn(
        name: 'Strength', width: 80, intValue: (row) => row.strength));
    list.add(DaviColumn(
        name: 'Dexterity', width: 80, intValue: (row) => row.dexterity));
    list.add(DaviColumn(
        name: 'Intelligence', width: 90, intValue: (row) => row.intelligence));
    list.add(DaviColumn(name: 'Life', width: 70, intValue: (row) => row.life));
    list.add(DaviColumn(name: 'Mana', width: 70, intValue: (row) => row.mana));
    list.add(DaviColumn(
        name: 'Gold',
        width: 110,
        doubleValue: (row) => row.gold, //row.gold,
        fractionDigits: 2));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_model == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget table = DaviTheme(
        child: Davi<Character>(_model!,
            rowColor: _rowColor
                ? (data, rowIndex, hovered) =>
                    data.life < 1000 ? Colors.red[200] : null
                : null,
            trailingWidget: _trailingWidget
                ? const Center(child: Text('TRAILING WIDGET'))
                : null),
        data: DaviThemeData(
            columnDividerFillHeight: _columnDividerFillHeight,
            header: HeaderThemeData(visible: _headerVisible),
            cell: CellThemeData(
                nullValueColor: _nullValueColor
                    ? (index, hovered) => Colors.grey[400]
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
        dividerThickness: _customDividerThickness
            ? 10
            : RowThemeDataDefaults.dividerThickness,
        dividerColor: _customDividerThickness
            ? Colors.blue[200]
            : RowThemeDataDefaults.dividerColor,
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
                  value: _multipleSort,
                  onChanged: _onMultipleSortSwitch,
                  text: 'Multiple sort'),
              CheckboxUtil.build(
                  value: _columnsWithIcon,
                  onChanged: _onColumnsWithIcon,
                  text: 'Columns with icons widget'),
              CheckboxUtil.build(
                  value: _headerVisible,
                  onChanged: _onHeaderVisible,
                  text: 'Header visible'),
              CheckboxUtil.build(
                  value: _leftPinned,
                  onChanged: _onLeftPinned,
                  text: 'Left pinned'),
              CheckboxUtil.build(
                  value: _trailingWidget,
                  onChanged: _onTrailingWidgetSwitch,
                  text: 'Trailing widget'),
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
                  value: _customDividerThickness,
                  onChanged: _onCustomDividerThickness,
                  text: 'Custom divider thickness'),
              CheckboxUtil.build(
                  value: _rowColor, onChanged: _onRowColor, text: 'Row color'),
              const Text('Row theme color'),
              RadioButton<RowThemeColor>(
                  text: 'None',
                  value: RowThemeColor.none,
                  groupValue: _demoBackground,
                  onChanged: _onBackgroundChanged),
              RadioButton<RowThemeColor>(
                  text: 'Simple',
                  value: RowThemeColor.simple,
                  groupValue: _demoBackground,
                  onChanged: _onBackgroundChanged),
              RadioButton<RowThemeColor>(
                  text: 'Zebra',
                  value: RowThemeColor.zebra,
                  groupValue: _demoBackground,
                  onChanged: _onBackgroundChanged)
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

  void _onTrailingWidgetSwitch() {
    setState(() {
      _trailingWidget = !_trailingWidget;
    });
  }

  void _onMultipleSortSwitch() {
    setState(() {
      _multipleSort = !_multipleSort;
      _buildModel().then((model) {
        setState(() {
          _model = model;
        });
      });
    });
  }

  void _onNullValueColor() {
    setState(() {
      _nullValueColor = !_nullValueColor;
    });
  }

  void _onColumnsWithIcon() {
    setState(() {
      _columnsWithIcon = !_columnsWithIcon;
      _buildModel().then((model) {
        setState(() {
          _model = model;
        });
      });
    });
  }

  void _onCustomDividerThickness() {
    setState(() {
      _customDividerThickness = !_customDividerThickness;
    });
  }
}

enum RowThemeColor { none, zebra, simple }

class RadioButton<T> extends StatelessWidget {
  final String text;
  final ValueChanged<T?>? onChanged;
  final T? groupValue;
  final T value;

  const RadioButton(
      {required this.text,
      required this.value,
      required this.onChanged,
      required this.groupValue,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
        child: Row(children: [
      Radio<T>(value: value, onChanged: onChanged, groupValue: groupValue),
      Text(text)
    ]));
  }
}
