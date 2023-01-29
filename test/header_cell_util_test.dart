import 'package:davi/davi.dart';
import 'package:davi/src/internal/header_cell.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeaderCellUtil', () {
    group('newSortList', () {
      List<int> rows = [1, 2, 3];

      DaviColumn<int> column1 = DaviColumn<int>(id: 'id1', name: 'name1');
      DaviColumn<int> column2 = DaviColumn<int>(id: 'id2', name: 'name2');
      DaviColumn<int> column3 = DaviColumn<int>(id: 'id3', name: 'name3');

      List<DaviColumn<int>> columns = [column1, column2, column3];

      test('multiSortEnabled: false - alwaysSorted: false', () {
        DaviModel<int> model = DaviModel(
            rows: rows,
            columns: columns,
            ignoreSortFunctions: true,
            multiSortEnabled: false,
            alwaysSorted: false);
        expect(model.sortedColumns.length, 0);

        List<DaviSort> sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id2');
        expect(sortList.first.direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id1');
        expect(sortList.first.direction, DaviSortDirection.ascending);

        model.sort(sortList);
        expect(model.sortedColumns.length, 1);

        sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id2');
        expect(sortList.first.direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id1');
        expect(sortList.first.direction, DaviSortDirection.descending);

        model.sort(sortList);
        expect(model.sortedColumns.length, 1);

        sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id2');
        expect(sortList.first.direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 0);
      });

      test('multiSortEnabled: true - alwaysSorted: false', () {
        DaviModel<int> model = DaviModel(
            rows: rows,
            columns: columns,
            ignoreSortFunctions: true,
            multiSortEnabled: true,
            alwaysSorted: false);
        expect(model.sortedColumns.length, 0);

        List<DaviSort> sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id2');
        expect(sortList.first.direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id1');
        expect(sortList.first.direction, DaviSortDirection.ascending);

        model.sort(sortList);
        expect(model.sortedColumns.length, 1);

        sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 2);
        expect(sortList[0].id, 'id1');
        expect(sortList[0].direction, DaviSortDirection.ascending);
        expect(sortList[1].id, 'id2');
        expect(sortList[1].direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id1');
        expect(sortList.first.direction, DaviSortDirection.descending);

        model.sort(sortList);
        expect(model.sortedColumns.length, 1);

        sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 2);
        expect(sortList[0].id, 'id1');
        expect(sortList[0].direction, DaviSortDirection.descending);
        expect(sortList[1].id, 'id2');
        expect(sortList[1].direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 0);
      });

      test('multiSortEnabled: false - alwaysSorted: true', () {
        DaviModel<int> model = DaviModel(
            rows: rows,
            columns: columns,
            ignoreSortFunctions: true,
            multiSortEnabled: false,
            alwaysSorted: true);
        expect(model.sortedColumns.length, 1);

        List<DaviSort> sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id2');
        expect(sortList.first.direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id1');
        expect(sortList.first.direction, DaviSortDirection.descending);

        model.sort(sortList);
        expect(model.sortedColumns.length, 1);

        sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id2');
        expect(sortList.first.direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id1');
        expect(sortList.first.direction, DaviSortDirection.ascending);

        model.sort(sortList);
        expect(model.sortedColumns.length, 1);

        sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id2');
        expect(sortList.first.direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id1');
        expect(sortList.first.direction, DaviSortDirection.descending);
      });

      test('multiSortEnabled: true - alwaysSorted: true', () {
        DaviModel<int> model = DaviModel(
            rows: rows,
            columns: columns,
            ignoreSortFunctions: true,
            multiSortEnabled: true,
            alwaysSorted: true);
        expect(model.sortedColumns.length, 1);

        List<DaviSort> sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 2);
        expect(sortList[0].id, 'id1');
        expect(sortList[0].direction, DaviSortDirection.ascending);
        expect(sortList[1].id, 'id2');
        expect(sortList[1].direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id1');
        expect(sortList.first.direction, DaviSortDirection.descending);

        model.sort(sortList);
        expect(model.sortedColumns.length, 1);

        sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 2);
        expect(sortList[0].id, 'id1');
        expect(sortList[0].direction, DaviSortDirection.descending);
        expect(sortList[1].id, 'id2');
        expect(sortList[1].direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id1');
        expect(sortList.first.direction, DaviSortDirection.ascending);

        model.sort(sortList);
        expect(model.sortedColumns.length, 1);

        sortList = HeaderCellUtil.newSortList(model, column2);
        expect(sortList.length, 2);
        expect(sortList[0].id, 'id1');
        expect(sortList[0].direction, DaviSortDirection.ascending);
        expect(sortList[1].id, 'id2');
        expect(sortList[1].direction, DaviSortDirection.ascending);

        sortList = HeaderCellUtil.newSortList(model, column1);
        expect(sortList.length, 1);
        expect(sortList.first.id, 'id1');
        expect(sortList.first.direction, DaviSortDirection.descending);
      });
    });
  });
}
