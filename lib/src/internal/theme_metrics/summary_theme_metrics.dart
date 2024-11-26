import 'package:davi/src/internal/theme_metrics/header_cell_theme_metrics.dart';
import 'package:davi/src/theme/header_theme_data.dart';
import 'package:davi/src/theme/summary_theme_data.dart';
import 'package:meta/meta.dart';

/// Stores summary theme values that change the table layout.
@internal
class SummaryThemeMetrics {
  SummaryThemeMetrics({required SummaryThemeData themeData})
      : height = themeData.height;

  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryThemeMetrics &&
          runtimeType == other.runtimeType &&
          height == other.height;

  @override
  int get hashCode => height.hashCode;
}
