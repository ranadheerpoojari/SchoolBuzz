import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'schoolbuzz.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE school_events (
            eventId TEXT PRIMARY KEY,
            childId TEXT NOT NULL,
            childNameSnapshot TEXT NOT NULL,
            caregiverId TEXT NOT NULL,
            caregiverNameSnapshot TEXT NOT NULL,
            schoolId TEXT NOT NULL,
            actionType TEXT NOT NULL,
            eventTime INTEGER NOT NULL,
            source TEXT NOT NULL,
            shareStatus TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            customMessage TEXT
          )
        ''');
      },
    );
  }
}
