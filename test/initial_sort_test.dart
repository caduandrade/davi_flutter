import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> get _rows => List<int>.generate(5, (i) => i + 1);

void main() {
  group('DaviModel', () {
    group('Initial sort', () {
      group('Model without column', () {
        test('No sorted column', () {
          DaviModel<int> model = DaviModel(
              rows: _rows,
              columns: [],
              multiSortEnabled: false,
              alwaysSorted: true,
              ignoreSortFunctions: false);
          expect(model.isSorted, false);
          expect(model.isMultiSorted, false);
          expect(model.sortedColumns.length, 0);

          model = DaviModel(
              rows: _rows,
              columns: [],
              multiSortEnabled: false,
              alwaysSorted: true,
              ignoreSortFunctions: true);
          expect(model.isSorted, false);
          expect(model.isMultiSorted, false);
          expect(model.sortedColumns.length, 0);

          model = DaviModel(
              rows: _rows,
              columns: [],
              multiSortEnabled: true,
              alwaysSorted: true,
              ignoreSortFunctions: true);
          expect(model.isSorted, false);
          expect(model.isMultiSorted, false);
          expect(model.sortedColumns.length, 0);
        });
        group('Model with 1 column', () {
          test('No sorted column', () {});
          test('One sorted column', () {
            DaviModel<int> model = DaviModel(
                rows: _rows,
                columns: [DaviColumn<int>(name: 'name')],
                multiSortEnabled: true,
                alwaysSorted: true,
                ignoreSortFunctions: true);
            expect(model.isSorted, true);
            expect(model.isMultiSorted, false);
            expect(model.sortedColumns.length, 1);
            expect(model.sortedColumns.first.name, 'name');
            expect(model.sortedColumns.first.sortPriority, 1);
            expect(model.sortedColumns.first.sortDirection,
                DaviSortDirection.ascending);
          });
        });
      });
    });
  });
}
