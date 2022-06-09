import 'package:flutter/widgets.dart';

class TableCallbacks {
  TableCallbacks(
      {required this.onTap,
      required this.onDragStart,
      required this.onDragUpdate,
      required this.onDragEnd});

  final GestureTapCallback? onTap;
  final GestureDragStartCallback? onDragStart;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableCallbacks &&
          runtimeType == other.runtimeType &&
          onTap == other.onTap &&
          onDragStart == other.onDragStart &&
          onDragUpdate == other.onDragUpdate &&
          onDragEnd == other.onDragEnd;

  @override
  int get hashCode =>
      onTap.hashCode ^
      onDragStart.hashCode ^
      onDragUpdate.hashCode ^
      onDragEnd.hashCode;
}
