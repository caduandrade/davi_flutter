import 'package:davi/davi.dart';
import 'package:davi/src/internal/new/span_usage_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpanUsageCache', () {
    test('intercepts - rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1',
        () {
      SpanUsageCache cache = SpanUsageCache();
      cache.add(rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1);

      expect(cache.count, 0);

      expect(
          cache.intercepts(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          false);
      expect(
          cache.intercepts(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          false);
      expect(
          cache.intercepts(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          false);
    });
    test('intercepts - rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 1',
        () {
      SpanUsageCache cache = SpanUsageCache();
      cache.add(rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 1);

      expect(cache.count, 2);

      expect(
          cache.intercepts(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          true);
      expect(
          cache.intercepts(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          true);
      expect(
          cache.intercepts(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          true);
      expect(
          cache.intercepts(
              rowIndex: 3, columnIndex: 3, rowSpan: 1, columnSpan: 1),
          false);
    });
    test('intercepts - rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 2',
        () {
      SpanUsageCache cache = SpanUsageCache();
      cache.add(rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 2);

      expect(cache.count, 2);

      expect(
          cache.intercepts(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          true);
      expect(
          cache.intercepts(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          true);
      expect(
          cache.intercepts(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          true);
      expect(
          cache.intercepts(
              rowIndex: 3, columnIndex: 3, rowSpan: 1, columnSpan: 1),
          false);
    });
    test('intercepts - rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 2',
        () {
      SpanUsageCache cache = SpanUsageCache();
      cache.add(rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 2);

      expect(cache.count, 4);

      expect(
          cache.intercepts(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          true);
      expect(
          cache.intercepts(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          true);
      expect(
          cache.intercepts(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          true);
      expect(
          cache.intercepts(
              rowIndex: 3, columnIndex: 3, rowSpan: 1, columnSpan: 1),
          false);
    });
  });
}
