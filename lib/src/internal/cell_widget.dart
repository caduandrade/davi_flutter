import 'package:davi/davi.dart';
import 'package:davi/src/internal/new/hover_listenable_builder.dart';
import 'package:davi/src/internal/new/text_cell_painter.dart';
import 'package:davi/src/internal/new/painter_cache.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/new/collision_detector.dart';
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
      required this.collisionDetector})
      : super(key: key);

  final DATA data;
  final int rowIndex;
  final int rowSpan;
  final int columnIndex;
  final int columnSpan;
  final DaviColumn<DATA> column;
  final DaviContext daviContext;
  final PainterCache<DATA> painterCache;
  final CollisionDetector collisionDetector;

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
    final bool intercepts = collisionDetector.intersects(
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
      collisionDetector.add(
          rowIndex: rowIndex,
          columnIndex: columnIndex,
          rowSpan: rowSpan,
          columnSpan: columnSpan);
    }
    return Offstage(offstage: offstage, child: child);
  }

  Widget _builder(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);

    EdgeInsets? padding = theme.cell.padding;
    padding = column.cellPadding ?? padding;

    Alignment alignment = theme.cell.alignment;
    alignment = column.cellAlignment ?? alignment;

    TextStyle? textStyle;
    if (column.cellTextStyle != null) {
      textStyle = column.cellTextStyle!(
          data, rowIndex, rowIndex == daviContext.hoverNotifier.index);
    }
    textStyle = textStyle ?? theme.cell.textStyle;

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
                barBackground: column.cellBarStyle?.barBackground ??
                    theme.cell.barStyle.barBackground,
                barForeground: column.cellBarStyle?.barForeground ??
                    theme.cell.barStyle.barForeground,
                textSize: column.cellBarStyle?.textSize ??
                    theme.cell.barStyle.textSize,
                textColor: column.cellBarStyle?.textColor ??
                    theme.cell.barStyle.textColor));
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
      required this.barForeground,
      required this.barBackground,
      required this.textColor,
      required this.textSize});

  final double value;
  final Color? barBackground;
  final CellBarColor? barForeground;
  final CellBarColor? textColor;
  final double? textSize;
  final PainterCache painterCache;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    if (barBackground != null) {
      paint.color = barBackground!;
      canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
    }

    if (barBackground != null) {
      paint.color = barForeground!(value);
      double width = value * size.width;
      canvas.drawRect(Rect.fromLTRB(0, 0, width, size.height), paint);
    }

    if (textColor != null) {
      TextPainter textPainter = painterCache.getTextPainter(
          width: size.width,
          textStyle: TextStyle(fontSize: textSize, color: textColor!(value)),
          value: '${(value * 100).truncate()}%',
          rowSpan: 1,
          columnSpan: 1);
      final Offset textOffset = Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
