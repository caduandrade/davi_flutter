import 'package:davi/davi.dart';
import 'package:davi/src/internal/sort_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SortUtil', () {
    group('newSortList', () {
      test('multiSortEnabled: false, alwaysSorted: false', () {
        // shortcut to test
        void t(
            {required List<DaviSort> currentSort,
            required int columnIdToSort,
            required List<DaviSort> expectedNewSort}) {
          testSort(
              multiSortEnabled: false,
              alwaysSorted: false,
              currentSort: currentSort,
              columnIdToSort: columnIdToSort,
              expectedNewSort: expectedNewSort);
        }

        t(
            currentSort: [],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.ascending(1)]);
        t(
            currentSort: [DaviSort.ascending(1)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.descending(1)]);
        t(
            currentSort: [DaviSort.descending(1)],
            columnIdToSort: 1,
            expectedNewSort: []);
        t(
            currentSort: [DaviSort.ascending(1)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.ascending(2)]);
        t(
            currentSort: [DaviSort.descending(1)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.ascending(2)]);
        t(
            currentSort: [DaviSort.descending(1), DaviSort.descending(2)],
            columnIdToSort: 3,
            expectedNewSort: [DaviSort.ascending(3)]);
        t(
            currentSort: [DaviSort.descending(1), DaviSort.descending(2)],
            columnIdToSort: 1,
            expectedNewSort: []);
        t(
            currentSort: [DaviSort.ascending(1), DaviSort.ascending(2)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.descending(1)]);
        t(
            currentSort: [DaviSort.ascending(1), DaviSort.ascending(2)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.descending(2)]);
      });
      test('multiSortEnabled: true, alwaysSorted: false', () {
        // shortcut to test
        void t(
            {required List<DaviSort> currentSort,
            required int columnIdToSort,
            required List<DaviSort> expectedNewSort}) {
          testSort(
              multiSortEnabled: true,
              alwaysSorted: false,
              currentSort: currentSort,
              columnIdToSort: columnIdToSort,
              expectedNewSort: expectedNewSort);
        }

        t(
            currentSort: [],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.ascending(1)]);
        t(
            currentSort: [DaviSort.ascending(1)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.descending(1)]);
        t(
            currentSort: [DaviSort.descending(1)],
            columnIdToSort: 1,
            expectedNewSort: []);
        t(
            currentSort: [DaviSort.ascending(1)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.ascending(1), DaviSort.ascending(2)]);
        t(
            currentSort: [DaviSort.descending(1)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.descending(1), DaviSort.ascending(2)]);
        t(
            currentSort: [DaviSort.descending(1), DaviSort.descending(2)],
            columnIdToSort: 3,
            expectedNewSort: [
              DaviSort.descending(1),
              DaviSort.descending(2),
              DaviSort.ascending(3)
            ]);
        t(
            currentSort: [DaviSort.descending(1), DaviSort.descending(2)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.descending(2)]);
        t(
            currentSort: [DaviSort.ascending(1), DaviSort.ascending(2)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.ascending(2)]);
        t(
            currentSort: [DaviSort.ascending(1), DaviSort.ascending(2)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.ascending(1), DaviSort.descending(2)]);
      });
      test('multiSortEnabled: false, alwaysSorted: true', () {
        // shortcut to test
        void t(
            {required List<DaviSort> currentSort,
            required int columnIdToSort,
            required List<DaviSort> expectedNewSort}) {
          testSort(
              multiSortEnabled: false,
              alwaysSorted: true,
              currentSort: currentSort,
              columnIdToSort: columnIdToSort,
              expectedNewSort: expectedNewSort);
        }

        t(
            currentSort: [],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.ascending(1)]);
        t(
            currentSort: [DaviSort.ascending(1)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.descending(1)]);
        t(
            currentSort: [DaviSort.descending(1)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.ascending(1)]);
        t(
            currentSort: [DaviSort.ascending(1)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.ascending(2)]);
        t(
            currentSort: [DaviSort.descending(1)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.ascending(2)]);
        t(
            currentSort: [DaviSort.descending(1), DaviSort.descending(2)],
            columnIdToSort: 3,
            expectedNewSort: [DaviSort.ascending(3)]);
        t(
            currentSort: [DaviSort.descending(1), DaviSort.descending(2)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.ascending(1)]);
        t(
            currentSort: [DaviSort.ascending(1), DaviSort.ascending(2)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.descending(1)]);
        t(
            currentSort: [DaviSort.ascending(1), DaviSort.ascending(2)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.descending(2)]);
      });
      test('multiSortEnabled: true, alwaysSorted: true', () {
        // shortcut to test
        void t(
            {required List<DaviSort> currentSort,
            required int columnIdToSort,
            required List<DaviSort> expectedNewSort}) {
          testSort(
              multiSortEnabled: true,
              alwaysSorted: true,
              currentSort: currentSort,
              columnIdToSort: columnIdToSort,
              expectedNewSort: expectedNewSort);
        }

        t(
            currentSort: [],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.ascending(1)]);
        t(
            currentSort: [DaviSort.ascending(1)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.descending(1)]);
        t(
            currentSort: [DaviSort.descending(1)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.ascending(1)]);
        t(
            currentSort: [DaviSort.ascending(1)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.ascending(1), DaviSort.ascending(2)]);
        t(
            currentSort: [DaviSort.descending(1)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.descending(1), DaviSort.ascending(2)]);
        t(
            currentSort: [DaviSort.descending(1), DaviSort.descending(2)],
            columnIdToSort: 3,
            expectedNewSort: [
              DaviSort.descending(1),
              DaviSort.descending(2),
              DaviSort.ascending(3)
            ]);
        t(
            currentSort: [DaviSort.descending(1), DaviSort.descending(2)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.descending(2)]);
        t(
            currentSort: [DaviSort.ascending(1), DaviSort.ascending(2)],
            columnIdToSort: 1,
            expectedNewSort: [DaviSort.ascending(2)]);
        t(
            currentSort: [DaviSort.ascending(1), DaviSort.ascending(2)],
            columnIdToSort: 2,
            expectedNewSort: [DaviSort.ascending(1), DaviSort.descending(2)]);
      });
    });
  });
}

void testSort(
    {required bool multiSortEnabled,
    required bool alwaysSorted,
    required List<DaviSort> currentSort,
    required int columnIdToSort,
    required List<DaviSort> expectedNewSort}) {
  List<DaviSort> newSortList = SortUtil.newSortList(
      sortList: currentSort,
      alwaysSorted: alwaysSorted,
      multiSortEnabled: multiSortEnabled,
      columnIdToSort: columnIdToSort);
  expect(newSortList, expectedNewSort);
}
