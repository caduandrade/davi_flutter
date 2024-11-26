import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';

class SummaryWidget<DATA> extends StatelessWidget {
  const SummaryWidget({Key? key, required this.daviContext}) : super(key: key);

  final DaviContext<DATA> daviContext;

  @override
  Widget build(BuildContext context) {
    if (daviContext.model.isColumnsEmpty) {
      return Container();
    }
    DaviThemeData theme = DaviTheme.of(context);

    Color? color = theme.summary.color;
    BoxBorder? border;
    if (theme.summary.topBorderThickness > 0 &&
        theme.summary.topBorderColor != null) {
      border = Border(
          top: BorderSide(
              width: theme.summary.topBorderThickness,
              color: theme.summary.topBorderColor!));
    }

    if (color != null || border != null) {
      return Container(
        decoration: BoxDecoration(border: border, color: color),
      );
    }
    return Container();
  }
}
