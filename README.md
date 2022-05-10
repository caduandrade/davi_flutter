[![](https://img.shields.io/pub/v/easy_table.svg)](https://pub.dev/packages/easy_table) [![](https://img.shields.io/badge/demo-try%20it%20out-blue)](https://caduandrade.github.io/easy_table_flutter_demo/) [![](https://img.shields.io/badge/Flutter-%E2%9D%A4-red)](https://flutter.dev/) [![](https://img.shields.io/badge/donate-crypto-green)](#support-this-project)

# Easy Table

![](https://caduandrade.github.io/easy_table_flutter/easy_table_v3.png)

* Ready for a large number of data. Building cells on demand.
* Focused on Web/Desktop Applications.
* Bidirectional scroll bars (always visible).
* Sortable.
* Resizable.
* Highly customized.
* Pinned columns.

## Usage

* [Get started](#get-started)
* [Columns fit](#columns-fit)
* [Custom cell](#custom-cell)
* [Row callbacks](#row-callbacks)
* Null values
  * [Cell color](#cell-color)
* [Pinned column](#pinned-column)
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

![](https://caduandrade.github.io/easy_table_flutter/get_started_v2.png)

## Columns fit

```dart
  _model = EasyTableModel<Person>(rows: [
    Person('Landon', 19),
    Person('Sari', 22),
    Person('Julian', 37),
    Person('Carey', 39),
    Person('Cadu', 43),
    Person('Delmar', 72)
  ], columns: [
    EasyTableColumn(name: 'Name', weight: 5, stringValue: (row) => row.name),
    EasyTableColumn(name: 'Age', weight: 1, intValue: (row) => row.age)
  ]);
```

```dart
  EasyTable<Person>(_model, columnsFit: true);
```

![](https://caduandrade.github.io/easy_table_flutter/columns_fit_v2.png)

## Custom cell

```dart
_model = EasyTableModel<Person>(rows: rows, columns: [
  EasyTableColumn(name: 'Name', stringValue: (row) => row.name),
  EasyTableColumn(
      name: 'Rate',
      width: 150,
      cellBuilder: (context, row) => StarsWidget(stars: row.stars))
]);
```

![](https://caduandrade.github.io/easy_table_flutter/custom_cell_v3.png)

## Row callbacks

```dart
@override
Widget build(BuildContext context) {
  return EasyTable<Person>(_model,
      onRowTap: (person) => _onRowTap(context, person),
      onRowDoubleTap: (person) => _onRowDoubleTap(context, person));
}

void _onRowTap(BuildContext context, Person person) {
  ...
}

void _onRowDoubleTap(BuildContext context, Person person) {
  ...
}
```

## Null values

### Cell color

```dart
  _model = EasyTableModel<Person>(rows: [
    Person('Landon', '+321 321-432-543'),
    Person('Sari', '+123 456-789-012'),
    Person('Julian', null),
    Person('Carey', '+111 222-333-444'),
    Person('Cadu', null),
    Person('Delmar', '+22 222-222-222')
  ], columns: [
    EasyTableColumn(name: 'Name', width: 120, stringValue: (row) => row.name),
    EasyTableColumn(
        name: 'Mobile', width: 150, stringValue: (row) => row.mobile)
  ]);
```

```dart
  EasyTableTheme(
      child: EasyTable<Person>(_model),
      data: EasyTableThemeData(
          cell:
              CellThemeData(nullValueColor: ((rowIndex) => Colors.grey[300]))));
```

![](https://caduandrade.github.io/easy_table_flutter/null_cell_color_v2.png)

## Pinned column

```dart
    _model = EasyTableModel(rows: persons, columns: [
      EasyTableColumn(
          pinned: true,
          width: 30,
          cellBuilder: (BuildContext context, Person row) {
            return InkWell(
                child: const Icon(Icons.edit, size: 16),
                onTap: () => _onEdit(row));
          }),
      EasyTableColumn(name: 'Name', width: 120, stringValue: (row) => row.name),
      EasyTableColumn(name: 'Age', width: 120, intValue: (row) => row.age)
    ]);
```

![](https://caduandrade.github.io/easy_table_flutter/pinned_column_v2.png)

## TODO

* Collapsed rows
* Header grouping
* Row selection
* Custom headers
* Cell edition
* Column reorder
* Pinned column on right?
* Filter
* More theming options
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