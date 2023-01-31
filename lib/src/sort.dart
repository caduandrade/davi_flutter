import 'package:davi/src/sort_direction.dart';
import 'package:meta/meta.dart';

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

  int _priority = 1;

  /// The priority used in multi sorting.
  ///
  /// When added to the model, this value will be automatically updated
  /// to keep incremental across columns.
  /// Must be ignored in [hashCode] and [==] operator.
  int get priority => _priority;

  @internal
  set priority(int value) {
    _priority = value;
  }

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
