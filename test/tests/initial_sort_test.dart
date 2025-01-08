import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DaviModel', () {
    group('Initial sort', () {
      test('Model without column', () {
        noColumn(multiSortEnabled: false, alwaysSorted: true);
        noColumn(multiSortEnabled: true, alwaysSorted: false);
        noColumn(multiSortEnabled: false, alwaysSorted: false);
        noColumn(multiSortEnabled: true, alwaysSorted: true);
      });
      test('Model with 1 column', () {
        oneColumn(
            multiSortEnabled: false,
            alwaysSorted: true,
            isColumnSortable: false,
            expectSortedModel: false);
        oneColumn(
            multiSortEnabled: false,
            alwaysSorted: false,
            isColumnSortable: false,
            expectSortedModel: false);
        oneColumn(
            multiSortEnabled: false,
            alwaysSorted: false,
            isColumnSortable: true,
            expectSortedModel: false);
        oneColumn(
            multiSortEnabled: true,
            alwaysSorted: true,
            isColumnSortable: false,
            expectSortedModel: false);
        oneColumn(
            multiSortEnabled: true,
            alwaysSorted: false,
            isColumnSortable: false,
            expectSortedModel: false);
        oneColumn(
            multiSortEnabled: true,
            alwaysSorted: false,
            isColumnSortable: true,
            expectSortedModel: false);
        oneColumn(
            multiSortEnabled: false,
            alwaysSorted: true,
            isColumnSortable: true,
            expectSortedModel: true);
        oneColumn(
            multiSortEnabled: true,
            alwaysSorted: true,
            isColumnSortable: true,
            expectSortedModel: true);
      });
      test('Model with 2 columns', () {
        twoColumns(
            multiSortEnabled: false,
            alwaysSorted: false,
            isColumn1Sortable: false,
            isColumn2Sortable: false,
            expectSortedColumn: null);
        twoColumns(
            multiSortEnabled: false,
            alwaysSorted: false,
            isColumn1Sortable: false,
            isColumn2Sortable: true,
            expectSortedColumn: null);
        twoColumns(
            multiSortEnabled: false,
            alwaysSorted: false,
            isColumn1Sortable: true,
            isColumn2Sortable: false,
            expectSortedColumn: null);
        twoColumns(
            multiSortEnabled: false,
            alwaysSorted: true,
            isColumn1Sortable: false,
            isColumn2Sortable: false,
            expectSortedColumn: null);
        twoColumns(
            multiSortEnabled: true,
            alwaysSorted: false,
            isColumn1Sortable: false,
            isColumn2Sortable: false,
            expectSortedColumn: null);
        twoColumns(
            multiSortEnabled: false,
            alwaysSorted: false,
            isColumn1Sortable: true,
            isColumn2Sortable: true,
            expectSortedColumn: null);
        twoColumns(
            multiSortEnabled: false,
            alwaysSorted: true,
            isColumn1Sortable: true,
            isColumn2Sortable: false,
            expectSortedColumn: 1);
        twoColumns(
            multiSortEnabled: true,
            alwaysSorted: true,
            isColumn1Sortable: false,
            isColumn2Sortable: false,
            expectSortedColumn: null);
        twoColumns(
            multiSortEnabled: false,
            alwaysSorted: true,
            isColumn1Sortable: false,
            isColumn2Sortable: true,
            expectSortedColumn: 2);
        twoColumns(
            multiSortEnabled: true,
            alwaysSorted: false,
            isColumn1Sortable: true,
            isColumn2Sortable: false,
            expectSortedColumn: null);
        twoColumns(
            multiSortEnabled: false,
            alwaysSorted: true,
            isColumn1Sortable: true,
            isColumn2Sortable: true,
            expectSortedColumn: 1);
        twoColumns(
            multiSortEnabled: true,
            alwaysSorted: true,
            isColumn1Sortable: true,
            isColumn2Sortable: false,
            expectSortedColumn: 1);
        twoColumns(
            multiSortEnabled: true,
            alwaysSorted: false,
            isColumn1Sortable: false,
            isColumn2Sortable: true,
            expectSortedColumn: null);
        twoColumns(
            multiSortEnabled: true,
            alwaysSorted: true,
            isColumn1Sortable: true,
            isColumn2Sortable: true,
            expectSortedColumn: 1);
      });
    });
  });
}

List<int> get _rows => List<int>.generate(5, (i) => i + 1);

/// Testing model without column
void noColumn({required bool multiSortEnabled, required bool alwaysSorted}) {
  DaviModel model = DaviModel(
      rows: _rows,
      columns: [],
      multiSortEnabled: multiSortEnabled,
      alwaysSorted: alwaysSorted);
  expect(model.isSorted, false);
  expect(model.isMultiSorted, false);
  expect(model.sortedColumns.length, 0);
}

/// Testing model with 1 column
void oneColumn(
    {required bool multiSortEnabled,
    required bool alwaysSorted,
    required bool isColumnSortable,
    required bool expectSortedModel}) {
  DaviModel<int> model = DaviModel(
      rows: _rows,
      columns: [
        DaviColumn<int>(id: 'id', name: 'name', sortable: isColumnSortable)
      ],
      multiSortEnabled: multiSortEnabled,
      alwaysSorted: alwaysSorted);
  expect(model.isSorted, expectSortedModel);
  expect(model.isMultiSorted, false);
  if (expectSortedModel) {
    expect(model.sortedColumns.length, 1);
    expect(model.sortedColumns.first.name, 'name');
    expect(model.sortedColumns.first.sortDirection, isNotNull);
    expect(model.sortedColumns.first.sortPriority, 1);
    expect(
        model.sortedColumns.first.sortDirection, DaviSortDirection.ascending);
  } else {
    expect(model.sortedColumns.length, 0);
  }
}

/// Testing model with 2 columns
void twoColumns(
    {required bool multiSortEnabled,
    required bool alwaysSorted,
    required bool isColumn1Sortable,
    required bool isColumn2Sortable,
    required int? expectSortedColumn}) {
  DaviModel<int> model = DaviModel(
      rows: _rows,
      columns: [
        DaviColumn<int>(id: 'id1', name: 'name1', sortable: isColumn1Sortable),
        DaviColumn<int>(id: 'id2', name: 'name2', sortable: isColumn2Sortable)
      ],
      multiSortEnabled: multiSortEnabled,
      alwaysSorted: alwaysSorted);
  expect(model.isMultiSorted, false);
  if (expectSortedColumn == null) {
    expect(model.isSorted, false);
    expect(model.sortedColumns.length, 0);
  } else {
    expect(model.isSorted, true);
    expect(model.sortedColumns.length, 1);
    expect(model.sortedColumns.first.sortDirection, isNotNull);
    expect(model.sortedColumns.first.sortPriority, 1);
    expect(
        model.sortedColumns.first.sortDirection, DaviSortDirection.ascending);
    if (expectSortedColumn == 1) {
      expect(model.sortedColumns.first.name, 'name1');
    } else if (expectSortedColumn == 2) {
      expect(model.sortedColumns.first.name, 'name2');
    }
  }
}
