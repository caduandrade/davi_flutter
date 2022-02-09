[![](https://img.shields.io/pub/v/easy_table.svg)](https://pub.dev/packages/easy_table) [![](https://img.shields.io/badge/demo-try%20it%20out-blue)](https://caduandrade.github.io/easy_table_flutter_demo/) [![](https://img.shields.io/badge/Flutter-%E2%9D%A4-red)](https://flutter.dev/) ![](https://img.shields.io/badge/final%20version-as%20soon%20as%20possible-blue)

# Easy Table

![](https://caduandrade.github.io/easy_table_flutter/easy_table_v1.png)

* Ready for a large number of data. Building cells on demand.
* Focused on Web/Desktop Applications.
* Bidirectional scroll bars (always visible).
* Highly customized.

## Usage

* [Get started](#get-started)

### Get started

```dart
List<Person>? _rows;

@override
void initState() {
  super.initState();
  _rows = [
    Person('Landon', 19),
    Person('Sari', 22),
    Person('Julian', 37),
    Person('Carey', 39),
    Person('Cadu', 43),
    Person('Delmar', 72)
  ];
}

@override
Widget build(BuildContext context) {
  return EasyTable<Person>(rows: _rows, columns: [
    EasyTableColumn.auto((row) => row.name, name: 'Name'),
    EasyTableColumn.auto((row) => row.age, name: 'Age')
  ]);
}
```

![](https://caduandrade.github.io/easy_table_flutter/get_started_v1.png)

## TODO

* Collapsed rows
* Header grouping
* Row selection
* Custom headers
* Cell edition
* Column reorder
* Column resize
* Pinned column
* Sort
* Theme
* And everything else, the sky is the limit
