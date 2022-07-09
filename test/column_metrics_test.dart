import 'package:easy_table/easy_table.dart';
import 'package:easy_table/src/internal/column_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColumnMetrics', () {
    test('Fit - Empty', () {
      EasyTableModel model = EasyTableModel(columns: []);
      List<ColumnMetrics> list = ColumnMetrics.columnsFit(
          model: model, maxWidth: 100, dividerThickness: 10);
      expect(list.length, 0);
    });
    test('Fit - Single - Divider', () {
      EasyTableModel model =
          EasyTableModel(columns: [EasyTableColumn(pinStatus: PinStatus.left)]);
      List<ColumnMetrics> list = ColumnMetrics.columnsFit(
          model: model, maxWidth: 100, dividerThickness: 10);
      expect(list.length, 1);
      expect(list[0].offset, 0);
      expect(list[0].width, 100);
      expect(list[0].pinStatus, PinStatus.none);
    });
    test('Fit - Single - No divider', () {
      EasyTableModel model =
          EasyTableModel(columns: [EasyTableColumn(pinStatus: PinStatus.left)]);
      List<ColumnMetrics> list = ColumnMetrics.columnsFit(
          model: model, maxWidth: 100, dividerThickness: 0);
      expect(list.length, 1);
      expect(list[0].offset, 0);
      expect(list[0].width, 100);
      expect(list[0].pinStatus, PinStatus.none);
    });
    test('Fit - Multiple - Divider', () {
      EasyTableModel model = EasyTableModel(columns: [
        EasyTableColumn(pinStatus: PinStatus.left),
        EasyTableColumn(pinStatus: PinStatus.none)
      ]);
      List<ColumnMetrics> list = ColumnMetrics.columnsFit(
          model: model, maxWidth: 100, dividerThickness: 10);
      expect(list.length, 2);
      expect(list[0].offset, 0);
      expect(list[0].width, 45);
      expect(list[0].pinStatus, PinStatus.none);
      expect(list[1].offset, 55);
      expect(list[1].width, 45);
      expect(list[1].pinStatus, PinStatus.none);
    });
    test('Fit - Multiple - No divider', () {
      EasyTableModel model = EasyTableModel(columns: [
        EasyTableColumn(pinStatus: PinStatus.left),
        EasyTableColumn(pinStatus: PinStatus.none)
      ]);
      List<ColumnMetrics> list = ColumnMetrics.columnsFit(
          model: model, maxWidth: 100, dividerThickness: 0);
      expect(list.length, 2);
      expect(list[0].offset, 0);
      expect(list[0].width, 50);
      expect(list[0].pinStatus, PinStatus.none);
      expect(list[1].offset, 50);
      expect(list[1].width, 50);
      expect(list[1].pinStatus, PinStatus.none);
    });
  });
}
