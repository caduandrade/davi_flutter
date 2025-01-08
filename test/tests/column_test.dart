import 'package:davi/davi.dart';
import 'package:davi/src/column.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DaviColumn', () {
    test('setting sort', () {
      DaviColumn column = DaviColumn(id: 'id', sortable: true);
      DaviSort sort = DaviSort('id');
      DaviColumnHelper.setSort(column: column, sort: sort, priority: 2);
      expect(column.sortPriority, 2);
      sort = DaviSort('x');
      expect(
          () =>
              DaviColumnHelper.setSort(column: column, sort: sort, priority: 3),
          throwsA(const TypeMatcher<ArgumentError>()));

      column = DaviColumn(id: 'id', sortable: false);
      sort = DaviSort('id');
      expect(
          () =>
              DaviColumnHelper.setSort(column: column, sort: sort, priority: 1),
          throwsA(const TypeMatcher<ArgumentError>()));

      column = DaviColumn(id: 1);
      expect(DaviColumnHelper.setSortPriority(column: column, value: 1), false);
    });
  });
}
