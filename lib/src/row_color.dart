import 'package:flutter/material.dart';

/// Signature for a function that defines a row color.
/// The theme value will be used if it returns `NULL`.
typedef DaviRowColor<DATA> = Color? Function(RowColorParams<DATA> params);

/// Parameters passed to the [DaviRowColor] function.
class RowColorParams<DATA> {
  RowColorParams(
      {required this.data, required this.rowIndex, required this.hovered});

  /// Represents the data for a row in the table.
  final DATA data;

  /// The index of the row in the table.
  final int rowIndex;

  /// Indicates whether the row is hovered over.
  final bool hovered;
}
