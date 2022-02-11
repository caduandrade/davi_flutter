import 'package:easy_table/src/theme/easy_table_theme.dart';
import 'package:easy_table/src/theme/easy_table_theme_data.dart';
import 'package:flutter/widgets.dart';

/// Default header cell
class EasyTableHeaderCell extends StatelessWidget {
  /// Builds a header cell.
  const EasyTableHeaderCell(
      {Key? key, this.child, this.value, this.padding, this.alignment})
      : super(key: key);

  final Widget? child;
  final String? value;

  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    Widget? widget = child;

    EasyTableThemeData theme = EasyTableTheme.of(context);

    TextStyle? textStyle = theme.headerCell.textStyle;

    if (value != null) {
      widget = Text(value!, overflow: TextOverflow.ellipsis, style: textStyle);
    }

    widget = widget ?? Container();

    widget = Align(
        child: widget, alignment: alignment ?? theme.headerCell.alignment);
    EdgeInsetsGeometry? p = padding ?? theme.headerCell.padding;
    if (p != null) {
      widget = Padding(padding: p, child: widget);
    }

    return widget;
  }
}
