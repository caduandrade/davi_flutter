[![](https://img.shields.io/pub/v/easy_table.svg)](https://pub.dev/packages/easy_table) [![](https://img.shields.io/badge/demo-try%20it%20out-blue)](https://caduandrade.github.io/easy_table_flutter_demo/) [![](https://img.shields.io/badge/Flutter-%E2%9D%A4-red)](https://flutter.dev/) [![](https://img.shields.io/badge/donate-crypto-green)](#support-this-project) ![](https://img.shields.io/badge/%F0%9F%91%8D%20and%20%E2%AD%90-are%20free-yellow)

# Easy Table

![](https://caduandrade.github.io/easy_table_flutter/easy_table_v5.png)

* Ready for a large number of data. Building cells on demand.
* Focused on Web/Desktop Applications.
* Bidirectional scroll bars.
* Resizable.
* Highly customized.
* Pinned columns.
* Multiple sortable.

## Usage

* [Get started](#get-started)
* [Columns fit](#columns-fit)
* [Multiple sort](#multiple-sort)
* [Column style](#column-style)
* [Cell style](#cell-style)
* [Custom cell widget](#custom-cell-widget)
* [Pinned column](#pinned-column)
* Row
  * [Row callbacks](#row-callbacks)
  * [Row hover listener](#row-hover-listener)
  * [Infinite scroll](#infinite-scroll)
* Theme
  * [Dividers thickness and color](#dividers-thickness-and-color) 
  * [Header](#header)
  * Row
    * [Row color](#row-color) 
    * [Row zebra color](#row-zebra-color)
    * [Row hover background](#row-hover-background)
    * [Row hover foreground](#row-hover-foreground)
    * [Row fill height](#row-fill-height)
  * [Scrollbar](#scrollbar)
    * [Horizontal scrollbar only when needed](#horizontal-scrollbar-only-when-needed) 
  * Cell
    * [Null value color](#null-value-color)
* [Support this project](#support-this-project)

## Get started

```dart
EasyTableModel<Person>? _model;

@override
void initState() {
  super.initState();

  _model = EasyTableModel<Person>(rows: [
    Person('Landon', 19),
    Person('Sari', 22),
    Person('Julian', 37),
    Person('Carey', 39),
    Person('Cadu', 43),
    Person('Delmar', 72)
  ], columns: [
    EasyTableColumn(name: 'Name', stringValue: (row) => row.name),
    EasyTableColumn(name: 'Age', intValue: (row) => row.age)
  ]);
}

@override
Widget build(BuildContext context) {
  return EasyTable<Person>(_model);
}
```

![](https://caduandrade.github.io/easy_table_flutter/get_started_v4.png)

## Columns fit

```dart
    _model = EasyTableModel<Person>(rows: rows, columns: [
      EasyTableColumn(name: 'Name', weight: 5, stringValue: (row) => row.name),
      EasyTableColumn(name: 'Age', weight: 1, intValue: (row) => row.age)
    ]);
```

```dart
  EasyTable<Person>(_model, columnsFit: true);
```

![](https://caduandrade.github.io/easy_table_flutter/columns_fit_v3.png)

## Multiple sort

```dart
  EasyTable(_model, multiSortEnabled: true);
```

## Column style

```dart
    _model = EasyTableModel<Person>(rows: rows, columns: [
      EasyTableColumn(name: 'Name', stringValue: (row) => row.name),
      EasyTableColumn(
          name: 'Age',
          intValue: (row) => row.age,
          headerTextStyle: TextStyle(color: Colors.blue[900]!),
          headerAlignment: Alignment.center,
          cellAlignment: Alignment.center,
          cellTextStyle: TextStyle(color: Colors.blue[700]!),
          cellBackground: (data) => Colors.blue[50])
    ]);
```

![](https://caduandrade.github.io/easy_table_flutter/column_style_v1.png)

## Cell style

```dart
    _model = EasyTableModel<Person>(rows: rows, columns: [
      EasyTableColumn(name: 'Name', stringValue: (row) => row.name),
      EasyTableColumn(
          name: 'Age',
          intValue: (row) => row.age,
          cellStyleBuilder: (data) => data.row.age >= 30 && data.row.age < 40
              ? CellStyle(
                  background: Colors.blue[800],
                  alignment: Alignment.center,
                  textStyle: const TextStyle(color: Colors.white))
              : null)
    ]);
```

## Custom cell widget

```dart
    _model = EasyTableModel<Person>(rows: rows, columns: [
      EasyTableColumn(name: 'Name', stringValue: (row) => row.name),
      EasyTableColumn(
          name: 'Rate',
          width: 150,
          cellBuilder: (context, data) => StarsWidget(stars: data.row.stars))
    ]);
```

![](https://caduandrade.github.io/easy_table_flutter/custom_cell_widget_v1.png)

## Pinned column

```dart
    _model = EasyTableModel(rows: persons, columns: [
      EasyTableColumn(
          pinStatus: PinStatus.left,
          width: 30,
          cellBuilder: (BuildContext context, RowData<Person> data) {
            return InkWell(
                child: const Icon(Icons.edit, size: 16),
                onTap: () => _onEdit(data.row));
          }),
      EasyTableColumn(name: 'Name', stringValue: (row) => row.name),
      EasyTableColumn(name: 'Age', intValue: (row) => row.age)
    ]);
```

![](https://caduandrade.github.io/easy_table_flutter/pinned_column_v3.png)

## Row

### Row callbacks

```dart
@override
Widget build(BuildContext context) {
  return EasyTable<Person>(_model,
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

### Row hover listener

```dart
  EasyTable<Person>(_model, onHover: _onHover);

  void _onHover(int? rowIndex) {
    ...
  }
```

### Infinite scroll

```dart
  EasyTableModel<Value>? _model;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    List<Value> rows = List.generate(30, (index) => Value(index));
    _model = EasyTableModel<Value>(rows: rows, columns: [
      EasyTableColumn(name: 'Index', intValue: (row) => row.index),
      EasyTableColumn(name: 'Random 1', stringValue: (row) => row.random1),
      EasyTableColumn(name: 'Random 2', stringValue: (row) => row.random2)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return EasyTable<Value>(_model,
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
              List.generate(30, (index) => Value(_model!.rowsLength + index));
          _model!.addRows(newValues);
        });
      });
    }
  }
```

![](https://caduandrade.github.io/easy_table_flutter/infinite_scroll_v2.gif)

## Theme

### Dividers thickness and color

```dart
EasyTableTheme(
        child: EasyTable<Person>(_model),
        data: const EasyTableThemeData(
            columnDividerThickness: 4,
            columnDividerColor: Colors.blue,
            header: HeaderThemeData(columnDividerColor: Colors.purple),
            row: RowThemeData(dividerThickness: 4, dividerColor: Colors.green),
            scrollbar:
                TableScrollbarThemeData(columnDividerColor: Colors.orange)));
```

![](https://caduandrade.github.io/easy_table_flutter/theme_divider_v2.png)

### Header

```dart
EasyTableTheme(
        child: EasyTable<Person>(_model),
        data: EasyTableThemeData(
            header: const HeaderThemeData(
                bottomBorderHeight: 4, bottomBorderColor: Colors.blue),
            headerCell: HeaderCellThemeData(
                height: 40,
                alignment: Alignment.center,
                textStyle: const TextStyle(fontStyle: FontStyle.italic),
                resizeAreaWidth: 10,
                resizeAreaHoverColor: Colors.blue.withOpacity(.5),
                sortIconColor: Colors.green,
                expandableName: false)));
```

#### Hidden header

```dart
EasyTableTheme(
        child: EasyTable<Person>(_model),
        data:
            const EasyTableThemeData(header: HeaderThemeData(visible: false)));
```

### Row

#### Row color

```dart
EasyTableTheme(
        data: EasyTableThemeData(
            row: RowThemeData(color: (rowIndex) => Colors.green[50])),
        child: EasyTable<Person>(_model));
```

#### Row zebra color

```dart
EasyTableTheme(
        data: EasyTableThemeData(
            row: RowThemeData(color: RowThemeData.zebraColor())),
        child: EasyTable<Person>(_model));
```

#### Row hover background

```dart
EasyTableTheme(
        data: EasyTableThemeData(
            row: RowThemeData(hoverBackground: (rowIndex) => Colors.blue[50])),
        child: EasyTable<Person>(_model));
```

#### Row hover foreground

```dart
EasyTableTheme(
        data: EasyTableThemeData(
            row: RowThemeData(
                hoverForeground: (rowIndex) => Colors.blue.withOpacity(.2))),
        child: EasyTable<Person>(_model));
```

#### Row fill height

```dart
EasyTableTheme(
        data: EasyTableThemeData(
            row: RowThemeData(
                fillHeight: true, color: RowThemeData.zebraColor())),
        child: EasyTable<Person>(_model));
```

### Scrollbar

```dart
EasyTableTheme(
        child: EasyTable<Person>(_model),
        data:  const EasyTableThemeData(
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

#### Horizontal scrollbar only when needed

```dart
EasyTableTheme(
        child: EasyTable<Person>(_model),
        data: const EasyTableThemeData(
            scrollbar:
                TableScrollbarThemeData(horizontalOnlyWhenNeeded: true)));
```

![](https://caduandrade.github.io/easy_table_flutter/horizontal_scrollbar_when_needed_v1.png)

> A warning is being displayed in the console due to a bug in Flutter: https://github.com/flutter/flutter/issues/103939.
> The error happens when the horizontal scrollbar is hidden after being visible.
> The following MR should fix the issue: https://github.com/flutter/flutter/pull/103948

### Cell

#### Null value color

```dart
  _model = EasyTableModel<Person>(rows: [
    Person('Landon', '+321 321-432-543'),
    Person('Sari', '+123 456-789-012'),
    Person('Julian', null),
    Person('Carey', '+111 222-333-444'),
    Person('Cadu', null),
    Person('Delmar', '+22 222-222-222')
  ], columns: [
    EasyTableColumn(name: 'Name', stringValue: (row) => row.name),
    EasyTableColumn(
        name: 'Mobile', width: 150, stringValue: (row) => row.mobile)
  ]);
```

```dart
  EasyTableTheme(
        child: EasyTable<Person>(_model),
        data: EasyTableThemeData(
            cell: CellThemeData(
                nullValueColor: ((rowIndex, hovered) => Colors.grey[300]))));
```

![](https://caduandrade.github.io/easy_table_flutter/null_cell_color_v2.png)

## TODO

* Easiest way to create loading indicator for infinite scroll
* Collapsed rows
* Header grouping
* Row selection
* Cell edition?
* Column reorder
* Pinned column on right?
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