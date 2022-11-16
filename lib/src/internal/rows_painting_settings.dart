import 'dart:ui';

import 'package:easy_table/src/theme/theme_row_color.dart';
import 'package:meta/meta.dart';

@internal
class RowsPaintingSettings {
  RowsPaintingSettings(
      {required this.divisorColor,
      required this.fillHeight,
      required this.lastRowDividerVisible,
      required this.rowColor,
      required this.visibleRowsLength,
      required this.maxVisibleRowsLength,
      required this.firstRowIndex});

  final Color? divisorColor;
  final ThemeRowColor? rowColor;
  final bool fillHeight;
  final bool lastRowDividerVisible;
  final int visibleRowsLength;

  /// The number of rows that can be visible at the available height.
  final int maxVisibleRowsLength;
  final int firstRowIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowsPaintingSettings &&
          runtimeType == other.runtimeType &&
          divisorColor == other.divisorColor &&
          rowColor == other.rowColor &&
          fillHeight == other.fillHeight &&
          lastRowDividerVisible == other.lastRowDividerVisible &&
          visibleRowsLength == other.visibleRowsLength &&
          maxVisibleRowsLength == other.maxVisibleRowsLength &&
          firstRowIndex == other.firstRowIndex;

  @override
  int get hashCode =>
      divisorColor.hashCode ^
      rowColor.hashCode ^
      fillHeight.hashCode ^
      lastRowDividerVisible.hashCode ^
      visibleRowsLength.hashCode ^
      maxVisibleRowsLength.hashCode ^
      firstRowIndex.hashCode;
}
