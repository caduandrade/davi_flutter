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
  bool _columnsFit = false;
  bool _rowColor = false;
  bool _growColumns = false;
  bool _hoverBackground = false;
  bool _multipleSort = false;
  bool _hoverForeground = true;
  bool _rowFillHeight = RowThemeDataDefaults.fillHeight;
  bool _nullValueColor = true;
  bool _trailingWidget = false;
  bool _columnDividerFillHeight = DaviThemeDataDefaults.columnDividerFillHeight;
  RowThemeColor _demoBackground = RowThemeColor.none;
  bool _columnsWithCustomWidget = false;
  bool _customDividerThickness = false;
  bool _summaryEnabled = false;

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
        rowSpan: (params) => params.rowIndex == _model!.rowsLength - 2 ? 2 : 1,
        cellValue: (params) => params.data.name));
    list.add(DaviColumn(
        pinStatus: _leftPinned ? PinStatus.left : PinStatus.none,
        name: 'Gender',
        width: 80,
        cellClip: true,
        cellIcon: (params) => params.data.male
            ? CellIcon(Icons.male, color: Colors.blue[700]!)
            : CellIcon(Icons.female, color: Colors.pink[600]!)));
    list.add(DaviColumn(
        name: 'Race', width: 100, cellValue: (params) => params.data.race));
    list.add(DaviColumn(
        name: 'Class', width: 110, cellValue: (params) => params.data.cls));
    list.add(DaviColumn(
        name: 'Level', width: 70, cellValue: (params) => params.data.level));
    if (_columnsWithCustomWidget) {
      list.add(DaviColumn(
          name: 'Skills',
          width: 100,
          cellClip: true,
          cellWidget: (params) => SkillsWidget(skills: params.data.skills)));
    }
    if (_growColumns) {
      list.add(DaviColumn(
          name: 'Grow 1',
          grow: 1,
          width: 80,
          cellValue: (params) => params.data.strength));
    }
    list.add(DaviColumn(
        name: 'Strength',
        width: 80,
        cellValue: (params) => params.data.strength));
    list.add(DaviColumn(
        name: 'Dexterity',
        width: 80,
        cellValue: (params) => params.data.dexterity,
        summary: _summaryEnabled ? (context) => const Text('summary') : null));
    list.add(DaviColumn(
        name: 'Intelligence',
        width: 90,
        cellValue: (params) => params.data.intelligence));
    if (_growColumns) {
      list.add(DaviColumn(
          name: 'Grow2',
          grow: 2,
          width: 80,
          cellValue: (params) => params.data.dexterity));
    }
    list.add(DaviColumn(
        name: 'Life', width: 70, cellValue: (params) => params.data.life));
    list.add(DaviColumn(
        name: 'Mana', width: 70, cellValue: (params) => params.data.mana));
    list.add(DaviColumn(
        name: 'Gold',
        width: 110,
        cellValue: (params) => params.data.gold,
        cellValueStringify: (value) => (value as double).toStringAsFixed(2)));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_model == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget table = DaviTheme(
        child: Davi<Character>(_model!,
            columnWidthBehavior: _columnsFit
                ? ColumnWidthBehavior.fit
                : ColumnWidthBehavior.scrollable,
            rowColor: _rowColor
                ? (params) => params.data.life < 1000 ? Colors.red[200] : null
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
        hoverForeground: _hoverForeground
            ? (index) => Colors.black.withValues(alpha: .1)
            : null);
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
                  value: _columnsWithCustomWidget,
                  onChanged: _onColumnsWithCustomWidget,
                  text: 'Columns with custom widget'),
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
                  value: _summaryEnabled,
                  onChanged: _onSummaryEnabled,
                  text: 'Summary'),
              CheckboxUtil.build(
                  value: _columnsFit,
                  onChanged: _onColumnsFit,
                  text: 'Columns fit'),
              CheckboxUtil.build(
                  value: _growColumns,
                  onChanged: _onGrowColumns,
                  text: 'Grow columns'),
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

  void _onGrowColumns() {
    setState(() {
      _growColumns = !_growColumns;
      _model?.removeColumns();
      _model?.addColumns(_buildColumns());
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

  void _onSummaryEnabled() {
    setState(() {
      _summaryEnabled = !_summaryEnabled;
      _model?.removeColumns();
      _model?.addColumns(_buildColumns());
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

  void _onColumnsWithCustomWidget() {
    setState(() {
      _columnsWithCustomWidget = !_columnsWithCustomWidget;
      _buildModel().then((model) {
        setState(() {
          _model = model;
        });
      });
    });
  }

  void _onColumnsFit() {
    setState(() {
      _columnsFit = !_columnsFit;
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
