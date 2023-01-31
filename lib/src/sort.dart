import 'package:davi/src/sort_direction.dart';

/// Describes the [Davi] sort.
class DaviSort {
  DaviSort(this.columnId, [this.direction = DaviSortDirection.ascending]) {
    ArgumentError.checkNotNull(columnId);
  }

  factory DaviSort.ascending(dynamic columnId) {
    return DaviSort(columnId, DaviSortDirection.ascending);
  }

  factory DaviSort.descending(dynamic columnId) {
    return DaviSort(columnId, DaviSortDirection.descending);
  }

  final dynamic columnId;
  final DaviSortDirection direction;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DaviSort &&
          runtimeType == other.runtimeType &&
          columnId == other.columnId &&
          direction == other.direction;

  @override
  int get hashCode => columnId.hashCode ^ direction.hashCode;

  @override
  String toString() {
    return 'DaviSort{columnId: $columnId, direction: $direction}';
  }
}
