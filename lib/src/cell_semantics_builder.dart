import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Signature for a function that builds semantics for a given row.
///
/// Used by [DaviColumn].
typedef DaviCellSemanticsBuilder<DATA> = SemanticsProperties Function(
    SemanticsBuilderParams params);

class SemanticsBuilderParams<DATA> {
  SemanticsBuilderParams(
      {required this.context,
      required this.data,
      required this.rowIndex,
      required this.hovered});

  final BuildContext context;
  final DATA data;
  final int rowIndex;
  final bool hovered;
}
