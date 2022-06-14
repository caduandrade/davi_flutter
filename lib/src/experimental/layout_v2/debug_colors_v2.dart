import 'package:easy_table/src/experimental/column_pin.dart';
import 'package:flutter/material.dart';

class DebugColorsV2 {
  static Color headerArea(ColumnPin contentAreaId) {
    switch (contentAreaId) {
      case ColumnPin.leftPinned:
        return Colors.yellow[200]!.withOpacity(.4);
      case ColumnPin.unpinned:
        return Colors.lime[200]!.withOpacity(.4);
      case ColumnPin.rightPinned:
        return Colors.orange[200]!.withOpacity(.4);
    }
  }

  static Color horizontalScrollbarArea(ColumnPin contentAreaId) {
    switch (contentAreaId) {
      case ColumnPin.leftPinned:
        return Colors.yellow[300]!.withOpacity(.4);
      case ColumnPin.unpinned:
        return Colors.lime[300]!.withOpacity(.4);
      case ColumnPin.rightPinned:
        return Colors.orange[300]!.withOpacity(.4);
    }
  }
}
