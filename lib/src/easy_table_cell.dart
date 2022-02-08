import 'package:flutter/widgets.dart';

class EasyTableCell extends StatelessWidget {
  const EasyTableCell({Key? key, this.value}) : super(key: key);

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

  factory EasyTableCell.int({Key? key, required int value}) {
    return EasyTableCell(key: key, value: value.toString());
  }

  final String? value;

  @override
  Widget build(BuildContext context) {
    Text? text;
    if (value != null) {
      text = Text(value!, overflow: TextOverflow.ellipsis);
    }
    return Align(child: text, alignment: Alignment.centerLeft);
  }
}
