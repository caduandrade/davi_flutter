import 'package:davi/src/internal/row_extent_manager.dart';
import 'package:davi/src/theme/scrollbar_theme_data.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class TableScrollbar extends StatelessWidget {
  const TableScrollbar(
      {super.key,
      required this.contentSize,
      this.rowExtentManager,
      required this.scrollController,
      required this.axis,
      required this.color,
      required this.borderColor,
      required this.onDragScroll});

  /// The scrollable content's size along [axis]. For the vertical
  /// scrollbar, prefer [rowExtentManager] when given - row content is
  /// measured lazily, so this snapshot value can go stale between rebuilds.
  final double contentSize;

  /// When given (the vertical scrollbar only), the hidden
  /// `SingleChildScrollView` below tracks this directly instead of
  /// [contentSize], so `ScrollPosition.maxScrollExtent` - which mouse-wheel
  /// and keyboard scrolling clamp to - stays in sync with every row-height
  /// correction, not just whenever something else happens to rebuild the
  /// table.
  final RowExtentManager? rowExtentManager;

  final ScrollController scrollController;
  final Axis axis;
  final Color color;
  final Color borderColor;
  final OnDragScroll onDragScroll;

  @override
  Widget build(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);
    TableScrollbarThemeData scrollTheme = theme.scrollbar;
    BoxBorder? border;
    if (theme.scrollbar.borderThickness > 0) {
      if (axis == Axis.horizontal) {
        border = Border(
            top: BorderSide(
                color: borderColor, width: theme.scrollbar.borderThickness));
      } else if (axis == Axis.vertical) {
        border = Border(
            left: BorderSide(
                color: borderColor, width: theme.scrollbar.borderThickness));
      }
    }
    Widget scrollbar = Container(
        decoration: BoxDecoration(color: color, border: border),
        child: Theme(
            data: ThemeData(
                scrollbarTheme: ScrollbarThemeData(
                    crossAxisMargin: scrollTheme.margin,
                    thumbColor:
                        WidgetStateProperty.all(scrollTheme.thumbColor))),
            child: Scrollbar(
                controller: scrollController,
                interactive: true,
                thickness: scrollTheme.thickness,
                radius: scrollTheme.radius,
                thumbVisibility: true,
                child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false, dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.invertedStylus,
                      PointerDeviceKind.trackpad
                    }),
                    child: SingleChildScrollView(
                        dragStartBehavior: DragStartBehavior.down,
                        controller: scrollController,
                        scrollDirection: axis,
                        child: _sizedBox())))));

    return Listener(
        onPointerDown: (event) => onDragScroll(true),
        onPointerUp: (event) => onDragScroll(false),
        child: scrollbar);
  }

  Widget _sizedBox() {
    if (axis == Axis.vertical) {
      final RowExtentManager? manager = rowExtentManager;
      if (manager != null) {
        return ListenableBuilder(
            listenable: manager,
            builder: (context, child) => SizedBox(height: manager.totalHeight));
      }
      return SizedBox(height: contentSize);
    }
    return SizedBox(width: contentSize);
  }
}

typedef OnDragScroll = void Function(bool start);
