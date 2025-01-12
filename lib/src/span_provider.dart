/// A function type that calculates the span for a cell in a table (either row or column).
///
/// This function is used to define how many rows or columns a cell should span based on the data
/// associated with the row and its index.
typedef SpanProvider<DATA> = int Function(SpanParams<DATA> params);

/// Parameters passed to the [SpanProvider] function.
class SpanParams<DATA> {
  SpanParams({required this.data, required this.rowIndex});

  final DATA data;
  final int rowIndex;
}
