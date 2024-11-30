/// Defines column width behavior.
enum ColumnWidthBehavior {
  /// If the total column width is greater than the available width,
  /// horizontal scrolling is displayed.
  /// When it is smaller, the remaining width will be stretched
  /// to fill the space according to the value of the grow attribute.
  /// This stretching based on grow will only occur the first time a column
  /// is laid out. For newly added columns, this behavior will apply during
  /// their initial layout. Afterward, columns can be resized manually
  /// like any other.
  scrollable,

  /// All columns will fit in the available width.
  /// There is no horizontal scroll.
  /// If the column's `grow` attribute is null,
  /// the value 1 will be considered by default.
  /// The columns cannot be resized.
  fit
}
