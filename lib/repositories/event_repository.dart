import '../models/event.dart';
import 'database_helper.dart';

class EventRepository {
  Future<List<SchoolEvent>> getAll() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('school_events', orderBy: 'createdAt DESC', limit: 100);
    return maps.map((m) => SchoolEvent.fromMap(m)).toList();
  }

  Future<void> insert(SchoolEvent event) async {
    final db = await DatabaseHelper.database;
    await db.insert('school_events', event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<SchoolEvent?> getLastEvent() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('school_events', orderBy: 'eventTime DESC', limit: 1);
    return maps.isEmpty ? null : SchoolEvent.fromMap(maps.first);
  }

  Future<void> updateShareStatus(String eventId, ShareStatus status) async {
    final db = await DatabaseHelper.database;
    await db.update('school_events', {'shareStatus': status.name},
        where: 'eventId = ?', whereArgs: [eventId]);
  }

  Future<void> clearAll() async {
    final db = await DatabaseHelper.database;
    await db.delete('school_events');
  }
}
