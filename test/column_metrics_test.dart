import 'package:davi/davi.dart';
import 'package:davi/src/internal/column_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColumnMetrics', () {
    test('Equals', () {
      ColumnMetrics cm1 =
          ColumnMetrics(pinStatus: PinStatus.none, width: 100, offset: 0);
      ColumnMetrics cm2 =
          ColumnMetrics(pinStatus: PinStatus.none, width: 100, offset: 0);
      expect(cm1 == cm2, true);
      cm2 = ColumnMetrics(pinStatus: PinStatus.left, width: 100, offset: 0);
      expect(cm1 == cm2, false);
      cm2 = ColumnMetrics(pinStatus: PinStatus.none, width: 10, offset: 0);
      expect(cm1 == cm2, false);
      cm2 = ColumnMetrics(pinStatus: PinStatus.none, width: 100, offset: 10);
      expect(cm1 == cm2, false);
    });
    group('Fit', () {
      test('Empty', () {
        DaviModel model = DaviModel(columns: []);
        List<ColumnMetrics> list = ColumnMetrics.columnsFit(
            model: model, maxWidth: 100, dividerThickness: 10);
        expect(list.length, 0);
      });
      test('Single - Divider', () {
        DaviModel model =
            DaviModel(columns: [DaviColumn(pinStatus: PinStatus.left)]);
        List<ColumnMetrics> list = ColumnMetrics.columnsFit(
            model: model, maxWidth: 100, dividerThickness: 10);
        expect(list.length, 1);
        expect(list[0].offset, 0);
        expect(list[0].width, 100);
        expect(list[0].pinStatus, PinStatus.none);
      });
      test('Single - No divider', () {
        DaviModel model =
            DaviModel(columns: [DaviColumn(pinStatus: PinStatus.left)]);
        List<ColumnMetrics> list = ColumnMetrics.columnsFit(
            model: model, maxWidth: 100, dividerThickness: 0);
        expect(list.length, 1);
        expect(list[0].offset, 0);
        expect(list[0].width, 100);
        expect(list[0].pinStatus, PinStatus.none);
      });
      test('Multiple - Divider', () {
        DaviModel model = DaviModel(columns: [
          DaviColumn(pinStatus: PinStatus.left),
          DaviColumn(pinStatus: PinStatus.none)
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
      test('Multiple - No divider', () {
        DaviModel model = DaviModel(columns: [
          DaviColumn(pinStatus: PinStatus.left),
          DaviColumn(pinStatus: PinStatus.none)
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
      test('Single - Divider - Weight', () {
        DaviModel model = DaviModel(
            columns: [DaviColumn(pinStatus: PinStatus.left, grow: 2)]);
        List<ColumnMetrics> list = ColumnMetrics.columnsFit(
            model: model, maxWidth: 100, dividerThickness: 10);
        expect(list.length, 1);
        expect(list[0].offset, 0);
        expect(list[0].width, 100);
        expect(list[0].pinStatus, PinStatus.none);
      });
      test('Single - No divider - Weight', () {
        DaviModel model = DaviModel(
            columns: [DaviColumn(pinStatus: PinStatus.left, grow: 2)]);
        List<ColumnMetrics> list = ColumnMetrics.columnsFit(
            model: model, maxWidth: 100, dividerThickness: 0);
        expect(list.length, 1);
        expect(list[0].offset, 0);
        expect(list[0].width, 100);
        expect(list[0].pinStatus, PinStatus.none);
      });
      test('Multiple - Divider - Weight', () {
        DaviModel model = DaviModel(columns: [
          DaviColumn(pinStatus: PinStatus.left, grow: 2),
          DaviColumn(pinStatus: PinStatus.none, grow: 6)
        ]);
        List<ColumnMetrics> list = ColumnMetrics.columnsFit(
            model: model, maxWidth: 100, dividerThickness: 20);
        expect(list.length, 2);
        expect(list[0].offset, 0);
        expect(list[0].width, 20);
        expect(list[0].pinStatus, PinStatus.none);
        expect(list[1].offset, 40);
        expect(list[1].width, 60);
        expect(list[1].pinStatus, PinStatus.none);
      });
      test('Multiple - No divider - Weight', () {
        DaviModel model = DaviModel(columns: [
          DaviColumn(pinStatus: PinStatus.left, grow: 2),
          DaviColumn(pinStatus: PinStatus.none, grow: 8)
        ]);
        List<ColumnMetrics> list = ColumnMetrics.columnsFit(
            model: model, maxWidth: 100, dividerThickness: 0);
        expect(list.length, 2);
        expect(list[0].offset, 0);
        expect(list[0].width, 20);
        expect(list[0].pinStatus, PinStatus.none);
        expect(list[1].offset, 20);
        expect(list[1].width, 80);
        expect(list[1].pinStatus, PinStatus.none);
      });
    });
    group('Resizable', () {
      test('Empty', () {
        DaviModel model = DaviModel(columns: []);
        List<ColumnMetrics> list = ColumnMetrics.resizable(
            model: model, maxWidth: 500, dividerThickness: 10);
        expect(list.length, 0);
      });
      test('Single - Divider', () {
        DaviModel model = DaviModel(
            columns: [DaviColumn(pinStatus: PinStatus.left, width: 50)]);
        List<ColumnMetrics> list = ColumnMetrics.resizable(
            model: model, maxWidth: 500, dividerThickness: 10);
        expect(list.length, 1);
        expect(list[0].offset, 0);
        expect(list[0].width, 50);
        expect(list[0].pinStatus, PinStatus.left);
      });
      test('Single - No divider', () {
        DaviModel model = DaviModel(
            columns: [DaviColumn(pinStatus: PinStatus.left, width: 50)]);
        List<ColumnMetrics> list = ColumnMetrics.resizable(
            model: model, maxWidth: 500, dividerThickness: 10);
        expect(list.length, 1);
        expect(list[0].offset, 0);
        expect(list[0].width, 50);
        expect(list[0].pinStatus, PinStatus.left);
      });
      test('Multi - Divider', () {
        DaviModel model = DaviModel(columns: [
          DaviColumn(pinStatus: PinStatus.left, width: 50),
          DaviColumn(pinStatus: PinStatus.none, width: 100)
        ]);
        List<ColumnMetrics> list = ColumnMetrics.resizable(
            model: model, maxWidth: 500, dividerThickness: 10);
        expect(list.length, 2);
        expect(list[0].offset, 0);
        expect(list[0].width, 50);
        expect(list[0].pinStatus, PinStatus.left);
        expect(list[1].offset, 60);
        expect(list[1].width, 100);
        expect(list[1].pinStatus, PinStatus.none);
      });
      test('Multi - No divider', () {
        DaviModel model = DaviModel(columns: [
          DaviColumn(pinStatus: PinStatus.left, width: 50),
          DaviColumn(pinStatus: PinStatus.none, width: 100)
        ]);
        List<ColumnMetrics> list = ColumnMetrics.resizable(
            model: model, maxWidth: 500, dividerThickness: 0);
        expect(list.length, 2);
        expect(list[0].offset, 0);
        expect(list[0].width, 50);
        expect(list[0].pinStatus, PinStatus.left);
        expect(list[1].offset, 50);
        expect(list[1].width, 100);
        expect(list[1].pinStatus, PinStatus.none);
      });
    });
  });
}
