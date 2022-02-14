[![](https://img.shields.io/pub/v/easy_table.svg)](https://pub.dev/packages/easy_table) [![](https://img.shields.io/badge/demo-try%20it%20out-blue)](https://caduandrade.github.io/easy_table_flutter_demo/) [![](https://img.shields.io/badge/Flutter-%E2%9D%A4-red)](https://flutter.dev/) ![](https://img.shields.io/badge/final%20version-as%20soon%20as%20possible-blue)

# Easy Table

![](https://caduandrade.github.io/easy_table_flutter/easy_table_v1.png)

* Ready for a large number of data. Building cells on demand.
* Focused on Web/Desktop Applications.
* Bidirectional scroll bars (always visible).
* Sortable.
* Resizable.
* Highly customized.

## Usage

* [Get started](#get-started)
* [Custom cell](#custom-cell)
* [Row callbacks](#row-callbacks)

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

![](https://caduandrade.github.io/easy_table_flutter/get_started_v1.png)

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

![](https://caduandrade.github.io/easy_table_flutter/custom_cell_v1.png)

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

## TODO

* Collapsed rows
* Header grouping
* Row selection
* Custom headers
* Cell edition
* Column reorder
* Pinned column
* Filter
* More theming options
* And everything else, the sky is the limit
