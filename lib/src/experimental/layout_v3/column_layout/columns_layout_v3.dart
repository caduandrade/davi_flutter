import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_child_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_element_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_render_box_v3.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings_v3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// [EasyTable] table layout.
@internal
class ColumnsLayoutV3<ROW> extends MultiChildRenderObjectWidget {
  ColumnsLayoutV3(
      {Key? key,
      required this.layoutSettings,
      required List<ColumnsLayoutChildV3> children})
      : super(key: key, children: children);

  final TableLayoutSettingsV3<ROW> layoutSettings;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ColumnsLayoutRenderBoxV3<ROW>(layoutSettings: layoutSettings);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return ColumnsLayoutElementV3(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant ColumnsLayoutRenderBoxV3 renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject.layoutSettings = layoutSettings;
  }
}
