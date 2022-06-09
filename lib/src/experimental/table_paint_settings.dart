class TablePaintSettings {
  TablePaintSettings({required this.debugAreas});

  final bool debugAreas;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TablePaintSettings &&
          runtimeType == other.runtimeType &&
          debugAreas == other.debugAreas;

  @override
  int get hashCode => debugAreas.hashCode;
}
