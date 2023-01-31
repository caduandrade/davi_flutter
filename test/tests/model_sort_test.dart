import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/last_on_sort.dart';

List<int> get _rows => List<int>.generate(5, (i) => i + 1);

void main() {
  group('DaviModel', () {
    test('Sort', () {
      LastOnSort lastOnSort = LastOnSort();

      DaviModel<int> model = DaviModel(
          rows: _rows,
          columns: [
            DaviColumn<int>(id: 1, name: 'name1'),
            DaviColumn<int>(id: 2, name: 'name2'),
            DaviColumn<int>(id: 3, name: 'name3')
          ],
          onSort: lastOnSort.onSort,
          ignoreDataComparators: true);

      expect(model.sortedColumns.length, 0);

      model.sort([DaviSort(1, DaviSortDirection.ascending)]);
      expect(lastOnSort.triggeredCount, 1);
      expect(lastOnSort.columns.length, 1);
      expect(lastOnSort.columns[0].name, 'name1');
      expect(
          lastOnSort.columns[0].sort?.direction, DaviSortDirection.ascending);
    });
  });
}
