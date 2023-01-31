import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DaviSort', () {
    test('create', () {
      expect(() => DaviSort(null), throwsA(const TypeMatcher<ArgumentError>()));
    });
    test('equals', () {
      expect(DaviSort(1), DaviSort(1, DaviSortDirection.ascending));
      expect(DaviSort(1, DaviSortDirection.ascending),
          DaviSort(1, DaviSortDirection.ascending));
      expect(DaviSort(1, DaviSortDirection.ascending),
          isNot(DaviSort(2, DaviSortDirection.ascending)));
      expect(DaviSort.ascending(1), DaviSort.ascending(1));
      expect(DaviSort.ascending(1), DaviSort.ascending(1));
      expect(DaviSort.ascending(1), isNot(DaviSort.ascending(2)));
      expect(DaviSort.descending(1), DaviSort.descending(1));
      expect(DaviSort.ascending(1), isNot(DaviSort.descending(1)));
    });
  });
}
