import 'package:easy_table/src/experimental/pin_status.dart';
import 'package:flutter/material.dart';

class DebugColorsV2 {
  static Color headerArea(PinStatus pinStatus) {
    switch (pinStatus) {
      case PinStatus.leftPinned:
        return Colors.yellow[200]!.withOpacity(.4);
      case PinStatus.unpinned:
        return Colors.lime[200]!.withOpacity(.4);
      case PinStatus.rightPinned:
        return Colors.orange[200]!.withOpacity(.4);
    }
  }

  static Color horizontalScrollbarArea(PinStatus pinStatus) {
    switch (pinStatus) {
      case PinStatus.leftPinned:
        return Colors.yellow[300]!.withOpacity(.4);
      case PinStatus.unpinned:
        return Colors.lime[300]!.withOpacity(.4);
      case PinStatus.rightPinned:
        return Colors.orange[300]!.withOpacity(.4);
    }
  }
}
