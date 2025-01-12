import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';

/// Applies a [Davi] theme to descendant widgets.
/// See also:
///
///  * [DaviThemeData], which describes the actual configuration of a theme.
class DaviTheme extends StatelessWidget {
  /// Applies the given theme [data] to [child].
  ///
  /// The [data] and [child] arguments must not be null.
  const DaviTheme({
    super.key,
    required this.child,
    required this.data,
  });

  /// Specifies the theme for descendant widgets.
  final DaviThemeData data;

  /// The widget below this widget in the tree.
  final Widget child;

  static const DaviThemeData _defaultTheme = DaviThemeData();

  /// The data from the closest [DaviTheme] instance that encloses the given
  /// context.
  static DaviThemeData of(BuildContext context) {
    final _InheritedTheme? inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<_InheritedTheme>();
    final DaviThemeData data = inheritedTheme?.theme.data ?? _defaultTheme;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedTheme(theme: this, child: child);
  }
}

class _InheritedTheme extends InheritedWidget {
  const _InheritedTheme({
    required this.theme,
    required super.child,
  });

  final DaviTheme theme;

  @override
  bool updateShouldNotify(_InheritedTheme old) => theme.data != old.theme.data;
}
