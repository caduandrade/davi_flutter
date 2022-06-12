class TablePaintSettings {
  TablePaintSettings({this.debugAreas = false, required this.hoveredRowIndex});

  final bool debugAreas;
  final int? hoveredRowIndex;

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
