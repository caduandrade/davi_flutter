## 3.1.0

* Refactor
  * The `sortable` attribute of the `DaviColumnSort` can be `TRUE` even without a `sort` method.
    * When the `sortable` attribute is `TRUE` and the `sort` function is  `NULL`, the ordering click on the header will only be enabled if the `externalSort` attribute of the `DaviModel` is `TRUE`. In this case, the data will continue in its natural order but the `onSort` event will be triggered.
  * Typedef `DaviColumnSort`
    * Attribute addition: `DaviColumn<DATA> column`

## 3.0.0

* Renaming classes and parameters
  * `EasyTable<ROW>` to `Davi<DATA>`
  * `EasyTableColumn<ROW>` to `DaviColumn<DATA>`
  * `EasyTableTheme` to `DaviTheme`
  * `EasyTableThemeData` to `DaviThemeData`
  * `RowData<ROW>` to `DaviRow<DATA>`
    * `̀ROW row` to `DATA data`
  * `EasyTableModel<ROW>` to `DaviModel<DATA>`
  * `EasyTableRowColor<ROW>(RowData<ROW> data)` to `DaviRowColor<DATA>(DaviRow<DATA> row)`
  * `EasyTableRowCursor<DATA>(RowData<DATA> data)` to `DaviRowCursor<DATA>(DaviRow<DATA> row)`
  * `EasyTableColumnSort<ROW>(ROW a, ROW b)` to `DaviColumnSort<DATA>(DATA a, DATA b)`
  * `RowTapCallback<ROW>(ROW row)` to `RowTapCallback<DATA>(DATA data)`
  * `RowDoubleTapCallback<ROW>(ROW row)` to `RowDoubleTapCallback<DATA>(DATA data)`
  * `CellBackgroundBuilder<ROW>(RowData<ROW> data)` to `CellBackgroundBuilder<DATA>(DaviRow<DATA> row)`
  * `EasyTableCellBuilder<ROW>(BuildContext context, RowData<ROW> data)` to `DaviCellBuilder<DATA>(BuildContext context, DaviRow<DATA> row)`
  * `CellStyleBuilder<ROW>(RowData<ROW> data)` to `CellStyleBuilder<DATA>(DaviRow<DATA> row)`
  * `EasyTableIntValueMapper<ROW>(ROW row)` to `DaviIntValueMapper<DATA>(DATA data)`
  * `EasyTableDoubleValueMapper<ROW>(ROW row)` to `DaviDoubleValueMapper<DATA>(DATA data)`
  * `EasyTableStringValueMapper<ROW>(ROW row)` to `DaviStringValueMapper<DATA>(DATA data)`
  * `EasyTableObjectValueMapper<ROW>(ROW row)` to `DaviObjectValueMapper<DATA>(DATA data)`
  * `EasyTableIconValueMapper<ROW>(ROW row)` to `DaviIconValueMapper<DATA>(DATA data)`

## 2.6.0

* Migration from `easy_table` package (https://pub.dev/packages/easy_table)
  * Replace import `package:easy_table/easy_table.dart` with `package:davi/davi.dart`