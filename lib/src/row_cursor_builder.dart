import 'package:flutter/material.dart';

/// Signature for a function that defines a row cursor.
/// The theme value will be used if it returns `NULL`.
typedef RowCursorBuilder<DATA> = MouseCursor? Function(
    CursorBuilderParams params);

/// Parameters passed to the [RowCursorBuilder] function.
class CursorBuilderParams<DATA> {
  CursorBuilderParams(
      {required this.data, required this.rowIndex, required this.hovered});

  /// Represents the data for a row in the table.
  final DATA data;

  /// The index of the row in the table.
  final int rowIndex;

  /// Indicates whether the row is hovered over.
  final bool hovered;
}
