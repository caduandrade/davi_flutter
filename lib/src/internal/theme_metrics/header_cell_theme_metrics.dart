import 'package:easy_table/src/theme/header_cell_theme_data.dart';

/// Stores header cell theme values that change the table layout.
class HeaderCellThemeMetrics {
  HeaderCellThemeMetrics({required HeaderCellThemeData themeData})
      : height = themeData.height;

  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderCellThemeMetrics &&
          runtimeType == other.runtimeType &&
          height == other.height;

  @override
  int get hashCode => height.hashCode;
}
