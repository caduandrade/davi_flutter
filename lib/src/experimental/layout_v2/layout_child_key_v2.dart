import 'package:easy_table/src/experimental/column_pin.dart';
import 'package:easy_table/src/experimental/layout_v2/layout_child_type_v2.dart';
import 'package:flutter/widgets.dart';

class LayoutChildKeyV2 extends LocalKey {
  const LayoutChildKeyV2(
      {required this.type,
      required this.contentAreaId,
      required this.row,
      required this.column});

  final LayoutChildTypeV2 type;
  final ColumnPin? contentAreaId;
  final int? row;
  final int? column;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutChildKeyV2 &&
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
