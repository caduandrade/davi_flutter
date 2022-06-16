class RowsLayoutSettings {
  RowsLayoutSettings(
      {required this.firstRowIndex,
        required this.visibleRowsLength,
      required this.verticalOffset,
      required this.dividerThickness,
      required this.cellHeight});

  final int firstRowIndex;
  final int visibleRowsLength;
  final double verticalOffset;
  final double dividerThickness;
  final double cellHeight;

  double get rowHeight => cellHeight + dividerThickness;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowsLayoutSettings &&
          runtimeType == other.runtimeType &&
          firstRowIndex == other.firstRowIndex &&
          visibleRowsLength == other.visibleRowsLength &&
          verticalOffset == other.verticalOffset &&
          dividerThickness == other.dividerThickness &&
          cellHeight == other.cellHeight;

  @override
  int get hashCode =>
      firstRowIndex.hashCode ^
      visibleRowsLength.hashCode ^
      verticalOffset.hashCode ^
      dividerThickness.hashCode ^
      cellHeight.hashCode;
}
