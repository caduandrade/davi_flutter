import 'package:easy_table/src/theme/cell_theme_data.dart';
import 'package:flutter/material.dart';

/// Stores cell theme values that change the table layout.
class CellThemeMetrics {
  CellThemeMetrics({required CellThemeData themeData})
      : padding = themeData.padding,
        height = themeData.contentHeight +
            ((themeData.padding != null) ? themeData.padding!.vertical : 0);

  final EdgeInsets? padding;
  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellThemeMetrics &&
          runtimeType == other.runtimeType &&
          padding == other.padding &&
          height == other.height;

  @override
  int get hashCode => padding.hashCode ^ height.hashCode;
}
