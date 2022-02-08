import 'package:flutter/material.dart';

typedef EasyTableRowColor = Color? Function(int rowIndex);

class RowColors {
  static EasyTableRowColor evenOdd({Color? evenColor, Color? oddColor}) {
    return (rowIndex) {
      evenColor = evenColor ?? Colors.white;
      oddColor = oddColor ?? Colors.grey[100];
      return rowIndex.isOdd ? evenColor : oddColor;
    };
  }
}
