import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Default cell. Used by automatic cell builder.
@internal
class EasyTableCell extends StatelessWidget {
  /// Builds a cell.
  const EasyTableCell(
      {Key? key,
      required this.child,
      required this.padding,
      required this.alignment,
      required this.background})
      : super(key: key);

  final Widget? child;
  final EdgeInsets? padding;
  final Alignment? alignment;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    Widget? widget = child;

    EasyTableThemeData theme = EasyTableTheme.of(context);

    widget = Align(child: widget, alignment: alignment ?? theme.cell.alignment);
    EdgeInsetsGeometry? p = padding ?? theme.cell.padding;
    if (p != null) {
      widget = Padding(padding: p, child: widget);
    }
    if (background != null) {
      widget = Container(child: widget, color: background);
    }

    return widget;
  }
}
