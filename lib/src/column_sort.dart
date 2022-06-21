import 'package:easy_table/src/sort_order.dart';

/// Describes the column sort.
class ColumnSort {
  ColumnSort({required this.columnIndex, required this.order});

  final int columnIndex;
  final TableSortOrder order;
}
