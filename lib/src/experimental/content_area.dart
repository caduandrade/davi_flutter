import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:flutter/material.dart';

class ContentArea {
  ContentArea(
      {required this.id, required this.bounds, required this.layoutSettings});

  final ContentAreaId id;
  final Rect bounds;
  final TableLayoutSettings layoutSettings;

  void paintDebugAreas({required Canvas canvas}) {
    if (layoutSettings.hasHeader) {
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = headerAreaDebugColor;
      canvas.drawRect(
          Rect.fromLTWH(bounds.left, bounds.top, bounds.width,
              layoutSettings.headerHeight),
          paint);
    }

    if (layoutSettings.hasScrollbar) {
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = scrollbarAreaDebugColor;
      canvas.drawRect(
          Rect.fromLTWH(
              bounds.left,
              bounds.bottom - layoutSettings.scrollbarHeight,
              bounds.width,
              layoutSettings.scrollbarHeight),
          paint);
    }
  }

  Color get headerAreaDebugColor {
    switch (id) {
      case ContentAreaId.leftPinned:
        return Colors.yellow;
      case ContentAreaId.rightPinned:
        return Colors.orangeAccent;
      case ContentAreaId.unpinned:
        return Colors.lime;
    }
  }

  Color get scrollbarAreaDebugColor {
    switch (id) {
      case ContentAreaId.leftPinned:
        return Colors.yellow;
      case ContentAreaId.rightPinned:
        return Colors.orangeAccent;
      case ContentAreaId.unpinned:
        return Colors.lime;
    }
  }
}
