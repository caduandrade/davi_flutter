import 'package:davi/src/row.dart';
import 'package:flutter/widgets.dart';

/// Signature for a function that builds a [CellStyle] for a row.
///
/// Used by [DaviColumn].
typedef CellStyleBuilder<DATA> = CellStyle? Function(DaviRow<DATA> row);

/// Overrides the theme and column style.
class CellStyle {
  CellStyle(
      {this.alignment,
      this.textStyle,
      this.background,
      this.padding,
      this.overflow});

  final EdgeInsets? padding;
  final Alignment? alignment;
  final TextStyle? textStyle;
  final Color? background;
  final TextOverflow? overflow;
}
