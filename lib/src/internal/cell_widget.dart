import 'package:davi/src/cell_icon.dart';
import 'package:davi/src/column.dart';
import 'package:davi/src/internal/new/hover_index.dart';
import 'package:davi/src/row.dart';
import 'package:davi/src/theme/cell_null_color.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class CellWidget<DATA> extends StatelessWidget {
  final int columnIndex;
  final DaviRow<DATA> row;
  final DaviColumn<DATA> column;
  final HoverIndex hoverIndexNotifier;

  const CellWidget(
      {Key? key, required this.row, required this.column, required this.columnIndex, required this.hoverIndexNotifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);

    // Theme
    EdgeInsets? padding = theme.cell.padding;
    Alignment? alignment = theme.cell.alignment;
    TextStyle? textStyle = theme.cell.textStyle;
    TextOverflow? overflow = theme.cell.overflow;
     // Entire column
    padding = column.cellPadding ?? padding;
    alignment = column.cellAlignment ?? alignment;
    textStyle = column.cellTextStyle ?? textStyle;
    overflow = column.cellOverflow ?? overflow;

    bool tryNullValue = false;
    Widget? child;
    if (column.cellBuilder != null) {
      child = column.cellBuilder!(context, row);
    } else if (column.iconValueMapper != null) {
      CellIcon? cellIcon = column.iconValueMapper!(row.data);
      if (cellIcon != null) {
        child = Icon(cellIcon.icon, color: cellIcon.color, size: cellIcon.size);
      }
    } else {
      String? value = _stringValue(column: column, data: row.data);
      if (value != null) {
        child = Text(value,
            overflow: overflow ?? theme.cell.overflow,
            style: textStyle ?? theme.cell.textStyle);
      } else if (theme.cell.nullValueColor != null) {
        tryNullValue=true;
      }
    }
    if (child != null) {
      child = Align(alignment: alignment, child: child);
      if (padding != null) {
        child = Padding(padding: padding, child: child);
      }
    }
    // To avoid the bug that makes a cursor disappear
    // (https://github.com/flutter/flutter/issues/106767),
    // always build a Container with some color.
    child=Container(color: Colors.transparent, child: child);
    child= CustomPaint(painter: _CellBackgroundPainter(nullValueColor: tryNullValue?theme.cell.nullValueColor:null, hoverIndex: hoverIndexNotifier, column: column,    row: row),child: child);

    if (column.cellClip) {
      child = ClipRect(child: child);
    }
    if (column.semanticsBuilder != null) {
      return Semantics.fromProperties(
          properties: column.semanticsBuilder!(context, row), child: child);
    }
    return child;
  }

  String? _stringValue({required DaviColumn<DATA> column, required DATA data}) {
    if (column.stringValueMapper != null) {
      return column.stringValueMapper!(data);
    } else if (column.intValueMapper != null) {
      return column.intValueMapper!(data)?.toString();
    } else if (column.doubleValueMapper != null) {
      final double? doubleValue = column.doubleValueMapper!(data);
      if (doubleValue != null) {
        if (column.fractionDigits != null) {
          return doubleValue.toStringAsFixed(column.fractionDigits!);
        } else {
          return doubleValue.toString();
        }
      }
    } else if (column.objectValueMapper != null) {
      return column.objectValueMapper!(data)?.toString();
    }
    return null;
  }
}

class _CellBackgroundPainter<DATA> extends CustomPainter {
  final DaviRow<DATA> row;
  final DaviColumn<DATA> column;
  final HoverIndex hoverIndex;
  final CellNullColor? nullValueColor;

  _CellBackgroundPainter({required this.row, required this.column, required this.hoverIndex,
  required this.nullValueColor}) : super(repaint: hoverIndex);

  @override
  void paint(Canvas canvas, Size size) {
    Color? background;
    if( nullValueColor!=null) {
      background = nullValueColor!(row.index, row.index==hoverIndex.value);
    } else if(column.cellBackground != null) {
        background=column.cellBackground!(row);
    }
    if(background!=null) {
      final paint = Paint()
        ..color = background;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
