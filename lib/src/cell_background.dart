import 'package:flutter/widgets.dart';

/// Signature for a function that builds a background for a cell.
///
/// Used by [DaviColumn].
typedef CellBackgroundBuilder<DATA> = Color? Function(
    BackgroundBuilderParams params);

class BackgroundBuilderParams<DATA> {
  BackgroundBuilderParams(
      {required this.data, required this.rowIndex, required this.hovered});

  final DATA data;
  final int rowIndex;
  final bool hovered;
}
