import 'package:flutter/material.dart';
import 'character.dart';

class SkillsWidget extends StatelessWidget {
  const SkillsWidget({super.key, required this.skills});

  final List<Skill> skills;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (Skill skill in skills) {
      IconData? iconData;
      Color? color;
      if (skill == Skill.favorite) {
        iconData = Icons.favorite;
        color = Colors.red;
      } else if (skill == Skill.grade) {
        iconData = Icons.grade;
        color = Colors.teal;
      } else if (skill == Skill.pets) {
        iconData = Icons.pets;
        color = Colors.green;
      } else if (skill == Skill.science) {
        iconData = Icons.science;
        color = Colors.blue;
      } else if (skill == Skill.shield) {
        iconData = Icons.shield;
        color = Colors.indigo;
      } else if (skill == Skill.wbSunny) {
        iconData = Icons.wb_sunny;
        color = Colors.orange;
      } else if (skill == Skill.flashOn) {
        iconData = Icons.flash_on;
        color = Colors.orange;
      } else if (skill == Skill.adjust) {
        iconData = Icons.adjust;
        color = Colors.brown;
      } else if (skill == Skill.flare) {
        iconData = Icons.flare;
        color = Colors.brown;
      } else if (skill == Skill.filterVintage) {
        iconData = Icons.filter_vintage;
        color = Colors.green;
      } else if (skill == Skill.workspaces) {
        iconData = Icons.workspaces;
        color = Colors.purple;
      } else if (skill == Skill.cloud) {
        iconData = Icons.cloud;
        color = Colors.blue;
      } else if (skill == Skill.acUnit) {
        iconData = Icons.ac_unit;
        color = Colors.blue;
      }
      if (color == null || iconData == null) {
        throw StateError('Null');
      }
      children.add(Flexible(
          child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(iconData, color: color))));
    }
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center, children: children);
  }
}
