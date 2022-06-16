import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_child_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_element_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_render_box_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_painting_settings.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings_v3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// [EasyTable] table layout.
@internal
class RowsLayoutV3<ROW> extends MultiChildRenderObjectWidget {
  RowsLayoutV3(
      {Key? key,
      required this.layoutSettings,
      required this.paintSettings,
      required List<RowsLayoutChildV3> children})
      : super(key: key, children: children);

  final TableLayoutSettingsV3<ROW> layoutSettings;
  final RowsPaintingSettings paintSettings;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RowsLayoutRenderBoxV3<ROW>(
        layoutSettings: layoutSettings, paintSettings: paintSettings);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return RowsLayoutElementV3(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RowsLayoutRenderBoxV3 renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..layoutSettings = layoutSettings
      ..paintSettings = paintSettings;
  }
}
