import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Column', () {
    test('grow', () {
      DaviColumn column = DaviColumn();
      expect(column.grow, null);
      column = DaviColumn(grow: null);
      expect(column.grow, null);
      column = DaviColumn(grow: -1);
      expect(column.grow, 1);
      column = DaviColumn(grow: 0);
      expect(column.grow, 1);
      column = DaviColumn(grow: 2);
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
