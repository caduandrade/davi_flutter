[![](https://img.shields.io/pub/v/davi.svg)](https://pub.dev/packages/davi)
[![](https://img.shields.io/badge/Flutter-%E2%9D%A4-red)](https://flutter.dev/)
[![](https://img.shields.io/badge/%F0%9F%91%8D%20and%20%E2%AD%90-are%20free%20and%20motivate%20me-yellow)](#)

![](https://caduandrade.github.io/davi_flutter/davi_logo_v1.png)

* Ready for a large number of data. High performance. Building cells on demand.
* Focused on Web/Desktop Applications.
* Model mode, where the table owns the rows and sorts them, or builder mode, where the rows come from your own state (Bloc, `ChangeNotifier`, etc.), for example for server-side sorting.
* Bidirectional scroll bars.
* Resizable.
* Dynamic row height.
* Column summary (Footer).
* Highly customizable.
* Custom cells.
* Pinned columns.
* Multiple sort.
* Infinite scroll.
* Trailing widget.

## Model mode

A `DaviModel` holds the rows and takes care of them, including sorting.

```dart
DaviModel<Person> model = DaviModel(rows: rows, columns: [
  DaviColumn(name: 'Name', cellValue: (params) => params.data.name),
  DaviColumn(name: 'Age', cellValue: (params) => params.data.age)
]);

Davi<Person>(model);
```

## Builder mode

A `DaviController` keeps only the state of the columns. The rows come from you: when they change, rebuild with a new list. Tapping a header calls `onSort`, and you provide the rows in the requested order.

```dart
DaviController<Person> controller = DaviController(columns: [
  DaviColumn(name: 'Name', cellValue: (params) => params.data.name),
  DaviColumn(name: 'Age', cellValue: (params) => params.data.age)
]);

Davi<Person>.builder(
    controller: controller,
    rows: rows,
    onSort: (sortedColumns) {
      // Sort the rows (or fetch them sorted) and rebuild.
    });
```

Explore and learn more by clicking [here](https://caduandrade.github.io/davi_flutter_demo/).

![](https://caduandrade.github.io/davi_flutter/screenshot1.png)

![](https://caduandrade.github.io/davi_flutter/screenshot2.png)

![](https://caduandrade.github.io/davi_flutter/screenshot3.png)