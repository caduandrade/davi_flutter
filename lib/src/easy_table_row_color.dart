import 'package:flutter/material.dart';

typedef EasyTableRowColor<ROW> = Color? Function(ROW row, int rowIndex);

class RowColors {
  static EasyTableRowColor evenOdd({Color? evenColor, Color? oddColor}) {
    return (row, rowIndex) {
      evenColor = evenColor ?? Colors.white;
      oddColor = oddColor ?? Colors.grey[100];
      return rowIndex.isOdd ? evenColor : oddColor;
    };
  }
}
