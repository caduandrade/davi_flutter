import 'package:davi/davi.dart';
import 'package:davi/src/internal/cell_widget.dart';
import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/new/cell_span_cache.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/new/painter_cache.dart';
import 'package:davi/src/internal/new/viewport_state.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@internal
class CellWidgetBuilder<DATA> extends StatefulWidget{

  const CellWidgetBuilder({Key? key, required this.cellIndex,
    required this.daviContext,
    required this.painterCache,
    required this.cellSpanCache,
  required this.viewportState,
  required this.layoutSettings}) : super(key: key);

  final int cellIndex;
  final DaviContext<DATA> daviContext;
  final ViewportState<DATA> viewportState;
  final PainterCache<DATA> painterCache;
  final CellSpanCache cellSpanCache;
  final TableLayoutSettings layoutSettings;


  @override
  State<StatefulWidget> createState()=>CellWidgetBuilderState<DATA>();

}

@internal
class CellWidgetBuilderState<DATA> extends State<CellWidgetBuilder<DATA>> {

  late CellMapping? _cellMapping;

  @override
  void initState() {
    super.initState();
    _cellMapping= widget.viewportState.getCellMapping(cellIndex: widget.cellIndex);
    widget.viewportState.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(CellWidgetBuilder<DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewportState != widget.viewportState) {
      oldWidget.viewportState.removeListener(_valueChanged);
      _cellMapping= widget.viewportState.getCellMapping(cellIndex: widget.cellIndex);
      widget.viewportState.addListener(_valueChanged);
    }
  }

  @override
  void dispose() {
    widget.viewportState.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged(){
    CellMapping? newCellModelMapping= widget.viewportState.getCellMapping(cellIndex: widget.cellIndex);
    if(_cellMapping!=newCellModelMapping) {
      setState(() {
        _cellMapping=newCellModelMapping;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CellMapping? cellMapping = _cellMapping;
    if(cellMapping!=null) {
      DATA? data;
      if (cellMapping.rowIndex < widget.daviContext.model.rowsLength) {
        data = widget.daviContext.model.rowAt(cellMapping.rowIndex);
      }
      if (data != null) {
        DaviColumn<DATA> column = widget.daviContext.model.columnAt(
            cellMapping.columnIndex);

        return CustomSingleChildWidget(verticalScrollController: widget.daviContext.scrollControllers.vertical,
            horizontalScrollController: widget.daviContext.scrollControllers.getHorizontalController(column.pinStatus),
            areaBounds: widget.layoutSettings.getAreaBounds(column.pinStatus),
            columnsMetrics: widget.layoutSettings.columnsMetrics,
            cellHeight: widget.layoutSettings.themeMetrics.cell.height,
            rowHeight: widget.layoutSettings.themeMetrics.row.height,
            cellMapping: cellMapping,
            child: CellWidget(data: data,
                rowIndex: cellMapping.rowIndex,
                rowSpan: cellMapping.rowSpan,
                columnIndex: cellMapping.columnIndex,
                columnSpan: cellMapping.columnSpan,
                column: column,
                daviContext: widget.daviContext,
                painterCache: widget.painterCache,
                cellSpanCache: widget.cellSpanCache));
      }
    }
    return Container();
  }

}
class CustomSingleChildWidget extends SingleChildRenderObjectWidget {

  const CustomSingleChildWidget({
    Key? key,
    required this.verticalScrollController,
    required this.horizontalScrollController,
    required this.columnsMetrics,
    required this.cellHeight,
    required this.rowHeight,
    required this.cellMapping,
    required this.areaBounds,
    Widget? child,
  }) : super(key: key, child: child);

  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;
  final List<ColumnMetrics> columnsMetrics;
  final double cellHeight;
  final double rowHeight;
  final CellMapping  cellMapping;
  final Rect areaBounds;

  @override
  RenderCustomSingleChild createRenderObject(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);
    return RenderCustomSingleChild(verticalScrollController: verticalScrollController,
        horizontalScrollController:horizontalScrollController,columnsMetrics: columnsMetrics,
    cellHeight: cellHeight,
        rowHeight:rowHeight,
    cellMapping: cellMapping,
    areaBounds: areaBounds,
    dividerThickness: theme.row.dividerThickness,
    columnDividerThickness: theme.columnDividerThickness);
  }

  @override
  void updateRenderObject(BuildContext context, RenderCustomSingleChild renderObject) {
    DaviThemeData theme = DaviTheme.of(context);
    renderObject..verticalScrollController = verticalScrollController
      ..horizontalScrollController=horizontalScrollController
    ..columnsMetrics=columnsMetrics
        ..cellHeight=cellHeight
      ..rowHeight=rowHeight
      ..areaBounds=areaBounds
    ..dividerThickness= theme.row.dividerThickness
    ..cellMapping=cellMapping
    ..columnDividerThickness=theme.columnDividerThickness;
  }
}

class CustomParentData extends ContainerBoxParentData<RenderBox> {}

class RenderCustomSingleChild extends RenderBox with RenderObjectWithChildMixin<RenderBox> {


  RenderCustomSingleChild({required ScrollController verticalScrollController,
    required ScrollController horizontalScrollController,
  required List<ColumnMetrics> columnsMetrics,
  required double cellHeight,
    required double rowHeight,
    required double columnDividerThickness,
    required double dividerThickness,
    required Rect areaBounds,
  required CellMapping cellMapping}) : _verticalScrollController = verticalScrollController,
         _horizontalScrollController=horizontalScrollController,
  _areaBounds=areaBounds,
        _columnsMetrics=columnsMetrics,
  _rowHeight=rowHeight,
  _cellHeight=cellHeight,
  _columnDividerThickness=columnDividerThickness,
  _dividerThickness=dividerThickness,
  _cellMapping=cellMapping{
    _verticalScrollController.addListener(markNeedsPaint);
    _horizontalScrollController.addListener(markNeedsPaint);
  }

  @override
  void dispose() {
    _verticalScrollController.removeListener(markNeedsPaint);
    _horizontalScrollController.removeListener(markNeedsPaint);
    super.dispose();
  }

  Rect _areaBounds;

  set areaBounds(Rect value) {
    if(_areaBounds!=value){
      _areaBounds=value;
      markNeedsPaint();
    }
  }

  ScrollController _verticalScrollController;

  set verticalScrollController(ScrollController value) {
    if (_verticalScrollController != value) {
      _verticalScrollController.removeListener(markNeedsPaint);
      _verticalScrollController = value;
      _verticalScrollController.addListener(markNeedsPaint);
      markNeedsPaint();
    }
  }

  double get verticalOffset {
    return _verticalScrollController.hasClients
        ? _verticalScrollController.offset
        : 0;
  }

  ScrollController _horizontalScrollController;

  set horizontalScrollController(ScrollController value) {
    if (_horizontalScrollController != value) {
      _horizontalScrollController.removeListener(markNeedsPaint);
      _horizontalScrollController = value;
      _horizontalScrollController.addListener(markNeedsPaint);
      markNeedsPaint();
    }
  }

  double get horizontalOffset {
    return _horizontalScrollController.hasClients
        ? _horizontalScrollController.offset
        : 0;
  }

  List<ColumnMetrics> _columnsMetrics;

  set columnsMetrics(List<ColumnMetrics> list) {
    if (listEquals(_columnsMetrics, list) == false) {
      _columnsMetrics = list;
      markNeedsLayout();
    }
  }

  double _rowHeight;

  set rowHeight(double value) {
    if (_rowHeight != value) {
      _rowHeight = value;
      markNeedsLayout();
    }
  }

  double _columnDividerThickness;

  set columnDividerThickness(double value) {
    if (_columnDividerThickness != value) {
      _columnDividerThickness = value;
      markNeedsLayout();
    }
  }

  double _cellHeight;

  set cellHeight(double value) {
    if (_cellHeight != value) {
      _cellHeight = value;
      markNeedsLayout();
    }
  }

  double _dividerThickness;

  set dividerThickness(double value) {
    if (_dividerThickness != value) {
      _dividerThickness = value;
      markNeedsLayout();
    }
  }

  CellMapping _cellMapping;

  set cellMapping(CellMapping value){
    if(_cellMapping!=value) {
      _cellMapping=value;
      markNeedsLayout();
    }
  }

  bool _hasLayoutErrors = false;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! CustomParentData) {
      child.parentData = CustomParentData();
    }
  }

  @override
  void performLayout() {
    _hasLayoutErrors = false;
    size = constraints.biggest;

    if (child != null) {
      if (_cellMapping.columnIndex + _cellMapping.columnSpan > _columnsMetrics.length) {
        _hasLayoutErrors = true;
        throw StateError(
            'The column span exceeds the table\'s column limit at row ${_cellMapping.rowIndex}, starting from column ${_cellMapping.columnIndex}.');
      }
      /*
      else if (rowRegion.hasData &&
          rowIndex + rowSpan > _model.rowsLength) {
        _hasLayoutErrors = true;
        throw StateError(
            'The row span exceeds the table\'s row limit at row $rowIndex and column $columnIndex.');
      }*/


      double width = 0;
      for (int i = _cellMapping.columnIndex; i < _cellMapping.columnIndex + _cellMapping.columnSpan; i++) {
        final ColumnMetrics columnMetrics = _columnsMetrics[i];
        width += columnMetrics.width;
        if (i < _cellMapping.columnIndex + _cellMapping.columnSpan - 1) {
          width += _columnDividerThickness;
        }
      }

      double height = 0;
      for (int i = _cellMapping.rowIndex; i < _cellMapping.rowIndex + _cellMapping.rowSpan; i++) {
        height += _cellHeight;
        if (i < _cellMapping.rowIndex + _cellMapping.rowSpan - 1) {
          height += _dividerThickness;
        }
      }
      
      child!.layout(BoxConstraints.tightFor(width: width,height: height), parentUsesSize: true);

      final CustomParentData childParentData = child!.parentData as CustomParentData;
      childParentData.offset =Offset.zero;
    }
  }



  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasLayoutErrors ||
        constraints.maxWidth == 0 ||
        constraints.maxHeight == 0) {
      return;
    }

    if (child != null) {
      final int rowIndex = _cellMapping.rowIndex;
      final ColumnMetrics columnMetrics = _columnsMetrics[_cellMapping.columnIndex];

      context.canvas.save();
      context.canvas.clipRect(_areaBounds.translate(offset.dx, offset.dy));

      final double top = (rowIndex * _rowHeight) - verticalOffset;
      final Offset childOffset =
      offset.translate(columnMetrics.offset - horizontalOffset, top);

      context.paintChild(child!, childOffset);
      context.canvas.restore();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      //TODO
      final CustomParentData childParentData = child!.parentData as CustomParentData;
      final Offset childOffset = childParentData.offset;
      if (position.dx >= childOffset.dx &&
          position.dx <= childOffset.dx + child!.size.width &&
          position.dy >= childOffset.dy &&
          position.dy <= childOffset.dy + child!.size.height) {
        return child!.hitTest(result, position: position - childOffset);
      }
    }
    return false;
  }
}