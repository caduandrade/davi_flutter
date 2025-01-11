import 'package:flutter/widgets.dart';

/// A function that provides a [Listenable] for a specific cell in a column.
/// The function receives the row's data ([DATA]) and the row index ([rowIndex])
/// and returns the corresponding [Listenable].
typedef DaviCellListenableBuilder<DATA> = Listenable? Function(
    ListenableBuilderParams<DATA> params);

/// Parameters passed to the [DaviCellListenableBuilder] function.
class ListenableBuilderParams<DATA> {
  ListenableBuilderParams({required this.data, required this.rowIndex});

  final DATA data;
  final int rowIndex;
}
