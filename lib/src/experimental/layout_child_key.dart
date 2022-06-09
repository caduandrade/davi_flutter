import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/layout_child_type.dart';
import 'package:flutter/widgets.dart';

class LayoutChildKey extends LocalKey {
  const LayoutChildKey(
      {required this.type,
      required this.contentAreaId,
      required this.row,
      required this.column});

  final LayoutChildType type;
  final ContentAreaId? contentAreaId;
  final int? row;
  final int? column;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutChildKey &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          contentAreaId == other.contentAreaId &&
          row == other.row &&
          column == other.column;

  @override
  int get hashCode =>
      type.hashCode ^ contentAreaId.hashCode ^ row.hashCode ^ column.hashCode;

  @override
  String toString() {
    return 'LayoutChildKey{type: $type, contentAreaId: $contentAreaId, row: $row, column: $column}';
  }
}
