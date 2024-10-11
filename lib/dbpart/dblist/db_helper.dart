import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  // Private constructor for singleton
  DbHelper._privateConstructor();

  // Create a single instance of DbHelper
  static final DbHelper _instance = DbHelper._privateConstructor();

  // Access point to the singleton instance
  static DbHelper get getInstance => _instance;

  Database? _database;

  // Column names
  static const String COLUMN_NOTE_SNO = 'S_NO';
  static const String COLUMN_NOTE_TITLE = 'title';
  static const String COLUMN_NOTE_DESC = 'desc';

  // Get database instance
  Future<Database> get database async {
    _database ??= await openDB();
    return _database!;
  }

  // Open or create the database
  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "TODO_List_Database.db");

    return await openDatabase(dbPath, version: 1, onCreate: (db, version) {
      db.execute(
          "CREATE TABLE NOTE($COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT, $COLUMN_NOTE_TITLE TEXT, $COLUMN_NOTE_DESC TEXT)");
    });
  }

  // Insert a new note
  Future<bool> addNote({
    required String title,
    required String desc,
  }) async {
    var db = await database;
    int rowsEffected = await db.insert(
        "NOTE", {'title': title, 'desc': desc});
    return rowsEffected > 0;
  }

  // Retrieve all notes
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await database;
    return await db.query("NOTE");
  }

  // Update a note
  Future<bool> updateNote({
    required String title,
    required String desc,
    required int sno,
  }) async {
    var db = await database;
    int rowsEffected = await db.update(
        "NOTE", {'title': title, 'desc': desc},
        where: "$COLUMN_NOTE_SNO = ?", whereArgs: [sno]);
    return rowsEffected > 0;
  }

  // Delete a note
  Future<bool> deleteNote({required int sno}) async {
    var db = await database;
    int rowsEffected =
        await db.delete("NOTE", where: "$COLUMN_NOTE_SNO = ?", whereArgs: [sno]);
    return rowsEffected > 0;
  }
}
