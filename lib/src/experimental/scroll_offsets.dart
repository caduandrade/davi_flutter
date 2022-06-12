class TableScrollOffsets {
  TableScrollOffsets(
      {required this.leftPinnedContentArea,
      required this.unpinnedContentArea,
      required this.rightPinnedContentArea,
      required this.vertical});

  final double leftPinnedContentArea;
  final double unpinnedContentArea;
  final double rightPinnedContentArea;
  final double vertical;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableScrollOffsets &&
          runtimeType == other.runtimeType &&
          leftPinnedContentArea == other.leftPinnedContentArea &&
          unpinnedContentArea == other.unpinnedContentArea &&
          rightPinnedContentArea == other.rightPinnedContentArea &&
          vertical == other.vertical;

  @override
  int get hashCode =>
      leftPinnedContentArea.hashCode ^
      unpinnedContentArea.hashCode ^
      rightPinnedContentArea.hashCode ^
      vertical.hashCode;
}
