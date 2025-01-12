import 'package:flutter/widgets.dart';

/// Signature for a function that builds a text style for a cell.
///
/// Used by [DaviColumn].
typedef CellTextStyleBuilder<DATA> = TextStyle? Function(
    TextStyleBuilderParams<DATA> params);

/// Parameters passed to the [CellTextStyleBuilder] function.
class TextStyleBuilderParams<DATA> {
  TextStyleBuilderParams(
      {required this.data, required this.rowIndex, required this.hovered});

  final DATA data;
  final int rowIndex;
  final bool hovered;
}
