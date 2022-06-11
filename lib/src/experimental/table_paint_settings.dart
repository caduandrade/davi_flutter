import 'package:easy_table/src/theme/row_color.dart';

class TablePaintSettings {
  TablePaintSettings(
      {this.debugAreas = false,
      required this.hoveredRowIndex,
      required this.hoveredColor});

  final bool debugAreas;
  final int? hoveredRowIndex;
  final EasyTableRowColor? hoveredColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TablePaintSettings &&
          runtimeType == other.runtimeType &&
          debugAreas == other.debugAreas &&
          hoveredRowIndex == other.hoveredRowIndex;

  @override
  int get hashCode => debugAreas.hashCode ^ hoveredRowIndex.hashCode;
}
