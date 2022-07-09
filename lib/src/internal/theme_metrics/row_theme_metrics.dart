import 'package:easy_table/src/internal/theme_metrics/cell_theme_metrics.dart';

import 'package:easy_table/src/theme/row_theme_data.dart';

/// Stores row theme values that change the table layout.
class RowThemeMetrics {
  RowThemeMetrics(
      {required RowThemeData themeData,
      required CellThemeMetrics cellThemeMetrics})
      : dividerThickness = themeData.dividerThickness,
        height = themeData.dividerThickness + cellThemeMetrics.height;

  final double dividerThickness;
  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowThemeMetrics &&
          runtimeType == other.runtimeType &&
          dividerThickness == other.dividerThickness &&
          height == other.height;

  @override
  int get hashCode => dividerThickness.hashCode ^ height.hashCode;
}
