import 'package:davi/davi.dart';
import 'package:davi/src/cell_semantics_builder.dart';
import 'package:davi/src/internal/hover_notifier.dart';
import 'package:davi/src/internal/painter_cache.dart';
import 'package:davi/src/internal/text_cell_painter.dart';
import 'package:davi/src/internal/davi_context.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class CellWidget<DATA> extends StatefulWidget {
  CellWidget(
      {super.key,
      required this.data,
      required this.rowIndex,
      required this.columnIndex,
      required this.rowSpan,
      required this.columnSpan,
      required this.column,
      required this.daviContext,
      required this.painterCache})
      : cellListenable = column.cellListenable != null
            ? column.cellListenable!(
                ListenableBuilderParams<DATA>(data: data, rowIndex: rowIndex))
            : null;

  final DATA data;
  final int rowIndex;
  final int columnIndex;
  final int rowSpan;
  final int columnSpan;
  final DaviColumn<DATA> column;
  final DaviContext daviContext;
  final PainterCache<DATA> painterCache;
  final Listenable? cellListenable;

  bool get hovered => rowIndex == daviContext.hoverNotifier.index;

  @override
  State<StatefulWidget> createState() => CellWidgetState<DATA>();
}

@internal
class CellWidgetState<DATA> extends State<CellWidget<DATA>> {
  late int? _hoverIndex;

  @override
  void initState() {
    super.initState();
    final HoverNotifier hoverNotifier = widget.daviContext.hoverNotifier;
    _hoverIndex = hoverNotifier.index;
    hoverNotifier.addListener(_hoverChanged);
    widget.cellListenable?.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(CellWidget<DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daviContext.hoverNotifier !=
        widget.daviContext.hoverNotifier) {
      oldWidget.daviContext.hoverNotifier.removeListener(_hoverChanged);
      _hoverIndex = widget.daviContext.hoverNotifier.index;
      widget.daviContext.hoverNotifier.addListener(_hoverChanged);
    }
    if (oldWidget.cellListenable != widget.cellListenable) {
      oldWidget.cellListenable?.removeListener(_rebuild);
      widget.cellListenable?.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.daviContext.hoverNotifier.removeListener(_hoverChanged);
    widget.cellListenable?.removeListener(_rebuild);
    super.dispose();
  }

  void _hoverChanged() {
    final HoverNotifier hoverNotifier = widget.daviContext.hoverNotifier;
    if (_hoverIndex == null && hoverNotifier.index == widget.rowIndex) {
      // row enter
      setState(() {
        _hoverIndex = hoverNotifier.index;
      });
    }
    if (_hoverIndex == widget.rowIndex &&
        hoverNotifier.index != widget.rowIndex) {
      // row exit
      setState(() {
        _hoverIndex = null;
      });
    }
  }

  void _rebuild() {
    setState(() {
      // just rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);

    EdgeInsets? padding = theme.cell.padding;
    padding = widget.column.cellPadding ?? padding;

    Alignment alignment = theme.cell.alignment;
    alignment = widget.column.cellAlignment ?? alignment;

    TextStyle? textStyle;
    if (widget.column.cellTextStyle != null) {
      TextStyleBuilderParams<DATA> params = TextStyleBuilderParams(
          data: widget.data,
          rowIndex: widget.rowIndex,
          hovered: widget.hovered);
      textStyle = widget.column.cellTextStyle!(params);
    }
    textStyle = textStyle ?? theme.cell.textStyle;

    Widget? child;
    dynamic value;
    bool textCell = false;
    if (widget.column.cellValue != null) {
      textCell = true;
      final ValueMapperParams<DATA> params =
          ValueMapperParams(data: widget.data, rowIndex: widget.rowIndex);
      value = widget.column.cellValue!(params);
    } else if (widget.column.cellIcon != null) {
      textCell = true;
      final IconMapperParams<DATA> params =
          IconMapperParams(data: widget.data, rowIndex: widget.rowIndex);
      CellIcon? cellIcon = widget.column.cellIcon!(params);
      if (cellIcon != null) {
        value = String.fromCharCode(cellIcon.icon.codePoint);
        textStyle = TextStyle(
            fontSize: cellIcon.size,
            fontFamily: cellIcon.icon.fontFamily,
            package: cellIcon.icon.fontPackage,
            color: cellIcon.color);
      }
    } else if (widget.column.cellPainter != null) {
      child = CustomPaint(
          size: Size(widget.column.width, theme.cell.contentHeight),
          painter: _CustomPainter<DATA>(
              data: widget.data, cellPainting: widget.column.cellPainter!));
    } else if (widget.column.cellBarValue != null) {
      final BarValueMapperParams<DATA> params =
          BarValueMapperParams(data: widget.data, rowIndex: widget.rowIndex);
      double? barValue = widget.column.cellBarValue!(params);
      if (barValue != null) {
        child = CustomPaint(
            size: Size(widget.column.width, theme.cell.contentHeight),
            painter: _BarPainter(
                value: barValue,
                text: widget.column.cellBarValueStringify != null
                    ? widget.column.cellBarValueStringify!(params)
                    : null,
                painterCache: widget.painterCache,
                barBackground: widget.column.cellBarStyle?.barBackground ??
                    theme.cell.barStyle.barBackground,
                barForeground: widget.column.cellBarStyle?.barForeground ??
                    theme.cell.barStyle.barForeground,
                textSize: widget.column.cellBarStyle?.textSize ??
                    theme.cell.barStyle.textSize,
                textColor: widget.column.cellBarStyle?.textColor ??
                    theme.cell.barStyle.textColor));
      }
    } else if (widget.column.cellWidget != null) {
      final WidgetBuilderParams<DATA> params = WidgetBuilderParams(
          buildContext: context,
          data: widget.data,
          rowIndex: widget.rowIndex,
          columnIndex: widget.columnIndex,
          rebuildCallback: _rebuild);
      child = widget.column.cellWidget!(params);
    }

    if (textCell && value != null) {
      child = TextCellPainter(
          text: widget.column.cellValueStringify(value),
          rowSpan: widget.rowSpan,
          columnSpan: widget.columnSpan,
          painterCache: widget.painterCache,
          textStyle: textStyle);
    }

    if (widget.daviContext.semanticsEnabled &&
        widget.column.semanticsBuilder != null) {
      SemanticsBuilderParams<DATA> params = SemanticsBuilderParams(
          context: context,
          data: widget.data,
          rowIndex: widget.rowIndex,
          hovered: widget.hovered);
      child = Semantics.fromProperties(
          properties: widget.column.semanticsBuilder!(params), child: child);
    }

    child = Padding(padding: padding ?? EdgeInsets.zero, child: child);
    child = Align(alignment: alignment, child: child);

    // Always keep some color to avoid parent markNeedsLayout
    Color background = Colors.transparent;
    if (textCell && value == null && theme.cell.nullValueColor != null) {
      background = theme.cell.nullValueColor!(widget.rowIndex,
              widget.rowIndex == widget.daviContext.hoverNotifier.index) ??
          background;
    } else if (widget.column.cellBackground != null) {
      BackgroundBuilderParams<DATA> params = BackgroundBuilderParams(
          data: widget.data,
          rowIndex: widget.rowIndex,
          hovered: widget.hovered);
      background = widget.column.cellBackground!(params) ?? background;
    }
    child = Container(color: background, child: child);

    if (widget.column.cellClip) {
      child = ClipRect(child: child);
    }

    double focusOrder =
        ((widget.rowIndex * widget.daviContext.model.columnsLength) +
                widget.columnIndex)
            .toDouble();
    return FocusTraversalOrder(
        order: NumericFocusOrder(focusOrder), child: child);
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
      {required double value,
      required this.painterCache,
      required this.barForeground,
      required this.barBackground,
      required this.textColor,
      required this.text,
      required this.textSize})
      : value = value.clamp(0, 1);

  final double value;
  final String? text;
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
          value: text ?? '${(value * 100).truncate()}%',
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
