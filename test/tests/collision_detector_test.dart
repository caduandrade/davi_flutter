import 'package:davi/src/internal/new/collision_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CollisionDetector', () {
    test('intersects - rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1',
        () {
      CollisionDetector cache = CollisionDetector();
      cache.add(rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1);

      expect(
          cache.intersects(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          false);
      expect(
          cache.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          false);
      expect(
          cache.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          false);
    });
    test('intersects - rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 1',
        () {
      CollisionDetector cache = CollisionDetector();
      cache.add(rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 1);

      expect(
          cache.intersects(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          true);
      expect(
          cache.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          true);
      expect(
          cache.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          true);
      expect(
          cache.intersects(
              rowIndex: 3, columnIndex: 3, rowSpan: 1, columnSpan: 1),
          false);
    });
    test('intersects - rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 2',
        () {
      CollisionDetector cache = CollisionDetector();
      cache.add(rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 2);

      expect(
          cache.intersects(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          true);
      expect(
          cache.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          true);
      expect(
          cache.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          true);
      expect(
          cache.intersects(
              rowIndex: 3, columnIndex: 3, rowSpan: 1, columnSpan: 1),
          false);
    });
    test('intersects - rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 2',
        () {
      CollisionDetector cache = CollisionDetector();
      cache.add(rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 2);

      expect(
          cache.intersects(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          true);
      expect(
          cache.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          true);
      expect(
          cache.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          true);
      expect(
          cache.intersects(
              rowIndex: 3, columnIndex: 3, rowSpan: 1, columnSpan: 1),
          false);
    });
  });
}
