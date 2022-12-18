import 'package:easy_table/easy_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Column', () {
    test('grow', () {
      EasyTableColumn column = EasyTableColumn();
      expect(column.grow, null);
      column = EasyTableColumn(grow: null);
      expect(column.grow, null);
      column = EasyTableColumn(grow: -1);
      expect(column.grow, 1);
      column = EasyTableColumn(grow: 0);
      expect(column.grow, 1);
      column = EasyTableColumn(grow: 2);
      expect(column.grow, 2);

      column.grow = null;
      expect(column.grow, null);
      column.grow = -1;
      expect(column.grow, 1);
      column.grow = 0;
      expect(column.grow, 1);
      column.grow = 2;
      expect(column.grow, 2);
    });
  });
}
