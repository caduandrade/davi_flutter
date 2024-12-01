/// A function type that calculates the span for a cell in a table (either row or column).
///
/// This function is used to define how many rows or columns a cell should span based on the data
/// associated with the row and its index.
///
/// The function takes two parameters:
/// - `data`: The data object representing the row, typically a model or data structure.
/// - `rowIndex`: The index of the row in the table, starting from 0.
///
/// The return value is an `int`, where:
/// - A return value of `1` means the cell does not span multiple rows or columns.
/// - Any value greater than `1` specifies how many rows or columns the cell should span.
///
/// Example usage for `rowSpan` or `columnSpan` calculation:
/// ```dart
/// SpanProvider<MyData> spanCalculator = (data, rowIndex) {
///   if (data.shouldSpanRows) {
///     return 3; // Cell will span 3 rows or columns
///   }
///   return 1; // Cell does not span rows or columns
/// };
/// ```
typedef SpanProvider<DATA> = int Function(DATA data, int rowIndex);
