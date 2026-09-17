import 'package:davi/src/theme/header_theme_data.dart';
import 'package:meta/meta.dart';

/// Stores header theme values that change the table layout.
///
/// The header no longer has a fixed height here: [TableLayoutRenderBox]
/// discovers it from the header content's own intrinsic height at layout
/// time.
@internal
class HeaderThemeMetrics {
  HeaderThemeMetrics({required HeaderThemeData headerThemeData})
      : visible = headerThemeData.visible,
        bottomBorderHeight = headerThemeData.bottomBorderThickness;

  final bool visible;
  final double bottomBorderHeight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderThemeMetrics &&
          runtimeType == other.runtimeType &&
          visible == other.visible &&
          bottomBorderHeight == other.bottomBorderHeight;

  @override
  int get hashCode => visible.hashCode ^ bottomBorderHeight.hashCode;
}
