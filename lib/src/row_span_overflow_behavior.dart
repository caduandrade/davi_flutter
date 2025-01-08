/// Defines the behavior when a cell's rowSpan exceeds the available number of rows.
enum RowSpanOverflowBehavior {
  /// Throws an error if the cell's rowSpan exceeds the available number of rows.
  /// Use this option to enforce strict validation and prevent unexpected behaviors.
  error,

  /// Adjusts the rowSpan to fit within the available rows, limiting the span.
  /// This ensures the cell's content is displayed without breaking the table structure.
  cap
}
