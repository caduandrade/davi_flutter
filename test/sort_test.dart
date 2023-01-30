import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util/last_on_sort.dart';

List<int> get _rows => List<int>.generate(5, (i) => i + 1);

void main() {
  group('DaviModel', () {
    test('Sort', () {
      LastOnSort lastOnSort = LastOnSort();

      DaviModel<int> model = DaviModel(
          rows: _rows,
          columns: [
            DaviColumn<int>(id: 'id1', name: 'name1'),
            DaviColumn<int>(id: 'id2', name: 'name2'),
            DaviColumn<int>(name: 'name3')
          ],
          onSort: lastOnSort.onSort,
          ignoreSortFunctions: true);

      expect(model.sortedColumns.length, 0);

      model.sort([DaviSort(null, DaviSortDirection.ascending)]);
      expect(lastOnSort.triggeredCount, 1);
      expect(lastOnSort.columns.length, 0);

      model.sort([DaviSort('id1', DaviSortDirection.ascending)]);
      expect(lastOnSort.triggeredCount, 2);
      expect(lastOnSort.columns.length, 1);
      expect(lastOnSort.columns[0].name, 'name1');
      expect(lastOnSort.columns[0].sortDirection, DaviSortDirection.ascending);

      model.sort([
        DaviSort('id2', DaviSortDirection.descending),
        DaviSort('id1', DaviSortDirection.ascending)
      ]);
      // multi sort disabled, using the first sort
      expect(lastOnSort.triggeredCount, 3);
      expect(lastOnSort.columns.length, 1);
      expect(lastOnSort.columns[0].name, 'name2');
      expect(lastOnSort.columns[0].sortDirection, DaviSortDirection.descending);

      model.sort([
        DaviSort(null, DaviSortDirection.descending),
        DaviSort('id1', DaviSortDirection.ascending)
      ]);
      expect(lastOnSort.triggeredCount, 4);
      expect(lastOnSort.columns.length, 1);
      expect(lastOnSort.columns[0].name, 'name1');
      expect(lastOnSort.columns[0].sortDirection, DaviSortDirection.ascending);

      // multi sort

      model = DaviModel(
          rows: _rows,
          columns: [
            DaviColumn<int>(id: 'id1', name: 'name1'),
            DaviColumn<int>(id: 'id2', name: 'name2'),
            DaviColumn<int>(name: 'name3')
          ],
          onSort: lastOnSort.onSort,
          ignoreSortFunctions: true,
          multiSortEnabled: true);

      model.sort([
        DaviSort('id2', DaviSortDirection.descending),
        DaviSort('id1', DaviSortDirection.ascending)
      ]);
      expect(lastOnSort.triggeredCount, 5);
      expect(lastOnSort.columns.length, 2);
      expect(lastOnSort.columns[0].name, 'name2');
      expect(lastOnSort.columns[0].sortDirection, DaviSortDirection.descending);
      expect(lastOnSort.columns[1].name, 'name1');
      expect(lastOnSort.columns[1].sortDirection, DaviSortDirection.ascending);
    });
  });
}
