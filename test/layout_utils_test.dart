import 'package:davi/src/internal/layout_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LayoutUtils', () {
    group('maxVisibleRowsLength', () {
      test('Zero height', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 0, visibleAreaHeight: 0, rowHeight: 10);
        expect(length, 0);
      });
      test('Negative height', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 0, visibleAreaHeight: -10, rowHeight: 10);
        expect(length, 0);
      });
      test('Scenario 1', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 0, visibleAreaHeight: 30, rowHeight: 10);
        expect(length, 3);
      });
      test('Scenario 2', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 1, visibleAreaHeight: 30, rowHeight: 10);
        expect(length, 4);
      });
      test('Scenario 3', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 9, visibleAreaHeight: 30, rowHeight: 10);
        expect(length, 4);
      });
      test('Scenario 4', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 10, visibleAreaHeight: 30, rowHeight: 10);
        expect(length, 3);
      });
      test('Scenario 5', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 15, visibleAreaHeight: 30, rowHeight: 10);
        expect(length, 4);
      });
      test('Scenario 6', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 20, visibleAreaHeight: 30, rowHeight: 10);
        expect(length, 3);
      });
      test('Scenario 7', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 21, visibleAreaHeight: 30, rowHeight: 10);
        expect(length, 4);
      });

      test('Scenario 8', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 51, visibleAreaHeight: 30, rowHeight: 10);
        expect(length, 4);
      });
      test('Scenario 9', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 59, visibleAreaHeight: 30, rowHeight: 10);
        expect(length, 4);
      });
      test('Scenario 9', () {
        int length = LayoutUtils.maxVisibleRowsLength(
            scrollOffset: 60, visibleAreaHeight: 30, rowHeight: 10);
        expect(length, 3);
      });
    });
  });
}
