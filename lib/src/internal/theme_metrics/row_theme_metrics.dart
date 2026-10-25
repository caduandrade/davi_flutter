import 'package:davi/src/internal/theme_metrics/cell_theme_metrics.dart';
import 'package:davi/src/theme/row_theme_data.dart';
import 'package:meta/meta.dart';

/// Stores row theme values that change the table layout.
@internal
class RowThemeMetrics {
  RowThemeMetrics(
      {required RowThemeData themeData,
      required CellThemeMetrics cellThemeMetrics})
      : dividerThickness = themeData.dividerThickness,
        estimatedHeight = themeData.estimatedHeight + cellThemeMetrics.padding;

  final double dividerThickness;

  /// Row height used before a row's real content has been measured.
  final double estimatedHeight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowThemeMetrics &&
          runtimeType == other.runtimeType &&
          dividerThickness == other.dividerThickness &&
          estimatedHeight == other.estimatedHeight;

  @override
  int get hashCode => dividerThickness.hashCode ^ estimatedHeight.hashCode;
}
