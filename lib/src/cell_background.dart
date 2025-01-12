import 'package:flutter/widgets.dart';

/// Signature for a function that builds a background for a cell.
///
/// Used by [DaviColumn].
typedef CellBackgroundBuilder<DATA> = Color? Function(
    BackgroundBuilderParams<DATA> params);

/// Parameters passed to the [CellBackgroundBuilder] function.
class BackgroundBuilderParams<DATA> {
  BackgroundBuilderParams(
      {required this.data, required this.rowIndex, required this.hovered});

  /// The data used to construct the background.
  final DATA data;

  /// Indicates if the row is hovered over.
  final bool hovered;

  /// The index of the row in the data view.
  final int rowIndex;
}
