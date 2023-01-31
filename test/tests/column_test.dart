import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DaviColumn', () {
    test('setting sort', () {
      DaviColumn column = DaviColumn(id: 'id', sortable: true);
      DaviSort sort = DaviSort('id');
      column.setSort(sort, 2);
      expect(column.sortPriority, 2);
      sort = DaviSort('x');
      expect(() => column.setSort(sort, 3),
          throwsA(const TypeMatcher<ArgumentError>()));

      column = DaviColumn(id: 'id', sortable: false);
      sort = DaviSort('id');
      expect(() => column.setSort(sort, 1),
          throwsA(const TypeMatcher<ArgumentError>()));

      column = DaviColumn(id: 1);
      expect(column.setSortPriority(1), false);
    });
  });
}
