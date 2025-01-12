import 'package:flutter/material.dart';

/// Signature for a function that defines a row color.
/// The theme value will be used if it returns `NULL`.
typedef DaviRowColor<DATA> = Color? Function(RowColorParams<DATA> params);

/// Parameters passed to the [DaviRowColor] function.
class RowColorParams<DATA> {
  RowColorParams(
      {required this.data, required this.rowIndex, required this.hovered});

  final DATA data;
  final int rowIndex;
  final bool hovered;
}
