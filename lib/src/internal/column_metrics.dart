import 'dart:math' as math;

import 'package:davi/src/column.dart';
import 'package:davi/src/model.dart';
import 'package:davi/src/pin_status.dart';
import 'package:meta/meta.dart';

@internal
class ColumnMetrics {
  ColumnMetrics(
      {required this.width, required this.offset, required this.pinStatus});

  final double width;
  final double offset;
  final PinStatus pinStatus;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColumnMetrics &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          offset == other.offset &&
          pinStatus == other.pinStatus;

  @override
  int get hashCode => width.hashCode ^ offset.hashCode ^ pinStatus.hashCode;

  static List<ColumnMetrics> columnsFit(
      {required DaviModel model,
      required double maxWidth,
      required double dividerThickness}) {
    List<ColumnMetrics> list = [];
    double offset = 0;
    final int dividersLength = math.max(0, model.columnsLength - 1);
    final double availableWidth =
        math.max(0, maxWidth - (dividerThickness * dividersLength));

    double totalGrow = 0;
    for (int i = 0; i < model.columnsLength; i++) {
      final DaviColumn column = model.columnAt(i);
      totalGrow += column.grow ?? 1;
    }

    final double columnWidthRatio = availableWidth / totalGrow;

    for (int i = 0; i < model.columnsLength; i++) {
      final DaviColumn column = model.columnAt(i);
      final double width = columnWidthRatio * (column.grow ?? 1);
      list.add(ColumnMetrics(
          width: width, offset: offset, pinStatus: PinStatus.none));
      offset += width + dividerThickness;
    }
    return list;
  }

  static List<ColumnMetrics> resizable(
      {required DaviModel model,
      required double maxWidth,
      required double dividerThickness}) {
    double offset = 0;
    double totalGrow = 0;
    for (PinStatus pinStatus in PinStatus.values) {
      for (int i = 0; i < model.columnsLength; i++) {
        final DaviColumn column = model.columnAt(i);
        if (pinStatus == column.pinStatus) {
          offset += column.width + dividerThickness;
          if (column.grow != null) {
            totalGrow += column.grow!;
          }
        }
      }
    }

    double? growFactor;
    if (offset < maxWidth && totalGrow > 0) {
      final double availableWidth = maxWidth - offset;
      growFactor = availableWidth / totalGrow;
    }

    offset = 0;
    List<ColumnMetrics> list = [];
    for (PinStatus pinStatus in PinStatus.values) {
      for (int i = 0; i < model.columnsLength; i++) {
        final DaviColumn column = model.columnAt(i);
        if (pinStatus == column.pinStatus) {
          double width = column.width;
          if (column.grow != null && growFactor != null) {
            width += column.grow! * growFactor;
          }
          list.add(ColumnMetrics(
              width: width, offset: offset, pinStatus: pinStatus));
          offset += width + dividerThickness;
        }
      }
    }

    return list;
  }
}
