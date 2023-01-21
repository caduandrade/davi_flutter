[![](https://img.shields.io/pub/v/davi.svg)](https://pub.dev/packages/davi)
![](https://github.com/caduandrade/davi_flutter/actions/workflows/test.yml/badge.svg)
[![](https://img.shields.io/badge/demo-try%20it%20out-blue)](https://caduandrade.github.io/davi_flutter_demo/)
[![](https://img.shields.io/badge/Flutter-%E2%9D%A4-red)](https://flutter.dev/)
![](https://img.shields.io/badge/%F0%9F%91%8D%20and%20%E2%AD%90-are%20free%20and%20motivate%20me-yellow)

![](https://caduandrade.github.io/davi_flutter/davi_logo_v1.png)
---
![](https://caduandrade.github.io/davi_flutter/easy_table_v5.png)

* Ready for a large number of data. Building cells on demand.
* Focused on Web/Desktop Applications.
* Bidirectional scroll bars.
* Resizable.
* Highly customized.
* Pinned columns.
* Multiple sortable.
* Infinite scroll.

## Usage

* [Get started](#get-started)
* Model
  * Column
    * [Columns fit](#columns-fit)
    * [Stretchable column](#stretchable-column)
    * [Multiple sort](#multiple-sort)
    * [Column style](#column-style)
    * [Pinned column](#pinned-column)
  * Row
    * [Row color](#row-color)
    * [Row cursor](#row-cursor)
    * [Row callbacks](#row-callbacks)
    * [Row hover listener](#row-hover-listener)
    * [Infinite scroll](#infinite-scroll)
  * Cell
    * [Cell style](#cell-style)
    * [Custom cell widget](#custom-cell-widget)
    * [Cell edit](#cell-edit)
  * [Sort callback](#sort-callback)
  * [Server-side sorting](#server-side-sorting)
* Theme
  * [Dividers thickness and color](#dividers-thickness-and-color) 
  * [Header](#header)
    * [Hidden header](#hidden-header)  
  * Row
    * [Row color](#theme-row-color) 
    * [Row zebra color](#row-zebra-color)
    * [Row hover background](#row-hover-background)
    * [Row hover foreground](#row-hover-foreground)
    * [Row fill height](#row-fill-height)
  * [Scrollbar](#scrollbar)
    * [Scrollbar always visible](#scrollbar-always-visible) 
  * Cell
    * [Null value color](#null-value-color)
* [Support this project](#support-this-project)

## Get started

```dart
  DaviModel<Person>? _model;

  @override
  void initState() {
    super.initState();

    _model = DaviModel<Person>(rows: [
      Person('Landon', 19),
      Person('Sari', 22),
      Person('Julian', 37),
      Person('Carey', 39),
      Person('Cadu', 43),
      Person('Delmar', 72)
    ], columns: [
      DaviColumn(name: 'Name', stringValue: (row) => row.name),
      DaviColumn(name: 'Age', intValue: (row) => row.age)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Davi<Person>(_model);
  }
```

![](https://caduandrade.github.io/davi_flutter/get_started_v5.png)

## Model

### Column

#### Columns fit

All columns will fit in the available width.

```dart
    _model = DaviModel<Person>(rows: rows, columns: [
      DaviColumn(name: 'Name', grow: 2, stringValue: (row) => row.name),
      DaviColumn(name: 'Age', grow: 1, intValue: (row) => row.age)
    ]);
```

```dart
    Davi<Person>(_model, columnWidthBehavior: ColumnWidthBehavior.fit);
```

![](https://caduandrade.github.io/davi_flutter/columns_fit_v4.png)

#### Stretchable column

The remaining width will be distributed to the columns according to the value of the `grow` attribute.

```dart
    _model = DaviModel<Person>(rows: rows, columns: [
      DaviColumn(name: 'Name', grow: 1, stringValue: (row) => row.name),
      DaviColumn(name: 'Age', intValue: (row) => row.age)
    ]);
```

```dart
  Davi<Person>(_model);
```

![](https://caduandrade.github.io/davi_flutter/stretchable_column_v1.png)

#### Multiple sort

```dart
  Davi(_model, multiSort: true);
```

![](https://caduandrade.github.io/davi_flutter/multiple_sort_v1.png)

#### Column style

```dart
    _model = DaviModel<Person>(rows: rows, columns: [
      DaviColumn(name: 'Name', stringValue: (row) => row.name),
      DaviColumn(
          name: 'Age',
          intValue: (row) => row.age,
          headerTextStyle: TextStyle(color: Colors.blue[900]!),
          headerAlignment: Alignment.center,
          cellAlignment: Alignment.center,
          cellTextStyle: TextStyle(color: Colors.blue[700]!),
          cellBackground: (data) => Colors.blue[50])
    ]);
```

![](https://caduandrade.github.io/davi_flutter/column_style_v2.png)

#### Pinned column

```dart
    _model = DaviModel(rows: persons, columns: [
      DaviColumn(
          pinStatus: PinStatus.left,
          width: 30,
          cellBuilder: (BuildContext context, DaviRow<Person> row) {
            return InkWell(
                child: const Icon(Icons.edit, size: 16),
                onTap: () => _onEdit(row.data));
          }),
      DaviColumn(name: 'Name', stringValue: (row) => row.name),
      DaviColumn(name: 'Age', intValue: (row) => row.age)
    ]);
```

![](https://caduandrade.github.io/davi_flutter/pinned_column_v4.png)

### Row

#### Row color

```dart
    _model = DaviModel<Person>(rows: rows, columns: [
      DaviColumn(name: 'Name', stringValue: (row) => row.name),
      DaviColumn(name: 'Age', intValue: (row) => row.age)
    ]);
```

```dart
  @override
  Widget build(BuildContext context) {
    return Davi<Person>(_model, rowColor: _rowColor);
  }

  Color? _rowColor(DaviRow<Person> row) {
    if (row.data.age < 20) {
      return Colors.green[50]!;
    } else if (row.data.age > 30 && row.data.age < 50) {
      return Colors.orange[50]!;
    }
    return null;
  }
```

![](https://caduandrade.github.io/davi_flutter/row_color_v1.png)

#### Row cursor

```dart
    DaviTheme(
        child: Davi<Person>(_model,
            rowCursor: (row) =>
                row.data.age < 20 ? SystemMouseCursors.forbidden : null),
        data: const DaviThemeData(
            row: RowThemeData(cursorOnTapGesturesOnly: false)));
```

#### Row callbacks

```dart
@override
Widget build(BuildContext context) {
  return Davi<Person>(_model,
      onRowTap: (person) => _onRowTap(context, person),
      onRowSecondaryTap: (person) => _onRowSecondaryTap(context, person),
      onRowDoubleTap: (person) => _onRowDoubleTap(context, person));
}

void _onRowTap(BuildContext context, Person person) {
  ...
}

void _onRowSecondaryTap(BuildContext context, Person person) {
  ...
}

void _onRowDoubleTap(BuildContext context, Person person) {
  ...
}
```

#### Row hover listener

```dart
  Davi<Person>(_model, onHover: _onHover);

  void _onHover(int? rowIndex) {
    ...
  }
```

#### Infinite scroll

```dart
  DaviModel<Value>? _model;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    List<Value> rows = List.generate(30, (index) => Value(index));
    _model = DaviModel<Value>(rows: rows, columns: [
      DaviColumn(name: 'Index', intValue: (row) => row.index),
      DaviColumn(name: 'Random 1', stringValue: (row) => row.random1),
      DaviColumn(name: 'Random 2', stringValue: (row) => row.random2)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Davi<Value>(_model,
        lastRowWidget: const LoadingWidget(),
        onLastRowWidget: _onLastRowWidget);
  }

  void _onLastRowWidget(bool visible) {
    if (visible && !_loading) {
      setState(() {
        _loading = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _loading = false;
          List<Value> newValues =
              List.generate(15, (index) => Value(_model!.rowsLength + index));
          _model!.addRows(newValues);
        });
      });
    }
  }
```

![](https://caduandrade.github.io/davi_flutter/infinite_scroll_v3.gif)

### Cell

#### Cell style

```dart
    _model = DaviModel<Person>(rows: rows, columns: [
      DaviColumn(name: 'Name', stringValue: (row) => row.name),
      DaviColumn(
          name: 'Age',
          intValue: (row) => row.age,
          cellStyleBuilder: (row) => row.data.age >= 30 && row.data.age < 40
              ? CellStyle(
                  background: Colors.blue[800],
                  alignment: Alignment.center,
                  textStyle: const TextStyle(color: Colors.white))
              : null)
    ]);
```

![](https://caduandrade.github.io/davi_flutter/cell_style_v1.png)

#### Custom cell widget

```dart
    _model = DaviModel<Person>(rows: rows, columns: [
      DaviColumn(name: 'Name', stringValue: (row) => row.name),
      DaviColumn(
          name: 'Rate',
          width: 150,
          cellBuilder: (context, row) => StarsWidget(stars: row.data.stars))
    ]);
```

![](https://caduandrade.github.io/davi_flutter/custom_cell_widget_v2.png)

#### Cell edit

```dart
class Person {
  Person(this.name, this.value);

  final String name;
  final int value;

  bool _valid = true;

  bool get valid => _valid;

  String _editable = '';

  String get editable => _editable;

  set editable(String value) {
    _editable = value;
    _valid = _editable.length < 6;
  }
}

class MainWidgetState extends State<MainWidget> {
  DaviModel<Person>? _model;

  @override
  void initState() {
    super.initState();
    List<Person> rows = [
      Person('Landon', 1),
      Person('Sari', 0),
      Person('Julian', 2),
      Person('Carey', 4),
      Person('Cadu', 5),
      Person('Delmar', 2)
    ];
    _model = DaviModel<Person>(rows: rows, columns: [
      DaviColumn(name: 'Name', stringValue: (row) => row.name),
      DaviColumn(name: 'Value', intValue: (row) => row.value),
      DaviColumn(
          name: 'Editable',
          cellBuilder: _buildField,
          cellBackground: (row) => row.data.valid ? null : Colors.red[800])
    ]);
  }

  Widget _buildField(BuildContext context, DaviRow<Person> row) {
    return TextFormField(
        initialValue: row.data.editable,
        style: TextStyle(color: row.data.valid ? Colors.black : Colors.white),
        onChanged: (value) => _onFieldChange(value, row.data));
  }

  void _onFieldChange(String value, Person person) {
    final wasValid = person.valid;
    person.editable = value;
    if (wasValid != person.valid) {
      setState(() {
        // rebuild
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Davi<Person>(_model);
  }
}
```

### Sort callback

```dart
    _model = DaviModel<Person>(
        rows: rows,
        columns: [
          DaviColumn(name: 'Name', stringValue: (row) => row.name),
          DaviColumn(name: 'Age', intValue: (row) => row.age)
        ],
        onSort: _onSort);
```

```dart
  void _onSort(List<DaviColumn<Person>> sortedColumns) {
    ...
  }
```

### Server-side sorting

Ignoring sorting functions from the model.
Simulating the server-side sorting when loading data.

```dart
class Person {
  Person(this.name, this.age);

  final String name;
  final int age;
}

enum ColumnId { name, age }

class MainWidgetState extends State<MainWidget> {
  late DaviModel<Person> _model;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _model = DaviModel<Person>(columns: [
      DaviColumn(
          id: ColumnId.name, name: 'Name', stringValue: (row) => row.name),
      DaviColumn(id: ColumnId.age, name: 'Age', intValue: (row) => row.age)
    ], onSort: _onSort, ignoreSort: true);
    loadData(null);
  }

  void loadData(DaviColumn<Person>? column) {
    Future<List<Person>>.delayed(const Duration(seconds: 2), () {
      List<Person> rows = [
        Person('Linda', 33),
        Person('Pamela', 22),
        Person('Steven', 21),
        Person('James', 37),
        Person('Amanda', 43),
        Person('Cadu', 35)
      ];
      if (column != null) {
        final TableSortOrder order = column.order!;
        rows.sort((a, b) {
          switch (column.id) {
            case ColumnId.name:
              return order == TableSortOrder.ascending
                  ? a.name.compareTo(b.name)
                  : b.name.compareTo(a.name);
            case ColumnId.age:
              return order == TableSortOrder.ascending
                  ? a.age.compareTo(b.age)
                  : b.age.compareTo(a.age);
          }
          return 0;
        });
      }
      return rows;
    }).then((list) {
      setState(() {
        _loading = false;
        _model.replaceRows(list);
      });
    });
  }

  void _onSort(List<DaviColumn<Person>> sortedColumns) {
    setState(() {
      _loading = true;
      _model.removeRows();
    });
    final DaviColumn<Person>? column =
        sortedColumns.isNotEmpty ? sortedColumns.first : null;
    loadData(column);
  }

  @override
  Widget build(BuildContext context) {
    return Davi(_model,
        tapToSortEnabled: !_loading,
        lastRowWidget:
            _loading ? const Center(child: Text('Loading...')) : null);
  }
}
```

## Theme

### Dividers thickness and color

```dart
    DaviTheme(
        child: Davi<Person>(_model),
        data: const DaviThemeData(
            columnDividerThickness: 4,
            columnDividerColor: Colors.blue,
            header: HeaderThemeData(columnDividerColor: Colors.purple),
            row: RowThemeData(dividerThickness: 4, dividerColor: Colors.green),
            scrollbar:
                TableScrollbarThemeData(columnDividerColor: Colors.orange)));
```

![](https://caduandrade.github.io/davi_flutter/theme_divider_v3.png)

### Header

```dart
    DaviTheme(
        child: Davi<Person>(_model),
        data: DaviThemeData(
            header: HeaderThemeData(
                color: Colors.green[50],
                bottomBorderHeight: 4,
                bottomBorderColor: Colors.blue),
            headerCell: HeaderCellThemeData(
                height: 40,
                alignment: Alignment.center,
                textStyle: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
                resizeAreaWidth: 10,
                resizeAreaHoverColor: Colors.blue.withOpacity(.5),
                sortIconColor: Colors.green,
                expandableName: false)));
```

![](https://caduandrade.github.io/davi_flutter/header_v1.png)

#### Hidden header

```dart
    DaviTheme(
        child: Davi<Person>(_model),
        data: const DaviThemeData(header: HeaderThemeData(visible: false)));
```

![](https://caduandrade.github.io/davi_flutter/hidden_header_v1.png)

### Row

#### Theme Row color

```dart
    DaviTheme(
        data: DaviThemeData(
            row: RowThemeData(color: (rowIndex) => Colors.green[50])),
        child: Davi<Person>(_model));
```

![](https://caduandrade.github.io/davi_flutter/theme_row_color_v1.png)

#### Row zebra color

```dart
    DaviTheme(
        data:
            DaviThemeData(row: RowThemeData(color: RowThemeData.zebraColor())),
        child: Davi<Person>(_model));
```

![](https://caduandrade.github.io/davi_flutter/theme_row_zebra_color_v1.png)

#### Row hover background

```dart
    DaviTheme(
        data: DaviThemeData(
            row: RowThemeData(hoverBackground: (rowIndex) => Colors.blue[50])),
        child: Davi<Person>(_model));
```

![](https://caduandrade.github.io/davi_flutter/theme_row_hover_background_v1.png)

#### Row hover foreground

```dart
    DaviTheme(
        data: DaviThemeData(
            row: RowThemeData(
                hoverForeground: (rowIndex) => Colors.blue.withOpacity(.2))),
        child: Davi<Person>(_model));
```

![](https://caduandrade.github.io/davi_flutter/theme_row_hover_foreground_v1.png)

#### Row fill height

```dart
    DaviTheme(
        data: DaviThemeData(
            row: RowThemeData(
                fillHeight: true, color: RowThemeData.zebraColor())),
        child: Davi<Person>(_model));
```

![](https://caduandrade.github.io/davi_flutter/theme_roll_fill_height_v1.png)

### Scrollbar

```dart
    DaviTheme(
        child: Davi<Person>(_model),
        data: const DaviThemeData(
            scrollbar: TableScrollbarThemeData(
                thickness: 16,
                thumbColor: Colors.black,
                pinnedHorizontalColor: Colors.yellow,
                unpinnedHorizontalColor: Colors.green,
                verticalColor: Colors.blue,
                borderThickness: 8,
                pinnedHorizontalBorderColor: Colors.orange,
                unpinnedHorizontalBorderColor: Colors.purple,
                verticalBorderColor: Colors.pink)));
```

![](https://caduandrade.github.io/davi_flutter/theme_scrollbar_v1.png)

#### Scrollbar always visible

```dart
    return DaviTheme(
        data: const DaviThemeData(
            scrollbar: TableScrollbarThemeData(
                horizontalOnlyWhenNeeded: false,
                verticalOnlyWhenNeeded: false)),
        child: Davi<Person>(_model));
```

![](https://caduandrade.github.io/davi_flutter/scrollbar_always_visible_v1.png)

> A warning is being displayed in the console due to a bug in Flutter: https://github.com/flutter/flutter/issues/103939.
> The error happens when the horizontal scrollbar is hidden after being visible.
> The PR (https://github.com/flutter/flutter/pull/103948) fix it. 

### Cell

#### Null value color

```dart
    _model = DaviModel<Person>(rows: [
      Person('Landon', '+321 321-432-543'),
      Person('Sari', '+123 456-789-012'),
      Person('Julian', null),
      Person('Carey', '+111 222-333-444'),
      Person('Cadu', null),
      Person('Delmar', '+22 222-222-222')
    ], columns: [
      DaviColumn(name: 'Name', stringValue: (row) => row.name),
      DaviColumn(name: 'Mobile', width: 150, stringValue: (row) => row.mobile)
    ]);
```

```dart
    DaviTheme(
        child: Davi<Person>(_model),
        data: DaviThemeData(
            cell: CellThemeData(
                nullValueColor: ((rowIndex, hovered) => Colors.grey[300]))));
```

![](https://caduandrade.github.io/davi_flutter/null_cell_color_v3.png)

## TODO

* Collapsed rows
* Header grouping
* Row selection
* Column reorder
* Cell merge
* Pinned column on right
* Filter
* And everything else, the sky is the limit

## Support this project

### Bitcoin

[bc1qhqy84y45gya58gtfkvrvass38k4mcyqnav803h](https://www.blockchain.com/pt/btc/address/bc1qhqy84y45gya58gtfkvrvass38k4mcyqnav803h)

### Ethereum (ERC-20) or Binance Smart Chain (BEP-20)

[0x9eB815FD4c88A53322304143A9Aa8733D3369985](https://etherscan.io/address/0x9eb815fd4c88a53322304143a9aa8733d3369985)

### Solana

[7vp45LoQXtLYFXXKx8wQGnzYmhcnKo1TmfqUgMX45Ad8](https://explorer.solana.com/address/7vp45LoQXtLYFXXKx8wQGnzYmhcnKo1TmfqUgMX45Ad8)

### Helium

[13A2fDqoApT9VnoxFjHWcy8kPQgVFiVnzps32MRAdpTzvs3rq68](https://explorer.helium.com/accounts/13A2fDqoApT9VnoxFjHWcy8kPQgVFiVnzps32MRAdpTzvs3rq68)