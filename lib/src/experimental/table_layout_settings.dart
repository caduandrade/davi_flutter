class TableLayoutSettings {
  TableLayoutSettings(
      {required this.visibleRowsCount,
      required this.rowHeight,
      required this.hasHeader,
      required this.headerHeight,
      required this.hasVerticalScrollbar,
      required this.scrollbarSize,
      required this.columnsFit});

  final int? visibleRowsCount;
  final double rowHeight;
  final bool hasHeader;
  final double headerHeight;
  final bool hasVerticalScrollbar;
  final double scrollbarSize;
  final bool columnsFit;

  bool get allowHorizontalScrollbar => !columnsFit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableLayoutSettings &&
          runtimeType == other.runtimeType &&
          visibleRowsCount == other.visibleRowsCount &&
          rowHeight == other.rowHeight &&
          hasHeader == other.hasHeader &&
          headerHeight == other.headerHeight &&
          hasVerticalScrollbar == other.hasVerticalScrollbar &&
          scrollbarSize == other.scrollbarSize &&
          columnsFit == other.columnsFit;

  @override
  int get hashCode =>
      visibleRowsCount.hashCode ^
      rowHeight.hashCode ^
      hasHeader.hashCode ^
      headerHeight.hashCode ^
      hasVerticalScrollbar.hashCode ^
      scrollbarSize.hashCode ^
      columnsFit.hashCode;
}
