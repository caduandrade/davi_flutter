import 'package:flutter/material.dart';

class EdgeThemeData {
  const EdgeThemeData(
      {this.headerColor = EdgeThemeDataDefaults.headerColor,
      this.headerLeftBorderColor = EdgeThemeDataDefaults.headerLeftBorderColor,
      this.headerBottomBorderColor =
          EdgeThemeDataDefaults.headerBottomBorderColor,
      this.summaryColor = EdgeThemeDataDefaults.summaryColor,
      this.summaryLeftBorderColor =
          EdgeThemeDataDefaults.scrollbarLeftBorderColor,
      this.summaryTopBorderColor = EdgeThemeDataDefaults.summaryTopBorderColor,
      this.scrollbarColor = EdgeThemeDataDefaults.scrollbarColor,
      this.scrollbarLeftBorderColor =
          EdgeThemeDataDefaults.scrollbarLeftBorderColor,
      this.scrollbarTopBorderColor =
          EdgeThemeDataDefaults.scrollbarTopBorderColor});

  final Color? headerColor;
  final Color headerLeftBorderColor;
  final Color headerBottomBorderColor;

  final Color? summaryColor;
  final Color summaryLeftBorderColor;
  final Color summaryTopBorderColor;

  final Color? scrollbarColor;
  final Color scrollbarLeftBorderColor;
  final Color scrollbarTopBorderColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EdgeThemeData &&
          runtimeType == other.runtimeType &&
          headerColor == other.headerColor &&
          headerLeftBorderColor == other.headerLeftBorderColor &&
          headerBottomBorderColor == other.headerBottomBorderColor &&
          summaryColor == other.summaryColor &&
          summaryLeftBorderColor == other.summaryLeftBorderColor &&
          summaryTopBorderColor == other.summaryTopBorderColor &&
          scrollbarColor == other.scrollbarColor &&
          scrollbarLeftBorderColor == other.scrollbarLeftBorderColor &&
          scrollbarTopBorderColor == other.scrollbarTopBorderColor;

  @override
  int get hashCode =>
      headerColor.hashCode ^
      headerLeftBorderColor.hashCode ^
      headerBottomBorderColor.hashCode ^
      summaryColor.hashCode ^
      summaryLeftBorderColor.hashCode ^
      summaryTopBorderColor.hashCode ^
      scrollbarColor.hashCode ^
      scrollbarLeftBorderColor.hashCode ^
      scrollbarTopBorderColor.hashCode;
}

class EdgeThemeDataDefaults {
  static const Color headerColor = Color(0xFFE0E0E0);
  static const Color headerLeftBorderColor = Colors.grey;
  static const Color headerBottomBorderColor = Colors.grey;

  static const Color summaryColor = Color(0xFFE0E0E0);
  static const Color summaryLeftBorderColor = Colors.grey;
  static const Color summaryTopBorderColor = Colors.grey;

  static const Color scrollbarColor = Color(0xFFE0E0E0);
  static const Color scrollbarLeftBorderColor = Colors.grey;
  static const Color scrollbarTopBorderColor = Colors.grey;
}
