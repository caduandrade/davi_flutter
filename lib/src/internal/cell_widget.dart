import 'package:davi/src/cell_icon.dart';
import 'package:davi/src/column.dart';
import 'package:davi/src/internal/new/cell_painter.dart';
import 'package:davi/src/internal/new/painter_cache.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class CellWidget<DATA> extends StatelessWidget {
  const CellWidget(
      {Key? key,
      required this.data,
      required this.rowIndex,
      required this.rowSpan,
      required this.columnSpan,
      required this.column,
      required this.daviContext,
      required this.painterCache})
      : super(key: key);

  final DATA data;
  final int rowIndex;
  final int rowSpan;
  final int columnSpan;
  final DaviColumn<DATA> column;
  final DaviContext daviContext;
  final PainterCache<DATA> painterCache;

  @override
  Widget build(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);

    // Theme
    EdgeInsets? padding = theme.cell.padding;
    Alignment alignment = theme.cell.alignment;
    TextStyle? textStyle = theme.cell.textStyle;
    // Entire column
    padding = column.cellPadding ?? padding;
    alignment = column.cellAlignment ?? alignment;
    textStyle = column.cellTextStyle ?? textStyle;

    Widget? child;
    String? value;
    bool hasCustomWidget = false;

    if (column.cellValue != null) {
      value = column.cellValue!(data, rowIndex);
    } else if (column.cellIcon != null) {
      CellIcon? cellIcon = column.cellIcon!(data, rowIndex);
      if (cellIcon != null) {
        value = String.fromCharCode(cellIcon.icon.codePoint);
        textStyle = TextStyle(
            fontSize: cellIcon.size,
            fontFamily: cellIcon.icon.fontFamily,
            package: cellIcon.icon.fontPackage,
            color: cellIcon.color);
      }
    } else if (column.cellWidget != null) {
      child = column.cellWidget!(context, data, rowIndex);
      if (child != null) {
        hasCustomWidget = true;
      }
    }

    if (child == null && value != null) {
      child = CellPainter(
          text: value,
          rowSpan: rowSpan,
          columnSpan: columnSpan,
          painterCache: painterCache,
          textStyle: textStyle);
    }

    if (daviContext.semanticsEnabled && column.semanticsBuilder != null) {
      child = Semantics.fromProperties(
          properties: column.semanticsBuilder!(context, data, rowIndex,
              rowIndex == daviContext.hoverNotifier.index),
          child: child);
    }

    child = Padding(padding: padding ?? EdgeInsets.zero, child: child);
    child = Align(alignment: alignment, child: child);

    // Always keep some color to avoid parent markNeedsLayout
    Color background = Colors.transparent;
    if (!hasCustomWidget &&
        value == null &&
        theme.cell.nullValueColor != null) {
      background = theme.cell.nullValueColor!(
              rowIndex, rowIndex == daviContext.hoverNotifier.index) ??
          background;
    } else if (column.cellBackground != null) {
      background = column.cellBackground!(
              data, rowIndex, rowIndex == daviContext.hoverNotifier.index) ??
          background;
    }
    child = Container(color: background, child: child);

    if (column.cellClip) {
      child = ClipRect(child: child);
    }
    return child;
  }
}
