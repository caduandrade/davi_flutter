import 'package:easy_table/src/internal/theme_metrics/cell_theme_metrics.dart';
import 'package:easy_table/src/internal/theme_metrics/header_cell_theme_metrics.dart';
import 'package:easy_table/src/internal/theme_metrics/header_theme_metrics.dart';
import 'package:easy_table/src/internal/theme_metrics/row_theme_metrics.dart';
import 'package:easy_table/src/internal/theme_metrics/scrollbar_theme_metrics.dart';
import 'package:easy_table/src/theme/theme_data.dart';

/// Stores theme values that change the table layout.
class TableThemeMetrics {
  factory TableThemeMetrics(EasyTableThemeData themeData) {
    CellThemeMetrics cell = CellThemeMetrics(themeData: themeData.cell);
    HeaderCellThemeMetrics headerCell =
        HeaderCellThemeMetrics(themeData: themeData.headerCell);
    HeaderThemeMetrics header = HeaderThemeMetrics(
        headerThemeData: themeData.header, headerCellThemeMetrics: headerCell);
    RowThemeMetrics row =
        RowThemeMetrics(themeData: themeData.row, cellThemeMetrics: cell);
    TableScrollbarThemeMetrics scrollbar =
        TableScrollbarThemeMetrics(themeData: themeData.scrollbar);

    return TableThemeMetrics._(
        columnDividerThickness: themeData.columnDividerThickness,
        cell: cell,
        header: header,
        headerCell: headerCell,
        row: row,
        scrollbar: scrollbar);
  }

  TableThemeMetrics._(
      {required this.columnDividerThickness,
      required this.cell,
      required this.header,
      required this.headerCell,
      required this.row,
      required this.scrollbar});

  final double columnDividerThickness;
  final CellThemeMetrics cell;
  final HeaderThemeMetrics header;
  final HeaderCellThemeMetrics headerCell;
  final RowThemeMetrics row;
  final TableScrollbarThemeMetrics scrollbar;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableThemeMetrics &&
          runtimeType == other.runtimeType &&
          columnDividerThickness == other.columnDividerThickness &&
          cell == other.cell &&
          header == other.header &&
          headerCell == other.headerCell &&
          row == other.row &&
          scrollbar == other.scrollbar;

  @override
  int get hashCode =>
      columnDividerThickness.hashCode ^
      cell.hashCode ^
      header.hashCode ^
      headerCell.hashCode ^
      row.hashCode ^
      scrollbar.hashCode;
}
