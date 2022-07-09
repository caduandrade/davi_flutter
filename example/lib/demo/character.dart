import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:convert';

enum Skill {
  favorite,
  grade,
  pets,
  science,
  shield,
  wbSunny,
  flashOn,
  adjust,
  flare,
  filterVintage,
  workspaces,
  cloud,
  acUnit
}

extension on Skill {
  int compareTo(Skill other) => index.compareTo(other.index);
}

class Character {
  Character(
      {required this.name,
      required this.male,
      required this.age,
      required this.race,
      required this.gold,
      required this.cls,
      required this.level,
      required this.strength,
      required this.intelligence,
      required this.dexterity,
      required this.life,
      required this.mana,
      required this.skills});

  final String name;
  final bool male;
  final int age;
  final String race;
  final String cls;
  final double? gold;
  final int level;
  final int strength;
  final int intelligence;
  final int dexterity;
  final int mana;
  final int life;
  final List<Skill> skills;

  bool get female => !male;

  static const List<String> _races = [
    'Dwarf',
    'Elf',
    'Hobbit',
    'Human',
    'Goblin',
    'Golem',
    'Orc',
    'Troll',
    'Angel',
    'Elemental',
    'Undead'
  ];

  static const List<String> _classes = [
    'Warrior',
    'Assassin',
    'Mage',
    'Ranger',
    'Berserker',
    'Cleric',
    'Necromancer',
    'Summoner',
    'Bard',
    'Monk',
    'Paladin',
    'Druid'
  ];

  static Future<List<Character>> loadCharacters() async {
    math.Random random = math.Random();
    List<Character> list = [];
    for (String name in await _readNames('data/females.txt')) {
      list.add(_character(name: name, male: false, random: random));
    }
    for (String name in await _readNames('data/males.txt')) {
      list.add(_character(name: name, male: true, random: random));
    }
    list.shuffle();
    return list;
  }

  static Future<List<String>> _readNames(String filePath) async {
    String names = await rootBundle.loadString(filePath);
    LineSplitter ls = const LineSplitter();
    return ls.convert(names);
  }

  static Character _character(
      {required String name, required bool male, required math.Random random}) {
    String race = _races[random.nextInt(_races.length)];
    int age = 20 + random.nextInt(80);
    String cls = _classes[random.nextInt(_classes.length)];
    int level = 1 + (random.nextInt(100) * random.nextDouble()).round();
    int strength =
        math.max(level + random.nextInt(100) - random.nextInt(20), 10);
    int intelligence =
        math.max(level + random.nextInt(100) - random.nextInt(20), 10);
    int dexterity =
        math.max(level + random.nextInt(100) - random.nextInt(20), 10);
    int mana = level + random.nextInt(500);
    int life = level + random.nextInt(5000);
    double? gold =
        life % 3 == 0 ? null : random.nextInt(500000) * random.nextDouble();

    Set<Skill> uniqueSkills = {};
    int skillsCount = random.nextInt(4);
    for (int i = 0; i < skillsCount; i++) {
      uniqueSkills.add(Skill.values[random.nextInt(Skill.values.length)]);
    }
    List<Skill> skills = uniqueSkills.toList();
    skills.sort((a, b) => a.compareTo(b));

    return Character(
        cls: cls,
        name: name,
        race: race,
        age: age,
        male: male,
        gold: gold,
        level: level,
        strength: strength,
        intelligence: intelligence,
        dexterity: dexterity,
        life: life,
        mana: mana,
        skills: skills);
  }
}
