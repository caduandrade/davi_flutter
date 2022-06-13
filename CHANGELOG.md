## 2.0.0

* Changes
  * `HeaderThemeData.height` has been removed.
  * `HeaderCellThemeData.height` has been added.
  * `TableScrollbarThemeData.columnDividerColor` has been added.
  * `CellThemeData.overflow` has been added.
  * `CellStyle.overflow` has been added.

## 1.6.0

* Multiple column sort.
  * `EasyTableModel.removeColumnSort` renamed to `EasyTableModel.clearSort`. 
* Bugfix
  * `CellStyle.background` not being used in null-valued cells.

## 1.5.1

* Bugfix
  * Drag stops when horizontal scrollbar is displayed.

## 1.5.0

* Vertical scroll with keyboard keys: arrow up, arrow down, page down and page up.
* Added `visibleRowIndex` in `EasyTableCellBuilder`.
* Added `notifyUpdate` method in `EasyTableModel`.

## 1.4.0

* Feature to display horizontal scrollbar only when needed.
  * A warning is being displayed in the console due to a bug in Flutter: https://github.com/flutter/flutter/issues/103939
  * The error happens when the horizontal scrollbar is hidden after being visible.
  * The following MR should fix the issue: https://github.com/flutter/flutter/pull/103948 
* `EasyTable.onLastVisibleRowListener` for listening to the last visible row index.
  * Useful for infinite scroll. 
* Added `RowThemeData.dividerColor`.
* `EasyTableThemeData.rowDividerThickness` moved to `RowThemeData.dividerThickness`.
* `RowThemeData.columnDividerColor` moved to `EasyTableThemeData.columnDividerColor`.
* `TableScrollThemeData` renamed to `TableScrollbarThemeData`.
* `EasyTableThemeData.scroll` renamed to `EasyTableThemeData.scrollbar`.
* Removed `EasyTable.scrollbarMargin` and `EasyTable.scrollbarThickness` (already exists in `TableScrollbarThemeData`).

## 1.3.0

* Updated to Flutter 3.0.0 or higher.
* Improved renderer performance.
* `CellThemeData.contentHeight` moved to `EasyTable.cellContentHeight`.
* `EasyTableColumn`
  * Added the `iconValueMapper` and `cellStyleBuilder` attributes.
  * `textStyle` refactored to `headerTextStyle` and `cellTextStyle`.
  * `padding` refactored to `headerPadding` and `cellPadding`.
  * `alignment` to `headerAlignment` and `cellAlignment`.
* `EasyTableCell` has been removed.

## 1.2.0

* Scrollbars without overlapping table contents.
* Added the `onRowSecondaryTap` callback.

## 1.1.0

* Pinned columns.

## 1.0.0

* Header leading.

## 0.9.0

* `visibleRowsCount` feature to calculate the height based on the number of visible lines. It can be used within an unbounded height layout.
* Layout bugfix
* EasyTableModel
  * Adding the `replaceRows` method

## 0.8.0

* Columns fit.

## 0.7.0

* Theme
  * Column
    * Divider color
  * Cell
    * Null cell color
* New column parameters for theme override
  * `padding`
  * `alignment`
  * `textStyle`
* Allow mapping columns to null values

## 0.6.0

* Resizable columns.

## 0.5.0

* Row callbacks
  * `onRowTap`
  * `onRowDoubleTap`

## 0.4.0

* Sort feature.

## 0.3.0

* `EasyTableModel` to handle rows and columns.

## 0.2.0

* `EasyTableTheme` widget to applies a theme to descendant widgets.
  * More theming options will be added to `EasyTableThemeData`.

## 0.1.0

* Initial release
  * Bidirectional scroll bars
  * Columns
    * Initial width
    * Header builder
    * Cell builder
      * Initial automatic cell builder with data mapper

## 0.0.1

* Package creation.