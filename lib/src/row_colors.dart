import 'package:easy_table/src/easy_table.dart';
import 'package:flutter/material.dart';

class RowColors {
  static EasyTableRowColor evenOdd({Color? evenColor, Color? oddColor}) {
    return (rowIndex) {
      evenColor = evenColor ?? Colors.white;
      oddColor = oddColor ?? Colors.grey[100];
      return rowIndex.isOdd ? evenColor : oddColor;
    };
  }
}
