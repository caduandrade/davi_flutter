import 'package:easy_table/src/internal/theme_metrics/header_cell_theme_metrics.dart';
import 'package:easy_table/src/theme/header_theme_data.dart';

/// Stores header theme values that change the table layout.
class HeaderThemeMetrics {
  HeaderThemeMetrics(
      {required HeaderThemeData headerThemeData,
      required HeaderCellThemeMetrics headerCellThemeMetrics})
      : visible = headerThemeData.visible,
        bottomBorderHeight = headerThemeData.bottomBorderHeight,
        height =
            headerCellThemeMetrics.height + headerThemeData.bottomBorderHeight;

  final bool visible;
  final double bottomBorderHeight;
  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderThemeMetrics &&
          runtimeType == other.runtimeType &&
          visible == other.visible &&
          bottomBorderHeight == other.bottomBorderHeight &&
          height == other.height;

  @override
  int get hashCode =>
      visible.hashCode ^ bottomBorderHeight.hashCode ^ height.hashCode;
}
