import 'package:davi/src/theme/cell_theme_data.dart';
import 'package:meta/meta.dart';

/// Stores cell theme values that change the table layout.
@internal
class CellThemeMetrics {
  CellThemeMetrics({required CellThemeData themeData})
      : padding = themeData.padding != null ? themeData.padding!.vertical : 0;

  /// The vertical padding (top + bottom) added around a cell's measured
  /// content height.
  final double padding;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellThemeMetrics &&
          runtimeType == other.runtimeType &&
          padding == other.padding;

  @override
  int get hashCode => padding.hashCode;
}
