import 'package:easy_table/src/theme/easy_table_theme.dart';
import 'package:easy_table/src/theme/easy_table_theme_data.dart';
import 'package:flutter/widgets.dart';

/// Default cell. Used by automatic cell builder.
class EasyTableCell extends StatelessWidget {
  /// Builds a cell.
  factory EasyTableCell(
      {Key? key,
      required Widget child,
      EdgeInsetsGeometry? padding,
      AlignmentGeometry? alignment}) {
    return EasyTableCell._(
        key: key, child: child, padding: padding, alignment: alignment);
  }

  /// Builds a cell to a [double] value.
  factory EasyTableCell.double(
      {Key? key,
      required double value,
      int? fractionDigits,
      TextStyle? textStyle,
      EdgeInsetsGeometry? padding,
      AlignmentGeometry? alignment}) {
    String? str;
    if (fractionDigits != null) {
      str = value.toStringAsFixed(fractionDigits);
    } else {
      str = value.toString();
    }
    return EasyTableCell._(
        key: key,
        value: str,
        textStyle: textStyle,
        padding: padding,
        alignment: alignment);
  }

  /// Builds a cell to an [int] value.
  factory EasyTableCell.int(
      {Key? key,
      required int value,
      TextStyle? textStyle,
      EdgeInsetsGeometry? padding,
      AlignmentGeometry? alignment}) {
    return EasyTableCell._(
        key: key,
        value: value.toString(),
        textStyle: textStyle,
        padding: padding,
        alignment: alignment);
  }

  /// Builds a cell to a [String] value.
  factory EasyTableCell.string(
      {Key? key,
      required String? value,
      TextStyle? textStyle,
      EdgeInsetsGeometry? padding,
      AlignmentGeometry? alignment}) {
    return EasyTableCell._(
        key: key,
        value: value,
        textStyle: textStyle,
        padding: padding,
        alignment: alignment);
  }

  const EasyTableCell._(
      {Key? key,
      this.value,
      this.textStyle,
      this.child,
      this.padding,
      this.alignment})
      : super(key: key);

  final Widget? child;
  final String? value;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    Widget? widget = child;

    if (value != null) {
      widget = Text(value!, overflow: TextOverflow.ellipsis, style: textStyle);
    }

    widget = widget ?? Container();

    EasyTableThemeData theme = EasyTableTheme.of(context);

    widget = Align(child: widget, alignment: alignment ?? theme.cell.alignment);
    EdgeInsetsGeometry? p = padding ?? theme.cell.padding;
    if (p != null) {
      widget = Padding(padding: p, child: widget);
    }

    return widget;
  }
}
