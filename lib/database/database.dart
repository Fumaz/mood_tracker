import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Day {
  final int day;
  final int month;
  final int year;
  Mood? mood;
  String? note;

  Day(this.day, this.month, this.year, {this.mood, this.note});

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'month': month,
      'year': year,
      'mood': mood?.index,
      'note': note,
    };
  }

  @override
  String toString() {
    return 'Day{day: $day, month: $month, year: $year, mood: $mood, note: $note}';
  }
}

enum Mood {
  unknown, excited, happy, relaxed, neutral, sad, stressed, angry
}

String getEmoji(Mood mood) {
  switch (mood) {
    case Mood.unknown:
      return '❓';
    case Mood.excited:
      return '😄';
    case Mood.happy:
      return '😃';
    case Mood.relaxed:
      return '😊';
    case Mood.neutral:
      return '😐';
    case Mood.sad:
      return '😔';
    case Mood.stressed:
      return '😕';
    case Mood.angry:
      return '😡';
  }
}

late Future<Database> database;

Future<void> insertDay(Day day) async {
  final Database db = await database;

  await db.insert(
    'days',
    day.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> updateDay(Day day) async {
  final Database db = await database;

  await db.update(
    'days',
    day.toMap(),
    where: 'day = ? AND month = ? AND year = ?',
    whereArgs: [day.day, day.month, day.year],
  );
}

Future<List<Day>> days() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('days');

  return List.generate(maps.length, (i) {
    return Day(
      maps[i]['day'],
      maps[i]['month'],
      maps[i]['year'],
      mood: maps[i]['mood'] != null ? Mood.values[maps[i]['mood']] : null,
      note: maps[i]['note'],
    );
  });
}

Future<Day> day(int day, int month, int year) async {
  final db = await database;
  List<Map<String, dynamic>> map = await db.query('days',
      where: 'day = ? AND month = ? AND year = ?',
      whereArgs: [day, month, year]);

  if (map.isEmpty) {
    return Day(day, month, year);
  }

  Mood? mood = map[0]['mood'] != null ? Mood.values[map[0]['mood']] : null;

  return Day(day, month, year, mood: mood, note: map[0]['note']);
}

void setup() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Creating database');
  database = openDatabase(join(await getDatabasesPath(), 'mood_database.db'),
      onCreate: (db, version) {
    // language=SQLite
    return db.execute(
        'CREATE TABLE days(day INTEGER, month INTEGER, year INTEGER, mood INTEGER, note TEXT, PRIMARY KEY (day, month, year))');
  }, version: 1);
}
