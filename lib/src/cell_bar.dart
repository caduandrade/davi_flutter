import 'package:flutter/material.dart';

/// Represents the style configuration for a cell bar value.
///
/// This class is used to customize the appearance of the bar, including
/// the background, foreground, text color, and text size.
class CellBarStyle {
  /// The background color of the bar.
  ///
  /// This color represents the portion of the bar that is not filled, indicating
  /// the remaining progress.
  final Color barBackground;

  /// A function that returns a color for the bar's foreground based on
  /// the current progress value (ranging from 0.0 to 1.0).
  ///
  /// This determines the color of the filled portion of the bar, reflecting the value.
  final CellBarColor barForeground;

  /// A function that returns the color for the text displayed on the progress bar
  /// based on the current progress value.
  ///
  /// This allows for dynamic text color changes as the progress changes.
  final CellBarColor textColor;

  /// The size of the text displayed.
  final double textSize;

  /// Creates a [CellBarStyle] object with the given properties.
  ///
  /// [barBackground] specifies the background color of the bar.
  /// [barForeground] defines the color of the foreground based on the value.
  /// [textColor] determines the color of the text based on the value.
  /// [textSize] defines the size of the text.
  const CellBarStyle({
    required this.barBackground,
    required this.barForeground,
    required this.textColor,
    required this.textSize,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellBarStyle &&
          runtimeType == other.runtimeType &&
          barBackground == other.barBackground &&
          barForeground == other.barForeground &&
          textColor == other.textColor &&
          textSize == other.textSize;

  @override
  int get hashCode =>
      barBackground.hashCode ^
      barForeground.hashCode ^
      textColor.hashCode ^
      textSize.hashCode;
}

/// A function type that takes a [double] value (representing value, between 0.0 and 1.0)
/// and returns a [Color] value.
///
/// This function is used to dynamically determine the color of the foreground or text
/// based on the current value.
typedef CellBarColor = Color Function(double value);

/// A typedef for a function that calculates the value for a progress bar,
/// based on the provided data.
///
/// This function receives a [DATA] type (representing a row) and returns
/// a [double] value between 0.0 and 1.0, representing the percentage of
/// the value.
/// It can return `null`, indicating no bar should be displayed for that cell.
typedef CellBarValue<DATA> = double? Function(DATA data, int rowIndex);
