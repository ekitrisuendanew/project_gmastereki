import 'dart:io';
import 'package:project_gmastereki/model_sqflite/schedule_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'schedules.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE schedules(
          id INTEGER PRIMARY KEY,
          name TEXT
      )
      ''');
  }

  Future<List<ScheduleModel>> getSchedules() async {
    Database db = await instance.database;
    var schedules = await db.query('schedules', orderBy: 'name');
    List<ScheduleModel> scheduleList = schedules.isNotEmpty
        ? schedules.map((c) => ScheduleModel.fromMap(c)).toList()
        : [];
    return scheduleList;
  }

  Future<int> add(ScheduleModel schedule) async {
    Database db = await instance.database;
    return await db.insert('schedules', schedule.toMap());
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(ScheduleModel schedule) async {
    Database db = await instance.database;
    return await db.update('schedules', schedule.toMap(),
        where: "id = ?", whereArgs: [schedule.id]);
  }

}