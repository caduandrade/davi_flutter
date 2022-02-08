import 'package:flutter/widgets.dart';

class EasyTableCell extends StatelessWidget {
  const EasyTableCell({Key? key, required this.value}) : super(key: key);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Align(
        child: Text(value, overflow: TextOverflow.ellipsis),
        alignment: Alignment.centerLeft);
  }
}
