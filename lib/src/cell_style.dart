import 'package:flutter/widgets.dart';

/// Signature for a function that builds a [CellStyle] for a value of a row.
///
/// Used by [EasyTableColumn].
typedef CellStyleBuilder<ROW> = CellStyle? Function(ROW row);

/// Overrides the theme and column style.
class CellStyle {
  CellStyle({this.alignment, this.textStyle, this.background, this.padding});

  final EdgeInsets? padding;
  final Alignment? alignment;
  final TextStyle? textStyle;
  final Color? background;
}
