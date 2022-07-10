import 'package:easy_table/src/internal/row_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RowRange', () {
    test('Zero height', () {
      RowRange? rr =
          RowRange.build(scrollOffset: 0, visibleAreaHeight: 0, rowHeight: 100);
      expect(rr, null);
    });
    test('Negative height', () {
      RowRange? rr = RowRange.build(
          scrollOffset: 0, visibleAreaHeight: -10, rowHeight: 100);
      expect(rr, null);
    });
    test('Scenario 1', () {
      RowRange? rr = rowRangeNotNull(RowRange.build(
          scrollOffset: 0, visibleAreaHeight: 30, rowHeight: 10));
      expect(rr.length, 3);
      expect(rr.firstIndex, 0);
      expect(rr.lastIndex, 2);
    });
    test('Scenario 2', () {
      RowRange? rr = rowRangeNotNull(RowRange.build(
          scrollOffset: 1, visibleAreaHeight: 30, rowHeight: 10));
      expect(rr.length, 4);
      expect(rr.firstIndex, 0);
      expect(rr.lastIndex, 3);
    });
    test('Scenario 3', () {
      RowRange? rr = rowRangeNotNull(RowRange.build(
          scrollOffset: 9, visibleAreaHeight: 30, rowHeight: 10));
      expect(rr.length, 4);
      expect(rr.firstIndex, 0);
      expect(rr.lastIndex, 3);
    });
    test('Scenario 4', () {
      RowRange? rr = rowRangeNotNull(RowRange.build(
          scrollOffset: 10, visibleAreaHeight: 30, rowHeight: 10));
      expect(rr.length, 3);
      expect(rr.firstIndex, 1);
      expect(rr.lastIndex, 3);
    });
    test('Scenario 5', () {
      RowRange? rr = rowRangeNotNull(RowRange.build(
          scrollOffset: 15, visibleAreaHeight: 30, rowHeight: 10));
      expect(rr.length, 4);
      expect(rr.firstIndex, 1);
      expect(rr.lastIndex, 4);
    });
    test('Scenario 6', () {
      RowRange? rr = rowRangeNotNull(RowRange.build(
          scrollOffset: 20, visibleAreaHeight: 30, rowHeight: 10));
      expect(rr.length, 3);
      expect(rr.firstIndex, 2);
      expect(rr.lastIndex, 4);
    });
    test('Scenario 7', () {
      RowRange? rr = rowRangeNotNull(RowRange.build(
          scrollOffset: 21, visibleAreaHeight: 30, rowHeight: 10));
      expect(rr.length, 4);
      expect(rr.firstIndex, 2);
      expect(rr.lastIndex, 5);
    });
    test('Scenario 8', () {
      RowRange? rr = rowRangeNotNull(RowRange.build(
          scrollOffset: 51, visibleAreaHeight: 30, rowHeight: 10));
      expect(rr.length, 4);
      expect(rr.firstIndex, 5);
      expect(rr.lastIndex, 8);
    });
    test('Scenario 9', () {
      RowRange? rr = rowRangeNotNull(RowRange.build(
          scrollOffset: 59, visibleAreaHeight: 30, rowHeight: 10));
      expect(rr.length, 4);
      expect(rr.firstIndex, 5);
      expect(rr.lastIndex, 8);
    });
    test('Scenario 9', () {
      RowRange? rr = rowRangeNotNull(RowRange.build(
          scrollOffset: 60, visibleAreaHeight: 30, rowHeight: 10));
      expect(rr.length, 3);
      expect(rr.firstIndex, 6);
      expect(rr.lastIndex, 8);
    });
  });
}

RowRange rowRangeNotNull(RowRange? rowRange) {
  if (rowRange != null) {
    return rowRange;
  } else {
    fail('RowRange null');
  }
}
