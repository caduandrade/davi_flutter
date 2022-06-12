import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:flutter/material.dart';

class DebugColors {
  static Color headerArea(ContentAreaId contentAreaId) {
    switch (contentAreaId) {
      case ContentAreaId.leftPinned:
        return Colors.yellow[200]!.withOpacity(.4);
      case ContentAreaId.unpinned:
        return Colors.lime[200]!.withOpacity(.4);
      case ContentAreaId.rightPinned:
        return Colors.orange[200]!.withOpacity(.4);
    }
  }

  static Color horizontalScrollbarArea(ContentAreaId contentAreaId) {
    switch (contentAreaId) {
      case ContentAreaId.leftPinned:
        return Colors.yellow[300]!.withOpacity(.4);
      case ContentAreaId.unpinned:
        return Colors.lime[300]!.withOpacity(.4);
      case ContentAreaId.rightPinned:
        return Colors.orange[300]!.withOpacity(.4);
    }
  }
}
