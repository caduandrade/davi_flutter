import 'package:davi/src/sort_direction.dart';

/// Describes the [Davi] sort.
class DaviSort {
  DaviSort(this.id, [this.direction = DaviSortDirection.ascending]);

  final dynamic id;
  final DaviSortDirection direction;
}
