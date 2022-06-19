import 'dart:ui';

import 'package:easy_table/src/theme/row_color.dart';
import 'package:meta/meta.dart';

@internal
class RowsPaintingSettings {
  RowsPaintingSettings(
      {required this.divisorColor,
      required this.fillHeight,
      required this.lastRowDividerVisible,
      required this.rowColor});

  final Color? divisorColor;
  final EasyTableRowColor? rowColor;
  final bool fillHeight;
  final bool lastRowDividerVisible;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowsPaintingSettings &&
          runtimeType == other.runtimeType &&
          divisorColor == other.divisorColor &&
          rowColor == other.rowColor &&
          fillHeight == other.fillHeight &&
          lastRowDividerVisible == other.lastRowDividerVisible;

  @override
  int get hashCode =>
      divisorColor.hashCode ^
      rowColor.hashCode ^
      fillHeight.hashCode ^
      lastRowDividerVisible.hashCode;
}
