import 'package:davi/src/sort_direction.dart';

/// Describes the column sort.
class DaviSort {
  DaviSort({required this.columnIndex, required this.direction});

  final int columnIndex;
  final DaviSortDirection direction;
}
