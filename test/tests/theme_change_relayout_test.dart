import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  _Row(this.name);
  final String name;
}

/// A plain mutable holder (not a ChangeNotifier) so the column's
/// `cellWidget` closure can read a value that changes independently of
/// widget construction - the row's rebuild is driven entirely by the
/// surrounding `setState`, exactly like demo.dart driving Davi's rebuild
/// from its own settings state.
class _RowHeightHolder {
  double row1Height = 20;
}

class _ThemeChanger extends StatefulWidget {
  const _ThemeChanger({super.key, required this.model});
  final DaviModel<_Row> model;

  @override
  State<_ThemeChanger> createState() => _ThemeChangerState();
}

class _ThemeChangerState extends State<_ThemeChanger> {
  double _dividerThickness = 1;

  void bumpDividerThickness() {
    setState(() => _dividerThickness = 20);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: SizedBox(
                height: 400,
                child: DaviTheme(
                    data: DaviThemeData(
                        row: RowThemeData(
                            dividerThickness: _dividerThickness)),
                    child: Davi<_Row>(widget.model)))));
  }
}

void main() {
  testWidgets(
      'a settings change that both touches an unrelated scalar theme field '
      'AND changes row content height relayouts the cell to its NEW height, '
      'not a stale one left over from a skipped layout pass (regression: '
      'RowExtentManager is mutated in place, so RenderCustomSingleChild must '
      'not gate its own relayout on reference equality)',
      (WidgetTester tester) async {
    const Key tallKey = Key('row1-cell');
    final _RowHeightHolder holder = _RowHeightHolder();
    final DaviModel<_Row> model = DaviModel<_Row>(
        rows: [_Row('a'), _Row('b'), _Row('c')],
        columns: [
          DaviColumn<_Row>(
              name: 'Content',
              cellWidget: (params) => params.rowIndex == 1
                  ? SizedBox(
                      key: tallKey,
                      height: holder.row1Height,
                      child: Container(color: Colors.red))
                  : Text(params.data.name)),
        ]);

    final GlobalKey<_ThemeChangerState> changerKey =
        GlobalKey<_ThemeChangerState>();
    await tester.pumpWidget(_ThemeChanger(model: model, key: changerKey));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(tallKey)).height, 20);

    // A single settings change: bump dividerThickness (an unrelated scalar
    // that already has its own dedicated, correctly-detected setter) AND
    // grow row 1's real content height, exactly like a demo.dart settings
    // toggle that rebuilds Davi's theme while some row's content also
    // legitimately changes size.
    holder.row1Height = 150;
    changerKey.currentState!.bumpDividerThickness();
    await tester.pump();

    expect(tester.takeException(), isNull);
    // Must reflect the NEW height within this same frame - not the old
    // (20) one left over from a RenderCustomSingleChild whose own layout
    // was skipped because nothing flagged it as dirty.
    expect(tester.getSize(find.byKey(tallKey)).height, 150);
  });
}
