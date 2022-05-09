import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Horizontal layout with gap between children
@internal
class HorizontalLayout extends StatelessWidget {
  const HorizontalLayout(
      {Key? key, required this.columnsMetrics, required this.children})
      : super(key: key);

  final ColumnsMetrics columnsMetrics;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    for (int i = 0; i < children.length; i++) {
      LayoutWidth layoutWidth = columnsMetrics.columns[i];
      children[i] = SizedBox(child: children[i], width: layoutWidth.width);
      if (theme.columnDividerThickness > 0) {
        children[i] = Padding(
            child: children[i],
            padding: EdgeInsets.only(right: theme.columnDividerThickness));
      }
    }
    return Row(
        children: children, crossAxisAlignment: CrossAxisAlignment.stretch);
  }
}
