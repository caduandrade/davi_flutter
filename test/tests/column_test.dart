import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DaviColumn', () {
    test('setting sort', () {
      DaviColumn column = DaviColumn(id: 'id', sortable: true);
      DaviSort sort = DaviSort('id');
      column.sort = sort;
      sort = DaviSort('x');
      expect(() => column.sort = sort,
          throwsA(const TypeMatcher<ArgumentError>()));

      column = DaviColumn(id: 'id', sortable: false);
      sort = DaviSort('id');
      expect(() => column.sort = sort,
          throwsA(const TypeMatcher<ArgumentError>()));
    });
  });
}
