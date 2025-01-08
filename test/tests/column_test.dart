import 'package:davi/davi.dart';
import 'package:davi/src/column.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DaviColumn', () {
    test('setting sort', () {
      DaviColumn column = DaviColumn(id: 'id', sortable: true);
      DaviColumnHelper.setSort(
          column: column, direction: DaviSortDirection.ascending, priority: 2);
      expect(column.sortPriority, 2);

      column = DaviColumn(id: 'id', sortable: false);
      expect(
          () => DaviColumnHelper.setSort(
              column: column,
              direction: DaviSortDirection.ascending,
              priority: 1),
          throwsA(const TypeMatcher<ArgumentError>()));

      column = DaviColumn(id: 1);
      expect(
          DaviColumnHelper.setSortPriority(column: column, priority: 1), false);
    });
  });
}
