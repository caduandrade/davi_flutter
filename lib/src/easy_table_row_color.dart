import 'package:flutter/material.dart';

typedef EasyTableRowColor<ROW_VALUE> = Color? Function(
    ROW_VALUE rowValue, int rowIndex);

class RowColors {
  static EasyTableRowColor evenOdd({Color? evenColor, Color? oddColor}) {
    return (rowValue, rowIndex) {
      evenColor = evenColor ?? Colors.white;
      oddColor = oddColor ?? Colors.grey[100];
      return rowIndex.isOdd ? evenColor : oddColor;
    };
  }
}
