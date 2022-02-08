import 'package:easy_table/src/easy_table_cell_builder.dart';
import 'package:easy_table/src/easy_table_header_builder.dart';

class EasyTableColumn<ROW_VALUE> {
  EasyTableColumn(
      {required this.cellBuilder,
      this.initialWidth = 100,
      this.name,
      this.headerCellBuilder = HeaderCellBuilders.defaultHeaderCellBuilder});

  final String? name;
  final double initialWidth;
  final EasyTableCellBuilder<ROW_VALUE> cellBuilder;
  final EasyTableHeaderCellBuilder? headerCellBuilder;
}
