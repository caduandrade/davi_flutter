class TableLayoutSettings {
  TableLayoutSettings(
      {required this.visibleRowsCount,
      required this.rowHeight,
      required this.hasHeader,
      required this.headerHeight,
      required this.hasScrollbar,
      required this.scrollbarHeight});

  final int? visibleRowsCount;
  final double rowHeight;
  final bool hasHeader;
  final double headerHeight;
  final bool hasScrollbar;
  final double scrollbarHeight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableLayoutSettings &&
          runtimeType == other.runtimeType &&
          visibleRowsCount == other.visibleRowsCount &&
          rowHeight == other.rowHeight &&
          hasHeader == other.hasHeader &&
          headerHeight == other.headerHeight &&
          hasScrollbar == other.hasScrollbar &&
          scrollbarHeight == other.scrollbarHeight;

  @override
  int get hashCode =>
      visibleRowsCount.hashCode ^
      rowHeight.hashCode ^
      hasHeader.hashCode ^
      headerHeight.hashCode ^
      hasScrollbar.hashCode ^
      scrollbarHeight.hashCode;
}
