import 'dart:math' as math;
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/pin_status.dart';
import 'package:easy_table/src/model.dart';

class ColumnMetricsV3<ROW> {
  ColumnMetricsV3(
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
      other is ColumnMetricsV3 &&
          runtimeType == other.runtimeType &&
          column == other.column &&
          width == other.width &&
          offset == other.offset &&
          pinStatus == other.pinStatus;

  @override
  int get hashCode =>
      column.hashCode ^ width.hashCode ^ offset.hashCode ^ pinStatus.hashCode;

  static List<ColumnMetricsV3<ROW>> columnsFit<ROW>(
      {required EasyTableModel<ROW> model,
      required double maxWidth,
      required double dividerThickness}) {
    List<ColumnMetricsV3<ROW>> list = [];
    double offset = 0;
    final int dividersLength = math.max(0, model.columnsLength - 1);
    final double availableWidth =
        math.max(0, maxWidth - (dividerThickness * dividersLength));
    final double columnWidthRatio = availableWidth / model.columnsWeight;

    for (int i = 0; i < model.columnsLength; i++) {
      final EasyTableColumn<ROW> column = model.columnAt(i);
      final double width = columnWidthRatio * column.weight;
      list.add(ColumnMetricsV3<ROW>(
          column: column,
          width: width,
          offset: offset,
          pinStatus: PinStatus.unpinned));
      offset += width + dividerThickness;
    }
    return list;
  }

  static List<ColumnMetricsV3<ROW>> resizable<ROW>(
      {required EasyTableModel<ROW> model, required double dividerThickness}) {
    List<ColumnMetricsV3<ROW>> list = [];
    double offset = 0;
    for (PinStatus pinStatus in PinStatus.values) {
      for (int i = 0; i < model.columnsLength; i++) {
        final EasyTableColumn<ROW> column = model.columnAt(i);
        if ((pinStatus == PinStatus.unpinned && column.pinned == false) ||
            (pinStatus == PinStatus.leftPinned && column.pinned)) {
          list.add(ColumnMetricsV3<ROW>(
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
