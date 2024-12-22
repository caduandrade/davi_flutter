  ## 4.0.0

*DRAFT*

New class DaviCell
DaviCellBuilder replaced by CellValueBuilder,CellIconBuilder and CellWidgetBuilder

DaviColumn.cellBuilder raplced by DaviColumn.cellValue, DaviColumn.cellIcon, DaviColumn.cellWidget 

CellThemeData.overflow removed

removed:
DaviColumn.intValue;
DaviColumn.doubleValue;
DaviColumn.stringValue;
DaviColumn.objectValue;
DaviColumn.iconValue;
DaviIntValueMapper
DaviDoubleValueMapper
DaviStringValueMapper
DaviObjectValueMapper
DaviIconValueMapper

add SpanProvider<DATA>

EdgeThemeData new
- DaviThemeData.topCornerBorderColor to EdgeThemeData.headerColor
  DaviThemeData.topCornerColor to EdgeThemeData.headerBottomBorderColor and headerLeftBorderColor
  DaviThemeData.bottomCornerBorderColor to EdgeThemeData.scrollbarLeftBorderColor and scrollbarTopBorderColor
  DaviThemeData.bottomCornerColor to EdgeThemeData.scrollbarColor
- 

DaviColumn.fractionDigits removed

RowThemeData.cursor renamed to RowThemeData.callbackCursor
RowThemeData.cursorOnTapGesturesOnly removed

HeaderThemeData.bottomBorderHeight  to HeaderThemeData.bottomBorderThickness
Davi.model cant be null
DaviRowCursor => RowCursorBuilder
CellStyleBuilder removed
Column.cellStyleBuilder => Column.style

CellThemeData.background added
CellThemeData.copyWith removed

Davi.lastRowWidget renamed Davi.trailingWidget
Davi.onLastRowWidget renamed Davi.onTrailingWidget
Davi.pinnedHorizontalScrollController renamed Davi.leftPinnedHorizontalScrollController

RowThemeData.copyWith removed
HeaderCellThemeData.copyWith removed
HeaderThemeData.copyWith removed
DaviThemeData.copyWith removed

DaviColumn.cellClip default value changed to TRUE

DaviColumn.cellTextStyle changed to builder

RowThemeData.lastDividerVisible removed

DaviRow removed
RowCursorBuilder parameter : DaviRow to DATA data, int index, bool hovered
CellBackgroundBuilder parameter : DaviRow to DATA data, int index, bool hovered
DaviRowColor parameter : DaviRow to DATA data, int index, bool hovered
DaviCellBuilder parameter : BuildContext, DaviRow to BuildContext, DATA data, int index, bool hovered
DaviCellSemanticsBuilder parameter : BuildContext, DaviRow to BuildContext, DATA data, int index, bool hovered

- typedef
 - OnLastRowWidgetListener  renamed LastRowWidgetListener  
 - OnLastRowWidgetListener renamed LastRowWidgetListener
 - LastRowWidgetListener renamed 


DaviColumn.grow attribute is now applied only during the initial layout for columns when ColumnWidthBehavior is set to scrollable


bug
- resizing column outside
  - lost icon?



## 3.5.0

* `Davi`
  * Added onRowSecondaryTapUp to get TapUpDetail

## 3.4.1

* Upgraded `renderObject.parent` object to use `RenderObject` instead of the deprecated `AbstractNode`. This ensures compatibility and resolves deprecation Flutter v3.13.0.

## 3.4.0

* BugFix
  * On-screen keyboard not showing up in Windows.
* Semantics configuration individually for each cell.
  * New typedef: `DaviCellSemanticsBuilder`.
  * `DaviColumn`
    * New attribute: `semanticsBuilder`

## 3.3.0

* Adding `copyWith` method to theme classes: `DaviThemeData`, `HeaderCellThemeData`, `HeaderThemeData`, `RowThemeData`, `CellThemeData` and `TableScrollbarThemeData`.

## 3.2.0

* `Davi`
  * The `multiSort` attribute has been moved to `DaviModel` as `multiSortEnabled`.
* `DaviModel`
  * New attribute: `alwaysSorted`.
    * Defines if there will always be some sorted column.
  * The `ignoreSort` attribute has been renamed to `ignoreDataComparators`.
  * New methods: `getColumn(dynamic id)` and `sortList`.
  * Removed methods: `multiSortByColumn`, `sortByColumnIndex` and `sortByColumn`.
* `DaviColumn`
  * The `sort` attribute has been renamed to `dataComparator`.
  * The `priority` and `order` attributes has been replaced by the new `sort` attribute. 
  * The `isSorted` has been removed.
* `HeaderCellThemeData`
  * The `sortOrderSize` attribute has been renamed to `sortPrioritySize`
* The `DaviColumnSort` typedef has been renamed to `DaviDataComparator`
* The `TableSortOrder` enum has been renamed to `DaviSortDirection`
* The `ColumnSort` class has been renamed to `DaviSort`
  * The `order` attribute has been renamed to `direction`.
  * The `columnIndex`(int) has been replaced by `columnId`(dynamic).
* `HeaderCellThemeData`
  * Default sorting icons have been changed.
  * The `sortIconColor` attribute has been replaced by `sortIconColors` (ascending and descending). 
  * The `ascendingIcon` and `descendingIcon` attributes has been replaced by `sortIconBuilder`.
  * New attributes: `sortPriorityColor` and `sortPriorityGap`.
* `SortIconBuilders`
  * Default sort icon builders.

## 3.1.1

* Bugfix
  * `DaviModel` and scroll controllers being disposed by `Davi`.

## 3.1.0

* Adding semantics on header and cells.
* Allow to ignore sorting functions. Useful for server-side sorting when loading data.
* `DaviModel`
  * New callback: `onSort`.
  * New attribute: `ignoreSort`.
    * Ignore column sorting functions to maintain the natural order of the data. Allows the header to be sortable if the column is also sortable.
* `Davi`
  * New attribute: `tapToSortEnabled`.
    * Indicates whether sorting events are enabled on the header.
final bool sortable;
* Refactor
  * The `sortable` attribute of the `DaviColumn` can be `TRUE` even without a `sort` function.
  * Typedef `DaviColumnSort`
    * New parameter: `DaviColumn<DATA> column`

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
