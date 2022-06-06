import 'package:easy_table/src/sort_type.dart';

/// Describes the ordering of a column.
class ColumnSort {
  ColumnSort({required this.columnIndex, required this.sortType});

  final int columnIndex;
  final EasyTableSortType sortType;
}
