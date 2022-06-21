import 'package:flutter/material.dart';

class CheckboxUtil {
  static Widget build(
      {required bool value,
      required Function onChanged,
      required String text}) {
    return GestureDetector(
        onTap: () => onChanged(),
        child: Row(children: [
          Checkbox(value: value, onChanged: (v) => onChanged()),
          const SizedBox(width: 8),
          Text(text)
        ]));
  }
}
