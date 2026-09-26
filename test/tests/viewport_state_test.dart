import 'package:davi/davi.dart';
import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/row_extent_manager.dart';
import 'package:davi/src/internal/viewport_state.dart';
import 'package:flutter_test/flutter_test.dart';

DaviModel<int> buildModel({required int rowCount, required int columnCount}) {
  List<int> rows = List.generate(rowCount, (index) => index);
  List<DaviColumn<int>> columns =
      List.generate(columnCount, (index) => DaviColumn(id: 'c$index'));
  return DaviModel(rows: rows, columns: columns);
}

RowExtentManager buildExtentManager(
    {required int rowsLength,
    required double cellHeight,
    required double dividerThickness}) {
  final manager = RowExtentManager();
  manager.resize(
      rowsLength: rowsLength,
      estimatedHeight: cellHeight,
      dividerThickness: dividerThickness);
  return manager;
}

void main() {
  test('shrinking a recycled pool keeps every mapping inside the pool', () {
    final model = buildModel(rowCount: 100, columnCount: 3);
    final manager = buildExtentManager(
        rowsLength: 100, cellHeight: 40, dividerThickness: 0);
    final columns = ColumnMetrics.resizable(
        dataSource: model, maxWidth: 500, dividerThickness: 0);
    final viewport = ViewportState<int>();
    addTearDown(manager.dispose);
    addTearDown(viewport.dispose);

    void reset(double offset, double height) => viewport.reset(
        verticalOffset: offset,
        columnsMetrics: columns,
        rowExtentManager: manager,
        maxHeight: height,
        maxWidth: 500,
        dataSource: model,
        hasTrailing: false,
        rowFillHeight: false);

    reset(0, 240);
    reset(120, 240);
    reset(120, 80);

    final mappings = <CellMapping>{
      for (int slot = 0; slot < viewport.maxCellCount; slot++)
        if (viewport.getCellMapping(cellIndex: slot) case final mapping?)
          mapping,
    };
    expect(mappings.length, viewport.mappedCellCount);
    for (int row = viewport.firstRow; row <= viewport.maxDataRowIndex; row++) {
      for (int column = 0; column < model.columnsLength; column++) {
        expect(mappings,
            contains(CellMapping(rowIndex: row, columnIndex: column)));
      }
    }
  });

  group('ViewportState', () {
    test('verticalOffset: 0 - view > model', () {
      const double maxWidth = 500;
      const double maxHeight = 200;

      const double dividerThickness = 10;
      const double cellHeight = 40;

      DaviModel<int> model = buildModel(rowCount: 3, columnCount: 2);

      List<ColumnMetrics> columnsMetrics = ColumnMetrics.resizable(
          dataSource: model, maxWidth: maxWidth, dividerThickness: dividerThickness);
      RowExtentManager rowExtentManager = buildExtentManager(
          rowsLength: model.rowsLength,
          cellHeight: cellHeight,
          dividerThickness: dividerThickness);

      ViewportState<int> viewport = ViewportState();
      viewport.reset(
          verticalOffset: 0,
          columnsMetrics: columnsMetrics,
          rowExtentManager: rowExtentManager,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          dataSource: model,
          hasTrailing: false,
          rowFillHeight: false);

      // testing attributes

      expect(viewport.maxVisibleRowCount, 5);
      expect(viewport.firstRow, 0);
      expect(viewport.lastRow, 4);
      expect(viewport.firstDataRow, 0);
      expect(viewport.maxDataRowIndex, 4);
      expect(viewport.lastDataRow, 2);
      expect(viewport.maxCellCount, 10);

      expect(viewport.mappedCellCount, 6);

      // testing cell mapping

      CellMapping? cellMapping = viewport.getCellMapping(cellIndex: 0);
      expect(cellMapping, isNotNull);
      expect(cellMapping?.rowIndex, 0);

      cellMapping = viewport.getCellMapping(cellIndex: 3);
      expect(cellMapping, isNotNull);
      expect(cellMapping?.rowIndex, 1);

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

    test('verticalOffset: 70 - view < model', () {
      const double maxWidth = 500;
      const double maxHeight = 100;

      const double dividerThickness = 10;
      const double cellHeight = 40;

      DaviModel<int> model = buildModel(rowCount: 5, columnCount: 2);

      List<ColumnMetrics> columnsMetrics = ColumnMetrics.resizable(
          dataSource: model, maxWidth: maxWidth, dividerThickness: dividerThickness);
      RowExtentManager rowExtentManager = buildExtentManager(
          rowsLength: model.rowsLength,
          cellHeight: cellHeight,
          dividerThickness: dividerThickness);

      ViewportState<int> viewport = ViewportState();
      viewport.reset(
          verticalOffset: 70,
          columnsMetrics: columnsMetrics,
          rowExtentManager: rowExtentManager,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          dataSource: model,
          hasTrailing: false,
          rowFillHeight: false);

      // testing view attributes

      expect(viewport.maxVisibleRowCount, 3);
      expect(viewport.firstRow, 1);
      expect(viewport.lastRow, 3);
      expect(viewport.firstDataRow, 1);
      expect(viewport.maxDataRowIndex, 3);
      expect(viewport.lastDataRow, 3);
      expect(viewport.maxCellCount, 6);
      expect(viewport.mappedCellCount, 6);

      // testing cell mapping

      CellMapping? cellMapping = viewport.getCellMapping(cellIndex: 0);
      expect(cellMapping, isNotNull);
      expect(cellMapping?.rowIndex, 1);
      expect(cellMapping?.columnIndex, 0);

      cellMapping = viewport.getCellMapping(cellIndex: 3);
      expect(cellMapping, isNotNull);
      expect(cellMapping?.rowIndex, 2);
      expect(cellMapping?.columnIndex, 1);

      // testing row regions

      expect(viewport.rowRegions.trailingRegion, isNull);
      expect(viewport.rowRegions.firstRowIndex, 1);
      expect(viewport.rowRegions.lastRowIndex, 3);
      expect(viewport.rowRegions.values.length, 3);

      RowRegion rowRegion = viewport.rowRegions.get(1);
      expect(rowRegion.index, 1);
      expect(rowRegion.visible, true);
      expect(rowRegion.hasData, true);
      expect(rowRegion.trailing, false);
      expect(rowRegion.bounds.top, -20);
      expect(rowRegion.bounds.bottom, 20);
    });
  });

  test(
      'sub-row-height scroll deltas skip the expensive cell mapping rebuild '
      'but keep row region positions live', () {
    const double maxWidth = 500;
    const double maxHeight = 200;

    const double dividerThickness = 10;
    const double cellHeight = 40;
    const double rowHeight = cellHeight + dividerThickness;

    DaviModel<int> model = buildModel(rowCount: 20, columnCount: 2);

    List<ColumnMetrics> columnsMetrics = ColumnMetrics.resizable(
        dataSource: model, maxWidth: maxWidth, dividerThickness: dividerThickness);
    RowExtentManager rowExtentManager = buildExtentManager(
        rowsLength: model.rowsLength,
        cellHeight: cellHeight,
        dividerThickness: dividerThickness);

    ViewportState<int> viewport = ViewportState();
    void reset(double verticalOffset) {
      viewport.reset(
          verticalOffset: verticalOffset,
          columnsMetrics: columnsMetrics,
          rowExtentManager: rowExtentManager,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          dataSource: model,
          hasTrailing: false,
          rowFillHeight: false);
    }

    reset(0);
    final CellMapping firstMapping = viewport.getCellMapping(cellIndex: 0)!;
    final RowRegion firstRowRegionBefore = viewport.rowRegions.get(0);
    expect(firstRowRegionBefore.bounds.top, 0);

    // A small scroll delta that stays within the same row window: the cell
    // mapping must be left untouched (same instance, no rebuild)...
    reset(5);
    final CellMapping mappingAfterSmallScroll =
        viewport.getCellMapping(cellIndex: 0)!;
    expect(identical(firstMapping, mappingAfterSmallScroll), isTrue);
    // ...but the row region position must still track the live offset.
    final RowRegion firstRowRegionAfter = viewport.rowRegions.get(0);
    expect(firstRowRegionAfter.bounds.top, -5);

    // A scroll delta large enough to change the first visible row must
    // rebuild the mapping (new instance, updated content).
    reset(rowHeight * 3);
    expect(viewport.firstDataRow, 3);
    final CellMapping mappingAfterBigScroll =
        viewport.getCellMapping(cellIndex: 0)!;
    expect(identical(firstMapping, mappingAfterBigScroll), isFalse);
    expect(mappingAfterBigScroll.rowIndex, isNot(0));
  });
}
