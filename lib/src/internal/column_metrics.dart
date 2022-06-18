import 'dart:math' as math;
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/pin_status.dart';
import 'package:easy_table/src/model.dart';
import 'package:meta/meta.dart';

@internal
class ColumnMetrics<ROW> {
  ColumnMetrics(
      {required this.column,
      required this.width,
      required this.offset,
      required this.pinStatus});

  final EasyTableColumn<ROW> column;
  final double width;
  final double offset;
  final PinStatus pinStatus;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColumnMetrics &&
          runtimeType == other.runtimeType &&
          column == other.column &&
          width == other.width &&
          offset == other.offset &&
          pinStatus == other.pinStatus;

  @override
  int get hashCode =>
      column.hashCode ^ width.hashCode ^ offset.hashCode ^ pinStatus.hashCode;

  static List<ColumnMetrics<ROW>> columnsFit<ROW>(
      {required EasyTableModel<ROW> model,
      required double maxWidth,
      required double dividerThickness}) {
    List<ColumnMetrics<ROW>> list = [];
    double offset = 0;
    final int dividersLength = math.max(0, model.columnsLength - 1);
    final double availableWidth =
        math.max(0, maxWidth - (dividerThickness * dividersLength));
    final double columnWidthRatio = availableWidth / model.columnsWeight;

    for (int i = 0; i < model.columnsLength; i++) {
      final EasyTableColumn<ROW> column = model.columnAt(i);
      final double width = columnWidthRatio * column.weight;
      list.add(ColumnMetrics<ROW>(
          column: column,
          width: width,
          offset: offset,
          pinStatus: PinStatus.none));
      offset += width + dividerThickness;
    }
    return list;
  }

  static List<ColumnMetrics<ROW>> resizable<ROW>(
      {required EasyTableModel<ROW> model, required double dividerThickness}) {
    List<ColumnMetrics<ROW>> list = [];
    double offset = 0;
    for (PinStatus pinStatus in PinStatus.values) {
      for (int i = 0; i < model.columnsLength; i++) {
        final EasyTableColumn<ROW> column = model.columnAt(i);
        if ((pinStatus == column.pinStatus)) {
          list.add(ColumnMetrics<ROW>(
              column: column,
              width: column.width,
              offset: offset,
              pinStatus: pinStatus));
          offset += column.width + dividerThickness;
        }
      }
    }
    return list;
  }
}
