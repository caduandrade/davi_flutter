/// Defines the sorting mode applied to the table.
///
/// - `interactive`: Allows the user to toggle between natural (original order), ascending, and descending states.
/// - `alwaysSorted`: Ensures the table is always sorted, toggling only between ascending and descending states.
/// - `disabled`: Disables sorting functionality entirely, showing data in its original order.
enum SortingMode {
  /// Allows the user to toggle between three states:
  /// natural (original order), ascending, and descending.
  interactive,

  /// Ensures that the table is always sorted by a column,
  /// toggling only between ascending and descending states.
  alwaysSorted,

  /// Disables sorting functionality completely.
  /// The data will be displayed in its original order.
  disabled,
}
