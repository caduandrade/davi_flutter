import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/last_on_sort.dart';

List<int> get _rows => List<int>.generate(5, (i) => i + 1);

DaviColumn<int> _column(int id) => DaviColumn<int>(id: id, name: 'name$id');

List<DaviColumn<int>> _columns(int length) =>
    List.generate(length, (index) => _column(index + 1));

void main() {
  group('DaviModel', () {
    test('onSort', () {
      LastOnSort lastOnSort = LastOnSort();

      DaviModel<int> model = DaviModel(
          rows: _rows, columns: _columns(3), onSort: lastOnSort.onSort);

      expect(model.isSorted, false);

      model.sort([DaviSort(1)]);

      expect(lastOnSort.triggeredCount, 1);
      expect(lastOnSort.columns.length, 1);
      expect(lastOnSort.columns[0].id, 1);
      expect(lastOnSort.columns[0].name, 'name1');
      expect(
          lastOnSort.columns[0].sort?.direction, DaviSortDirection.ascending);

      model.sort([DaviSort(1)]);

      expect(lastOnSort.triggeredCount, 1);
    });
  });
}
