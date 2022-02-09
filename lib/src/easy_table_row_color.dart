import 'package:flutter/material.dart';

/// Signature for a function that defines a row color.
typedef EasyTableRowColor<ROW> = Color? Function(ROW row, int rowIndex);

/// Default row colors rules.
class RowColors {
  static EasyTableRowColor evenOdd({Color? evenColor, Color? oddColor}) {
    return (row, rowIndex) {
      evenColor = evenColor ?? Colors.white;
      oddColor = oddColor ?? Colors.grey[100];
      return rowIndex.isOdd ? evenColor : oddColor;
    };
  }
}
