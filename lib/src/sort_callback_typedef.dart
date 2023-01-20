import 'package:davi/src/column.dart';

/// Signature for when a sort has occurred.
typedef OnSortCallback<DATA> = void Function(
    List<DaviColumn<DATA>> sortedColumns);
