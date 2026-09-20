## 5.0.0

* Row height is now dynamic: each row automatically grows to fit its content, the same way the header row already does, instead of using a single fixed height for every row.
* Cell merging (`rowSpan`/`columnSpan`) has been removed. It was one of the main blockers to making row height dynamic, made sorting and horizontal merging harder to reason about together, and added significant internal complexity for a rarely used feature. Removing it keeps the package simpler to maintain.
* Changes
  * `DaviColumn`
    * The `rowSpan` and `columnSpan` attributes have been removed.
  * `DaviModel`
    * The `maxRowSpan`, `maxColumnSpan`, `maxSpanBehavior`, `rowSpanOverflowBehavior` and `collisionBehavior` attributes have been removed.
  * `CellThemeData`
    * The `contentHeight` attribute has been removed; height is now derived automatically from cell content.
  * `RowThemeData`
    * New `estimatedHeight` attribute: an initial height hint used only until a row's real content is measured.
  * `DaviColumn`
    * `cellOverflow` now actually applies to `cellValue` cells (it was previously unused): leave it unset to let text wrap onto multiple lines and grow the row, or set it (e.g. `TextOverflow.ellipsis`) to keep it on a single line as before.
  * Removed `SpanProvider`, `SpanParams`, `MaxSpanBehavior`, `RowSpanOverflowBehavior` and `CellCollisionBehavior`.
* Bugfix
  * Cell text with no explicit `textStyle` (the default) could render invisible/white instead of a visible color, since it bypassed `DefaultTextStyle` inheritance.
  * `cellValue` text never wrapped, even with dynamic row height, since it was always measured/painted as a single line internally.
  * Mouse-wheel/keyboard scrolling could stop short of (or overshoot) the table's real end, while dragging the scrollbar itself was always correct - the scroll position's max extent wasn't kept in sync as row heights were measured. This also fixes a blank gap left at the bottom when scrolled near the end and the content height then shrank (e.g. turning off a custom row divider thickness).
  * A settings change that also resized rows (e.g. a custom row divider thickness) could leave a row's layout visibly stale for one frame.
  * Cell content position wasn't reported to Flutter's transform tree (`RenderObject.applyPaintTransform`), only used at paint/hit-test time - anything relying on it (accessibility/semantics, `Scrollable.ensureVisible`, `localToGlobal`) saw every cell as sitting at its row's container origin instead of its real position.

## 4.1.0

* The header row height is no longer fixed by the theme; it now adapts automatically to the header content's actual height.
* `DaviColumn` has a new optional `headerBuilder`, letting you fully customize the header content instead of the automatic `Text(name)`.
* The header's text style is now inherited by any `Text` in the header row, including custom `leading`/`headerBuilder` content, instead of needing to be set explicitly.
* Improved scrolling performance: the table no longer recomputes cell mapping, spans, collisions and dividers on every scroll frame, only when the visible rows actually change.
* You can now scroll horizontally by clicking (or trackpad-dragging) and dragging anywhere in the table body, not just the scrollbar.
* Bugfix
  * Columns were no longer resizable when `DaviModel.sortingMode` was set to `SortingMode.disabled`.

## 4.0.1

* Bugfix
  * Cell painter and cell bar were not taking up the entire width in fit mode.

## 4.0.0

* Significant performance improvements
  * Internal tests show Flutter frame rates during scrolling increasing from 5 FPS to over 30 FPS
* Cell merging
* Column summary (Footer)
* New cell types
  * Custom rendering using Canvas
  * Percentage bar
* Changes
  * `Davi`
    * The `lastRowWidget` attribute has been renamed to `trailingWidget`.
    * The `onLastRowWidget` attribute has been renamed to `onTrailingWidget`.
    * The `pinnedHorizontalScrollController` attribute has been renamed to `leftPinnedHorizontalScrollController`.
    * The `model` attribute is now non-nullable.
    * The `tapToSortEnabled` attribute has been replaced by `DaviModel.sortingMode`.
    * The `placeholderWidget` attribute has been added.
  * `DaviModel`
    * The `alwaysSorted` attribute has been replaced by `sortingMode`.
    * The `onSort` has been changed to be called before sorting.
  * `DaviColumn`
    * The `stringValue`, `intValue`, `objectValue` and `doubleValue` attributes has been replaced by `cellValue`.
    * The `cellBuilder` attribute has been replaced by `cellWidget`.
    * The `iconValueMapper` attribute has been replaced by `cellIcon`.
    * The `fractionDigits` attribute has been removed.
    * The `cellStyleBuilder` attribute has been removed.
    * The `cellTextStyle` attribute has been updated from a `TextStyle` type to a builder of type `CellTextStyleBuilder`
    * The default `cellClip` value has been changed to `TRUE`.
    * The `grow` attribute is now applied only during the initial layout for columns when `ColumnWidthBehavior` is set to `scrollable`.
    * The `sort` attribute has been renamed to `sortDirection`.
      * The type has been changed from `DaviSort` to `DaviSortDirection`.
  * `CellThemeData`
    * The `overflow` attribute has been removed.
  * `DaviThemeData`
    * The `topCornerBorderColor` attribute has been moved to `EdgeThemeData.headerColor`.
    * The `topCornerColor` attribute has been changed to `EdgeThemeData` attributes: `headerBottomBorderColor` and `headerLeftBorderColor`.
    * The `bottomCornerBorderColor` attribute has been changed to `EdgeThemeData` attribute: `scrollbarLeftBorderColor` and `scrollbarTopBorderColor`.
    * The `bottomCornerColor` attribute has been moved to `EdgeThemeData.scrollbarColor`.
    * The `copyWith` method has been removed.
  * `RowThemeData` 
    * The `cursor` attribute has been renamed to `callbackCursor`.
    * The `cursorOnTapGesturesOnly` attribute has been removed.
    * The `copyWith` method has been removed.
    * The `lastDividerVisible` attribute has been removed.
  * `HeaderThemeData`
    * The `bottomBorderHeight` attribute has been renamed to `bottomBorderThickness`.
    * The `copyWith` method has been removed.
  * `CellThemeData`
    * The `copyWith` method has been removed.
  * `HeaderCellThemeData`
    * The `copyWith` method has been removed.
  * Typedefs
    * `DaviDataComparator`
      * Has been renamed to `DaviComparator`
      * Updated the signature to include `rowA` and `rowB` parameters, and removed the `column` parameter
    * `DaviRowCursor`
      * Has been renamed to `RowCursorBuilder`.
      * Its signature has been changed from `DaviRow` to `CursorBuilderParams`
    * `OnLastRowWidgetListener` to `TrailingWidgetListener`
    * `OnLastVisibleRowListener` to `LastVisibleRowListener`
    * `DaviCellSemanticsBuilder`
      * Its signature has been changed from `DaviRow` to `SemanticsBuilderParams`
    * `CellBackgroundBuilder`
      * Its signature has been changed from `DaviRow` to `BackgroundBuilderParams`
  * Removed classes and typedefs
    * `DaviIntValueMapper`
    * `DaviDoubleValueMapper`
    * `DaviStringValueMapper`
    * `DaviObjectValueMapper`
    * `DaviIconValueMapper`
    * `CellStyleBuilder`
    * `DaviRow`
* BugFixes 
  * Focus problem between instances (or simply another focus widget)
  * Scroll is moving in opposite direction on Android.

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
    * New attribute: `DaviColumn<DATA> column`

## 3.0.0

* Renaming classes and attributes
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
