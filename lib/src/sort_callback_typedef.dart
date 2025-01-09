import 'package:davi/src/column.dart';

/// This callback is triggered before the internal sorting logic is executed.
///
/// Will only be triggered when the header is clicked or when
/// the [DaviModel.sort] or [DaviModel.clearSort] methods
/// are called programmatically.
typedef OnSortCallback<DATA> = void Function(
    List<DaviColumn<DATA>> sortedColumns);
