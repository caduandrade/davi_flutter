import 'package:flutter/material.dart';

/// Signature for a function that defines a row cursor.
/// The theme value will be used if it returns `NULL`.
typedef RowCursorBuilder<DATA> = MouseCursor? Function(
    CursorBuilderParams params);

/// Parameters passed to the [RowCursorBuilder] function.
class CursorBuilderParams<DATA> {
  CursorBuilderParams(
      {required this.data, required this.rowIndex, required this.hovered});

  final DATA data;
  final int rowIndex;
  final bool hovered;
}
