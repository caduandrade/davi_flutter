import 'package:davi/davi.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/row_callbacks.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
@Deprecated('')
class RowRegion<DATA> extends StatelessWidget {
  RowRegion(
      {required this.index,
      required this.data,
      required this.onHover,
      required this.cursor,
      required this.rowCallbacks,
      required this.horizontalScrollOffsets,
      required this.hoverIndexNotifier})
      : super(key: ValueKey<int>(index));

  final DATA data;
  final int index;
  final OnRowHoverListener? onHover;
  final RowCallbacks<DATA> rowCallbacks;
  final RowCursorBuilder<DATA>? cursor;
  final HorizontalScrollOffsets horizontalScrollOffsets;
  final HoverNotifier hoverIndexNotifier;

  @override
  Widget build(BuildContext context) {
    DaviRow<DATA> row = DaviRow(
        data: data, index: index, hovered: hoverIndexNotifier.index == index);

    DaviThemeData theme = DaviTheme.of(context);

    return MouseRegion(
        cursor: _cursor(theme, row),
        child: rowCallbacks.hasCallback
            ? GestureDetector(
                //child: Container(color: Colors.transparent),
                behavior: HitTestBehavior.opaque,
              )
            : null);
  }

  //TODO keep rule
  MouseCursor _cursor(DaviThemeData theme, DaviRow<DATA> row) {
    if (!theme.row.cursorOnTapGesturesOnly || rowCallbacks.hasCallback) {
      MouseCursor? mouseCursor;
      if (cursor != null) {
        mouseCursor = cursor!(row);
      }
      return mouseCursor ?? theme.row.cursor;
    }
    return MouseCursor.defer;
  }



}
