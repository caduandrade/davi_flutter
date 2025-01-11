import 'package:davi/davi.dart';
import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/new/viewport_state.dart';
import 'package:flutter_test/flutter_test.dart';

DaviModel<int> buildModel(
    {required int rowCount,
    required int columnCount,
    required int maxRowSpan,
    required int maxColumnSpan}) {
  List<int> rows = List.generate(rowCount, (index) => index);
  List<DaviColumn<int>> columns =
      List.generate(columnCount, (index) => DaviColumn(id: 'c$index'));
  return DaviModel(
      rows: rows, columns: columns, maxRowSpan: maxRowSpan, maxColumnSpan: 1);
}

void main() {
  group('ViewportState', () {
    test('verticalOffset: 0 - maxRowSpan: 2 - view > model', () {
      const double maxWidth = 500;
      const double maxHeight = 200;

      const double dividerThickness = 10;
      const double cellHeight = 40;
      const double rowHeight = cellHeight + dividerThickness;

      DaviModel<int> model = buildModel(
          rowCount: 3, columnCount: 2, maxRowSpan: 2, maxColumnSpan: 1);

      List<ColumnMetrics> columnsMetrics = ColumnMetrics.resizable(
          model: model, maxWidth: maxWidth, dividerThickness: dividerThickness);

      ViewportState<int> viewport = ViewportState();
      viewport.reset(
          verticalOffset: 0,
          columnsMetrics: columnsMetrics,
          rowHeight: rowHeight,
          cellHeight: cellHeight,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          model: model,
          hasTrailing: false,
          rowFillHeight: false,
          collisionBehavior: CellCollisionBehavior.ignore);

      // testing attributes

      expect(viewport.maxVisibleRowCount, 5);
      expect(viewport.firstRow, 0);
      expect(viewport.lastRow, 4);
      expect(viewport.firstDataRow, 0);
      expect(viewport.maxDataRowIndex, 4);
      expect(viewport.lastDataRow, 2);
      expect(viewport.maxCellCount, 12);

      expect(viewport.mappedCellCount, 6);

      // testing cell mapping

      CellMapping? cellMapping = viewport.getCellMapping(cellIndex: 0);
      expect(cellMapping, isNotNull);
      expect(cellMapping?.rowIndex, 0);
      expect(cellMapping?.rowSpan, 1);
      expect(cellMapping?.columnSpan, 1);

      cellMapping = viewport.getCellMapping(cellIndex: 3);
      expect(cellMapping, isNotNull);
      expect(cellMapping?.rowIndex, 1);
      expect(cellMapping?.rowSpan, 1);
      expect(cellMapping?.columnSpan, 1);

      cellMapping = viewport.getCellMapping(cellIndex: 6);
      expect(cellMapping, isNull);

      // testing row regions

      expect(viewport.rowRegions.trailingRegion, isNull);
      expect(viewport.rowRegions.firstRowIndex, 0);
      expect(viewport.rowRegions.lastRowIndex, 4);
      expect(viewport.rowRegions.values.length, 5);

      RowRegion rowRegion = viewport.rowRegions.get(0);
      expect(rowRegion.index, 0);
      expect(rowRegion.visible, true);
      expect(rowRegion.hasData, true);
      expect(rowRegion.trailing, false);
      expect(rowRegion.bounds.top, 0);
      expect(rowRegion.bounds.bottom, 40);

      rowRegion = viewport.rowRegions.get(3);
      expect(rowRegion.index, 3);
      expect(rowRegion.visible, true);
      expect(rowRegion.hasData, false);
      expect(rowRegion.trailing, false);
      expect(rowRegion.bounds.top, 150);
      expect(rowRegion.bounds.bottom, 190);

      rowRegion = viewport.rowRegions.get(4);
      expect(rowRegion.index, 4);
      expect(rowRegion.visible, false);
      expect(rowRegion.hasData, false);
      expect(rowRegion.trailing, false);
      expect(rowRegion.bounds.top, 200);
      expect(rowRegion.bounds.bottom, 240);
    });

    test('verticalOffset: 70 - maxRowSpan: 2 - view < model', () {
      const double maxWidth = 500;
      const double maxHeight = 100;

      const double dividerThickness = 10;
      const double cellHeight = 40;
      const double rowHeight = cellHeight + dividerThickness;

      DaviModel<int> model = buildModel(
          rowCount: 5, columnCount: 2, maxRowSpan: 2, maxColumnSpan: 1);

      List<ColumnMetrics> columnsMetrics = ColumnMetrics.resizable(
          model: model, maxWidth: maxWidth, dividerThickness: dividerThickness);

      ViewportState<int> viewport = ViewportState();
      viewport.reset(
          verticalOffset: 70,
          columnsMetrics: columnsMetrics,
          rowHeight: rowHeight,
          cellHeight: cellHeight,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          model: model,
          hasTrailing: false,
          rowFillHeight: false,
          collisionBehavior: CellCollisionBehavior.ignore);

      // testing view attributes

      expect(viewport.maxVisibleRowCount, 3);
      expect(viewport.firstRow, 0);
      expect(viewport.lastRow, 3);
      expect(viewport.firstDataRow, 1);
      expect(viewport.maxDataRowIndex, 3);
      expect(viewport.lastDataRow, 3);
      expect(viewport.maxCellCount, 8);
      expect(viewport.mappedCellCount, 8);

      // testing cell mapping

      CellMapping? cellMapping = viewport.getCellMapping(cellIndex: 0);
      expect(cellMapping, isNotNull);
      expect(cellMapping?.rowIndex, 0);
      expect(cellMapping?.columnIndex, 0);
      expect(cellMapping?.rowSpan, 1);
      expect(cellMapping?.columnSpan, 1);

      cellMapping = viewport.getCellMapping(cellIndex: 3);
      expect(cellMapping, isNotNull);
      expect(cellMapping?.rowIndex, 1);
      expect(cellMapping?.columnIndex, 1);
      expect(cellMapping?.rowSpan, 1);
      expect(cellMapping?.columnSpan, 1);

      // testing row regions

      expect(viewport.rowRegions.trailingRegion, isNull);
      expect(viewport.rowRegions.firstRowIndex, 0);
      expect(viewport.rowRegions.lastRowIndex, 3);
      expect(viewport.rowRegions.values.length, 4);

      RowRegion rowRegion = viewport.rowRegions.get(0);
      expect(rowRegion.index, 0);
      expect(rowRegion.visible, false);
      expect(rowRegion.hasData, true);
      expect(rowRegion.trailing, false);
      expect(rowRegion.bounds.top, -70);
      expect(rowRegion.bounds.bottom, -30);

      rowRegion = viewport.rowRegions.get(1);
      expect(rowRegion.index, 1);
      expect(rowRegion.visible, true);
      expect(rowRegion.hasData, true);
      expect(rowRegion.trailing, false);
      expect(rowRegion.bounds.top, -20);
      expect(rowRegion.bounds.bottom, 20);
    });
  });

  test('verticalOffset: 70 - maxRowSpan: 2 - view < model - row span', () {
    const double maxWidth = 500;
    const double maxHeight = 100;

    const double dividerThickness = 10;
    const double cellHeight = 40;
    const double rowHeight = cellHeight + dividerThickness;

    List<int> rows = List.generate(10, (index) => index);
    List<DaviColumn<int>> columns = [
      DaviColumn(name: 'c1', rowSpan: (params) => params.rowIndex == 3 ? 3 : 1)
    ];
    DaviModel<int> model = DaviModel(
        rows: rows, columns: columns, maxRowSpan: 3, maxColumnSpan: 1);

    List<ColumnMetrics> columnsMetrics = ColumnMetrics.resizable(
        model: model, maxWidth: maxWidth, dividerThickness: dividerThickness);

    ViewportState<int> viewport = ViewportState();
    viewport.reset(
        verticalOffset: 70,
        columnsMetrics: columnsMetrics,
        rowHeight: rowHeight,
        cellHeight: cellHeight,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        model: model,
        hasTrailing: false,
        rowFillHeight: false,
        collisionBehavior: CellCollisionBehavior.ignore);

    // testing view attributes

    expect(viewport.maxVisibleRowCount, 3);
    expect(viewport.firstRow, 0);
    expect(viewport.lastRow, 3);
    expect(viewport.firstDataRow, 1);
    expect(viewport.maxDataRowIndex, 3);
    expect(viewport.lastDataRow, 3);
    expect(viewport.maxCellCount, 5);
    expect(viewport.mappedCellCount, 4);

    // testing cell mapping

    CellMapping? cellMapping = viewport.getCellMapping(cellIndex: 0);
    expect(cellMapping, isNotNull);
    expect(cellMapping?.rowIndex, 0);
    expect(cellMapping?.columnIndex, 0);
    expect(cellMapping?.rowSpan, 1);
    expect(cellMapping?.columnSpan, 1);

    cellMapping = viewport.getCellMapping(cellIndex: 3);
    expect(cellMapping, isNotNull);
    expect(cellMapping?.rowIndex, 3);
    expect(cellMapping?.columnIndex, 0);
    expect(cellMapping?.rowSpan, 3);
    expect(cellMapping?.columnSpan, 1);

    // testing row regions

    expect(viewport.rowRegions.trailingRegion, isNull);
    expect(viewport.rowRegions.firstRowIndex, 0);
    expect(viewport.rowRegions.lastRowIndex, 3);
    expect(viewport.rowRegions.values.length, 4);

    RowRegion rowRegion = viewport.rowRegions.get(0);
    expect(rowRegion.index, 0);
    expect(rowRegion.visible, false);
    expect(rowRegion.hasData, true);
    expect(rowRegion.trailing, false);
    expect(rowRegion.bounds.top, -70);
    expect(rowRegion.bounds.bottom, -30);

    rowRegion = viewport.rowRegions.get(1);
    expect(rowRegion.index, 1);
    expect(rowRegion.visible, true);
    expect(rowRegion.hasData, true);
    expect(rowRegion.trailing, false);
    expect(rowRegion.bounds.top, -20);
    expect(rowRegion.bounds.bottom, 20);
  });
}
