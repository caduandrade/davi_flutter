import 'package:davi/davi.dart';

class LastOnSort<DATA> {
  int triggeredCount = 0;
  List<DaviColumn<DATA>> columns = [];

  void onSort(List<DaviColumn<DATA>> sortedColumns) {
    columns = sortedColumns;
    triggeredCount++;
  }
}
