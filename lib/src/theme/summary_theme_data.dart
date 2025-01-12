import 'package:flutter/material.dart';

class SummaryThemeData {
  const SummaryThemeData(
      {this.contentHeight = SummaryThemeDataDefaults.contentHeight,
      this.topBorderThickness = SummaryThemeDataDefaults.topBorderThickness,
      this.topBorderColor = SummaryThemeDataDefaults.topBorderColor,
      this.columnDividerColor = SummaryThemeDataDefaults.columnDividerColor,
      this.color = SummaryThemeDataDefaults.color,
      this.alignment = SummaryThemeDataDefaults.alignment,
      this.padding = SummaryThemeDataDefaults.padding});

  double get height => contentHeight + topBorderThickness;

  final double contentHeight;
  final double topBorderThickness;
  final Color? topBorderColor;
  final Color? color;
  final Color? columnDividerColor;
  final EdgeInsets? padding;
  final Alignment? alignment;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryThemeData &&
          runtimeType == other.runtimeType &&
          contentHeight == other.contentHeight &&
          topBorderThickness == other.topBorderThickness &&
          topBorderColor == other.topBorderColor &&
          color == other.color &&
          columnDividerColor == other.columnDividerColor &&
          padding == other.padding &&
          alignment == other.alignment;

  @override
  int get hashCode =>
      contentHeight.hashCode ^
      topBorderThickness.hashCode ^
      topBorderColor.hashCode ^
      color.hashCode ^
      columnDividerColor.hashCode ^
      padding.hashCode ^
      alignment.hashCode;
}

class SummaryThemeDataDefaults {
  static const double contentHeight = 32;
  static const double topBorderThickness = 1;
  static const Color topBorderColor = Colors.grey;
  static const Color color = Color(0xFFE0E0E0);
  static const Color columnDividerColor = Colors.grey;
  static const EdgeInsets padding = EdgeInsets.only(left: 8, right: 8);
  static const Alignment alignment = Alignment.centerLeft;
}
