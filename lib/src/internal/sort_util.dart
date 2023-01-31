import 'package:collection/collection.dart';
import 'package:davi/davi.dart';
import 'package:meta/meta.dart';

@internal
class SortUtil {
  /// Creates a new sort list given a list of sorted columns,
  /// model configuration and the new column.
  static List<DaviSort> newSortList(
      {required List<DaviSort> sortList,
      required bool multiSortEnabled,
      required bool alwaysSorted,
      required dynamic columnIdToSort}) {
    List<DaviSort> newSortList = [];

    if(multiSortEnabled) {
      bool needAddColumn = true;
      for (int index = 0; index < sortList.length; index++) {
        DaviSort sort = sortList[index];
        if (sort.columnId == columnIdToSort) {
          needAddColumn = false;
          if (index == sortList.length - 1) {
            if (sort.direction == DaviSortDirection.ascending) {
              newSortList.add(
                  DaviSort(columnIdToSort, DaviSortDirection.descending));
            }
          }
          continue;
        }
          newSortList.add(
              DaviSort(sort.columnId, sort.direction));
      }
      if (needAddColumn || (alwaysSorted && newSortList.isEmpty)) {
        newSortList.add(DaviSort(columnIdToSort, DaviSortDirection.ascending));
      }
    } else {
      DaviSort? sort = sortList.firstWhereOrNull((sort)=>sort.columnId==columnIdToSort);
      if (sort?.direction == DaviSortDirection.ascending) {
        newSortList.add(
            DaviSort(columnIdToSort, DaviSortDirection.descending));
      } else if(alwaysSorted || sort==null) {
        newSortList.add(
            DaviSort(columnIdToSort, DaviSortDirection.ascending));
      }
    }
    return newSortList;
  }

  /// Creates a new sort list given a list of sorted columns,
  /// model configuration and the new column.
  static List<DaviSort> newSortListOLD(
      {required List<DaviSort> sortList,
        required bool multiSortEnabled,
        required bool alwaysSorted,
        required dynamic columnIdToSort}) {
    List<DaviSort> newSortList = [];

    bool needAddColumn = true;
    for (int index = 0; index < sortList.length; index++) {
      DaviSort currentSort = sortList[index];
      if (currentSort.columnId == columnIdToSort) {
        needAddColumn = false;
        if (index == sortList.length - 1) {
          if (currentSort.direction == DaviSortDirection.ascending) {
            newSortList.add(DaviSort(columnIdToSort, DaviSortDirection.descending));
          }
        }
        continue;
      }
      if (multiSortEnabled) {
        newSortList.add(DaviSort(currentSort.columnId, currentSort.direction));
      }
    }
    if (needAddColumn || (alwaysSorted && newSortList.isEmpty)) {
      newSortList.add(DaviSort(columnIdToSort, DaviSortDirection.ascending));
    }
    return newSortList;
  }
}
