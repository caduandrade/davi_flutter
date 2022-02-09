import 'package:flutter/widgets.dart';

/// Default cell. Used by automatic cell builder.
class EasyTableCell extends StatelessWidget {
  const EasyTableCell({Key? key, this.value, this.textStyle}) : super(key: key);

  /// Builds a cell that maps the value to a [double].
  factory EasyTableCell.double(
      {Key? key, required double value, int? fractionDigits}) {
    String? str;
    if (fractionDigits != null) {
      str = value.toStringAsFixed(fractionDigits);
    } else {
      str = value.toString();
    }
    return EasyTableCell(key: key, value: str);
  }

  /// Builds a cell that maps the value to a [int].
  factory EasyTableCell.int({Key? key, required int value}) {
    return EasyTableCell(key: key, value: value.toString());
  }

  final String? value;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    Text? text;
    if (value != null) {
      text = Text(value!, overflow: TextOverflow.ellipsis, style: textStyle);
    }
    return Align(child: text, alignment: Alignment.centerLeft);
  }
}
