import 'package:davi/src/column.dart';

/// Signature to the callback of when a sort has occurred.
typedef OnSortCallback<DATA> = void Function(
    List<DaviColumn<DATA>> sortedColumns);
