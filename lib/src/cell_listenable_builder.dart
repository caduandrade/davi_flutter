import 'package:flutter/widgets.dart';

/// A function that provides a [Listenable] for a specific cell in a column.
typedef DaviCellListenableBuilder<DATA> = Listenable? Function(
    ListenableBuilderParams<DATA> params);

/// Parameters passed to the [DaviCellListenableBuilder] function.
class ListenableBuilderParams<DATA> {
  ListenableBuilderParams({required this.data, required this.rowIndex});

  final DATA data;
  final int rowIndex;
}
