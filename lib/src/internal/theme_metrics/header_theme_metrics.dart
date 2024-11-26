import 'package:davi/src/internal/theme_metrics/header_cell_theme_metrics.dart';
import 'package:davi/src/theme/header_theme_data.dart';
import 'package:meta/meta.dart';

/// Stores header theme values that change the table layout.
@internal
class HeaderThemeMetrics {
  HeaderThemeMetrics(
      {required HeaderThemeData headerThemeData,
      required HeaderCellThemeMetrics headerCellThemeMetrics})
      : visible = headerThemeData.visible,
        bottomBorderHeight = headerThemeData.bottomBorderThickness,
        height = headerCellThemeMetrics.height +
            headerThemeData.bottomBorderThickness;

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
