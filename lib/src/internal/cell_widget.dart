import 'package:davi/davi.dart';
import 'package:davi/src/internal/new/hover_listenable_builder.dart';
import 'package:davi/src/internal/new/text_cell_painter.dart';
import 'package:davi/src/internal/new/painter_cache.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/new/cell_span_cache.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class CellWidget<DATA> extends StatelessWidget {
  const CellWidget(
      {Key? key,
      required this.data,
      required this.rowIndex,
      required this.rowSpan,
      required this.columnIndex,
      required this.columnSpan,
      required this.column,
      required this.daviContext,
      required this.painterCache,
      required this.cellSpanCache})
      : super(key: key);

  final DATA data;
  final int rowIndex;
  final int rowSpan;
  final int columnIndex;
  final int columnSpan;
  final DaviColumn<DATA> column;
  final DaviContext daviContext;
  final PainterCache<DATA> painterCache;
  final CellSpanCache cellSpanCache;

  @override
  Widget build(BuildContext context) {
    Widget child = HoverListenableBuilder(
        rowIndex: rowIndex,
        hoverNotifier: daviContext.hoverNotifier,
        builder: _builder);

    if (daviContext.collisionBehavior == CellCollisionBehavior.overlap) {
      return child;
    }

    bool offstage = false;
    final bool intercepts = cellSpanCache.intersects(
        rowIndex: rowIndex,
        columnIndex: columnIndex,
        rowSpan: rowSpan,
        columnSpan: columnSpan);
    if (intercepts) {
      if (daviContext.collisionBehavior == CellCollisionBehavior.ignore) {
        offstage = true;
      } else if (daviContext.collisionBehavior ==
          CellCollisionBehavior.ignoreAndWarn) {
        offstage = true;
        debugPrint(
            'Collision detected at cell rowIndex: $rowIndex columnIndex: $columnIndex.');
      } else if (daviContext.collisionBehavior ==
          CellCollisionBehavior.overlapAndWarn) {
        debugPrint(
            'Collision detected at cell rowIndex: $rowIndex columnIndex: $columnIndex.');
      } else if (daviContext.collisionBehavior ==
          CellCollisionBehavior.throwException) {
        throw StateError(
            'Collision detected at cell rowIndex: $rowIndex columnIndex: $columnIndex.');
      }
    } else {
      cellSpanCache.add(
          rowIndex: rowIndex,
          columnIndex: columnIndex,
          rowSpan: rowSpan,
          columnSpan: columnSpan);
    }
    return Offstage(offstage: offstage, child: child);
  }

  Widget _builder(BuildContext context) {
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
    dynamic value;
    bool textCell = false;
    if (column.cellValue != null) {
      textCell = true;
      value = column.cellValue!(data, rowIndex);
    } else if (column.cellIcon != null) {
      textCell = true;
      CellIcon? cellIcon = column.cellIcon!(data, rowIndex);
      if (cellIcon != null) {
        value = String.fromCharCode(cellIcon.icon.codePoint);
        textStyle = TextStyle(
            fontSize: cellIcon.size,
            fontFamily: cellIcon.icon.fontFamily,
            package: cellIcon.icon.fontPackage,
            color: cellIcon.color);
      }
    } else if (column.cellPainter != null) {
      child = CustomPaint(
          size: Size(column.width, theme.cell.contentHeight),
          painter: _CustomPainter<DATA>(
              data: data, cellPainting: column.cellPainter!));
    } else if (column.cellBarValue != null) {
      double? barValue = column.cellBarValue!(data, rowIndex);
      if (barValue != null) {
        child = CustomPaint(
            size: Size(column.width, theme.cell.contentHeight),
            painter: _BarPainter(
                value: barValue,
                painterCache: painterCache,
                barStyle: column.cellBarStyle ?? theme.cell.barStyle));
      }
    } else if (column.cellWidget != null) {
      child = column.cellWidget!(context, data, rowIndex);
    }

    if (textCell && value != null) {
      child = TextCellPainter(
          text: column.cellValueStringify(value),
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
    if (textCell && value == null && theme.cell.nullValueColor != null) {
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

class _CustomPainter<DATA> extends CustomPainter {
  _CustomPainter({required this.data, required this.cellPainting});

  final DATA data;
  final CellPainter<DATA> cellPainting;

  @override
  void paint(Canvas canvas, Size size) {
    cellPainting(canvas, size, data);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarPainter extends CustomPainter {
  _BarPainter(
      {required this.value,
      required this.painterCache,
      required this.barStyle});

  final double value;
  final CellBarStyle barStyle;
  final PainterCache painterCache;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = barStyle.barBackground;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
    paint.color = barStyle.barForeground(value);
    double width = value * size.width;

    canvas.drawRect(Rect.fromLTRB(0, 0, width, size.height), paint);

    TextPainter textPainter = painterCache.getTextPainter(
        width: size.width,
        textStyle: TextStyle(
            fontSize: barStyle.textSize, color: barStyle.textColor(value)),
        value: '${(value * 100).truncate()}%',
        rowSpan: 1,
        columnSpan: 1);
    final Offset textOffset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
