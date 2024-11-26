import 'package:flutter/material.dart';

class SummaryThemeData {
  const SummaryThemeData(
      {this.contentHeight = SummaryThemeDataDefaults.contentHeight,
      this.topBorderThickness = SummaryThemeDataDefaults.topBorderThickness,
      this.topBorderColor = SummaryThemeDataDefaults.topBorderColor,
      this.color = SummaryThemeDataDefaults.color});

  double get height => contentHeight + topBorderThickness;

  final double contentHeight;
  final double topBorderThickness;
  final Color? topBorderColor;
  final Color? color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryThemeData &&
          runtimeType == other.runtimeType &&
          contentHeight == other.contentHeight &&
          topBorderThickness == other.topBorderThickness &&
          topBorderColor == other.topBorderColor &&
          color == other.color;

  @override
  int get hashCode =>
      contentHeight.hashCode ^
      topBorderThickness.hashCode ^
      topBorderColor.hashCode ^
      color.hashCode;
}

class SummaryThemeDataDefaults {
  static const double contentHeight = 32;
  static const double topBorderThickness = 5;
  static const Color topBorderColor = Colors.grey;
  static const Color color = Color(0xFFE0E0E0);
}
