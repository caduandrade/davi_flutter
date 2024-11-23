import 'package:davi/src/cell_icon.dart';
import 'package:davi/src/column.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class CellWidget<DATA> extends StatelessWidget {
  final int columnIndex;
  final DATA data;
  final int rowIndex;
  final DaviColumn<DATA> column;
  final HoverNotifier hoverNotifier;

  const CellWidget(
      {Key? key,
      required this.data,
      required this.rowIndex,
      required this.column,
      required this.columnIndex,
      required this.hoverNotifier})
      : super(key: key);

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

    Widget? child;
    if (column.cellBuilder != null) {
      child = column.cellBuilder!(
          context, data, rowIndex, rowIndex == hoverNotifier.index);
    } else if (column.iconValueMapper != null) {
      CellIcon? cellIcon = column.iconValueMapper!(data);
      if (cellIcon != null) {
        child = Icon(cellIcon.icon, color: cellIcon.color, size: cellIcon.size);
      }
    } else {
      String? value = _stringValue(column: column, data: data);
      if (value != null) {
        child = Text(value,
            overflow: overflow ?? theme.cell.overflow,
            style: textStyle ?? theme.cell.textStyle);
      }
    }
    if (child != null) {
      child = Align(alignment: alignment, child: child);
      if (padding != null) {
        child = Padding(padding: padding, child: child);
      }
    }

    if (column.cellClip) {
      child = ClipRect(child: child);
    }
    if (column.semanticsBuilder != null) {
      return Semantics.fromProperties(
          properties: column.semanticsBuilder!(
              context, data, rowIndex, rowIndex == hoverNotifier.index),
          child: child);
    }
    return child ?? Container();
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
