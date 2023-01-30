import 'package:davi/src/sort_direction.dart';

/// Describes the [Davi] sort.
class DaviSort {
  DaviSort(this.id, [this.direction = DaviSortDirection.ascending]);

  final dynamic id;
  final DaviSortDirection direction;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DaviSort &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          direction == other.direction;

  @override
  int get hashCode => id.hashCode ^ direction.hashCode;

  @override
  String toString() {
    return 'DaviSort{id: $id, direction: $direction}';
  }
}
