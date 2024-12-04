import 'package:davi/src/internal/new/cell_span.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CellSpan', () {
    test('intersects - rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1',
        () {
      CellSpan cellSpan =
          CellSpan(rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1);

      expect(
          cellSpan.intersects(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          true);
      expect(
          cellSpan.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          true);
      expect(
          cellSpan.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          true);
    });
    test('intersects - rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 1',
        () {
      CellSpan cellSpan =
          CellSpan(rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 1);

      expect(
          cellSpan.intersects(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          true);
      expect(
          cellSpan.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          true);
      expect(
          cellSpan.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          true);
      expect(
          cellSpan.intersects(
              rowIndex: 3, columnIndex: 3, rowSpan: 1, columnSpan: 1),
          false);
    });
    test('intersects - rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 2',
        () {
      CellSpan cellSpan =
          CellSpan(rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 2);

      expect(
          cellSpan.intersects(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          true);
      expect(
          cellSpan.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          true);
      expect(
          cellSpan.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          true);
      expect(
          cellSpan.intersects(
              rowIndex: 3, columnIndex: 3, rowSpan: 1, columnSpan: 1),
          false);
    });
    test('intersects - rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 2',
        () {
      CellSpan cellSpan =
          CellSpan(rowIndex: 1, columnIndex: 1, rowSpan: 2, columnSpan: 2);

      expect(
          cellSpan.intersects(
              rowIndex: 1, columnIndex: 1, rowSpan: 1, columnSpan: 1),
          true);
      expect(
          cellSpan.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 2),
          true);
      expect(
          cellSpan.intersects(
              rowIndex: 0, columnIndex: 0, rowSpan: 3, columnSpan: 3),
          true);
      expect(
          cellSpan.intersects(
              rowIndex: 3, columnIndex: 3, rowSpan: 1, columnSpan: 1),
          false);
    });
  });
}
