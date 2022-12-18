/// Defines column width behavior.
enum ColumnWidthBehavior {
  /// If the total column width is greater than the available width,
  /// horizontal scrolling is displayed.
  /// When it is smaller, the remaining width will be distributed
  /// to the columns according to the value of the grow attribute.
  /// Columns with null `grow` value will not stretch.
  /// Columns set to grow cannot be resized and
  /// the width value is considered the minimum value.
  scrollable,

  /// All columns will fit in the available width.
  /// There is no horizontal scroll.
  /// If the column's `grow` attribute is null,
  /// the value 1 will be considered by default.
  /// The columns cannot be resized.
  fit
}
