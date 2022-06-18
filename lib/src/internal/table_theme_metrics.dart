import 'package:easy_table/src/theme/theme_data.dart';
import 'package:meta/meta.dart';

@internal
class TableThemeMetrics<ROW> {
  factory TableThemeMetrics(EasyTableThemeData theme) {
    final bool hasHeader = theme.header.visible;
    final double cellHeight = theme.cell.contentHeight +
        ((theme.cell.padding != null) ? theme.cell.padding!.vertical : 0);
    final double rowHeight = cellHeight + theme.row.dividerThickness;
    final double headerCellHeight = theme.headerCell.height;
    final double headerHeight =
        headerCellHeight + theme.header.bottomBorderHeight;
    final double scrollbarWidth =
        theme.scrollbar.borderThickness + theme.scrollbar.thickness;
    final double scrollbarHeight =
        theme.scrollbar.borderThickness + theme.scrollbar.thickness;
    final double columnDividerThickness = theme.columnDividerThickness;
    final double rowDividerThickness = theme.row.dividerThickness;

    // Calculating the hashCode in advance. Will save 1 ms while scrolling ;-)

    final int hashCode = hasHeader.hashCode ^
        rowHeight.hashCode ^
        headerHeight.hashCode ^
        headerCellHeight.hashCode ^
        scrollbarWidth.hashCode ^
        scrollbarHeight.hashCode ^
        cellHeight.hashCode ^
        columnDividerThickness.hashCode ^
        rowDividerThickness.hashCode;

    return TableThemeMetrics._(
        hasHeader: hasHeader,
        rowHeight: rowHeight,
        headerCellHeight: headerCellHeight,
        headerHeight: headerHeight,
        scrollbarWidth: scrollbarWidth,
        scrollbarHeight: scrollbarHeight,
        cellHeight: cellHeight,
        columnDividerThickness: columnDividerThickness,
        rowDividerThickness: rowDividerThickness,
        hashCode: hashCode);
  }

  TableThemeMetrics._(
      {required this.hasHeader,
      required this.rowHeight,
      required this.headerCellHeight,
      required this.headerHeight,
      required this.scrollbarWidth,
      required this.scrollbarHeight,
      required this.cellHeight,
      required this.columnDividerThickness,
      required this.rowDividerThickness,
      required this.hashCode});

  final bool hasHeader;
  final double rowHeight;
  final double headerCellHeight;
  final double headerHeight;
  final double scrollbarWidth;
  final double scrollbarHeight;
  final double cellHeight;
  final double columnDividerThickness;
  final double rowDividerThickness;

  @override
  final int hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableThemeMetrics &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;
}
