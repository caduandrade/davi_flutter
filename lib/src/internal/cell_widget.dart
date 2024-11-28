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
      required this.column,
      required this.daviContext,
      required this.painterCache})
      : super(key: key);

  final DATA data;
  final int rowIndex;
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
    if (column.cellBuilder != null) {
      hasCustomWidget = true;
      child = column.cellBuilder!(
          context, data, rowIndex, rowIndex == daviContext.hoverNotifier.index);
    } else if (column.iconValue != null) {
      CellIcon? cellIcon = column.iconValue!(data);
      if (cellIcon != null) {
        value = String.fromCharCode(cellIcon.icon.codePoint);
        textStyle = TextStyle(
            fontSize: cellIcon.size,
            fontFamily: cellIcon.icon.fontFamily,
            package: cellIcon.icon.fontPackage,
            color: cellIcon.color);
      }
    } else {
      value = _stringValue(column: column, data: data);
    }

    if (child == null && value != null) {
      child = CellPainter(
          text: value, painterCache: painterCache, textStyle: textStyle);
    }

    if (daviContext.semanticsEnabled && column.semanticsBuilder != null) {
      child = Semantics.fromProperties(
          properties: column.semanticsBuilder!(context, data, rowIndex,
              rowIndex == daviContext.hoverNotifier.index),
          child: child);
    }

    child = Padding(padding: padding ?? EdgeInsets.zero, child: child);
    child = Align(alignment: alignment, child: child);

    Color? background;
    if (!hasCustomWidget &&
        value == null &&
        theme.cell.nullValueColor != null) {
      background = theme.cell.nullValueColor!(
          rowIndex, rowIndex == daviContext.hoverNotifier.index);
    } else if (column.cellBackground != null) {
      background = column.cellBackground!(
          data, rowIndex, rowIndex == daviContext.hoverNotifier.index);
    }
    child = Container(color: background, child: child);

    if (column.cellClip) {
      child = ClipRect(child: child);
    }
    return child;
  }

  String? _stringValue({required DaviColumn<DATA> column, required DATA data}) {
    if (column.stringValue != null) {
      return column.stringValue!(data);
    } else if (column.intValue != null) {
      return column.intValue!(data)?.toString();
    } else if (column.doubleValue != null) {
      final double? doubleValue = column.doubleValue!(data);
      if (doubleValue != null) {
        if (column.fractionDigits != null) {
          return doubleValue.toStringAsFixed(column.fractionDigits!);
        } else {
          return doubleValue.toString();
        }
      }
    } else if (column.objectValue != null) {
      return column.objectValue!(data)?.toString();
    }
    return null;
  }
}
