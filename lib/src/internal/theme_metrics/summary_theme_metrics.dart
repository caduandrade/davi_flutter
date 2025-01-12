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
