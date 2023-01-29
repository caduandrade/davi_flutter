import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

class LastSort {
  int triggeredCount = 0;
  List<DaviColumn<int>> columns = [];

  void onSort(List<DaviColumn<int>> sortedColumns) {
    columns = sortedColumns;
    triggeredCount++;
  }
}

void main() {
  group('Model', () {
    test('DaviSort', () {
      DaviSort sort = DaviSort(null);
      expect(sort.id, null);
    });
    test('Sort', () {
      LastSort lastSort = LastSort();

      DaviModel<int> model = DaviModel(rows: [
        1,
        2,
        3,
        4,
        5
      ], columns: [
        DaviColumn<int>(id: 'id1', name: 'name1'),
        DaviColumn<int>(id: 'id2', name: 'name2'),
        DaviColumn<int>(name: 'name3')
      ], onSort: lastSort.onSort, ignoreSortFunctions: true);

      expect(model.sortedColumns.length, 0);

      model.sort([DaviSort(null, DaviSortDirection.ascending)]);
      expect(lastSort.triggeredCount, 1);
      expect(lastSort.columns.length, 0);

      model.sort([DaviSort('id1', DaviSortDirection.ascending)]);
      expect(lastSort.triggeredCount, 2);
      expect(lastSort.columns.length, 1);
      expect(lastSort.columns[0].name, 'name1');
      expect(lastSort.columns[0].direction, DaviSortDirection.ascending);

      model.sort([
        DaviSort('id2', DaviSortDirection.descending),
        DaviSort('id1', DaviSortDirection.ascending)
      ]);
      // multi sort disabled, using the first sort
      expect(lastSort.triggeredCount, 3);
      expect(lastSort.columns.length, 1);
      expect(lastSort.columns[0].name, 'name2');
      expect(lastSort.columns[0].direction, DaviSortDirection.descending);

      model.sort([
        DaviSort(null, DaviSortDirection.descending),
        DaviSort('id1', DaviSortDirection.ascending)
      ]);
      expect(lastSort.triggeredCount, 4);
      expect(lastSort.columns.length, 1);
      expect(lastSort.columns[0].name, 'name1');
      expect(lastSort.columns[0].direction, DaviSortDirection.ascending);

      // multi sort

      model = DaviModel(rows: [
        1,
        2,
        3,
        4,
        5
      ], columns: [
        DaviColumn<int>(id: 'id1', name: 'name1'),
        DaviColumn<int>(id: 'id2', name: 'name2'),
        DaviColumn<int>(name: 'name3')
      ], onSort: lastSort.onSort, ignoreSortFunctions: true, multiSort: true);

      model.sort([
        DaviSort('id2', DaviSortDirection.descending),
        DaviSort('id1', DaviSortDirection.ascending)
      ]);
      expect(lastSort.triggeredCount, 5);
      expect(lastSort.columns.length, 2);
      expect(lastSort.columns[0].name, 'name2');
      expect(lastSort.columns[0].direction, DaviSortDirection.descending);
      expect(lastSort.columns[1].name, 'name1');
      expect(lastSort.columns[1].direction, DaviSortDirection.ascending);
    });
  });
}
