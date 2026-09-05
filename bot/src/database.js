const Database = require('better-sqlite3');
const path = require('path');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, '..', 'data', 'schoolbuzz.db');
let db;

function initDatabase() {
  const fs = require('fs');
  const dir = path.dirname(DB_PATH);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

  db = new Database(DB_PATH);
  db.pragma('journal_mode = WAL');

  db.exec(`
    CREATE TABLE IF NOT EXISTS events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      actionType TEXT NOT NULL,
      caregiverName TEXT NOT NULL,
      caregiverPhone TEXT NOT NULL,
      schoolName TEXT NOT NULL,
      customMessage TEXT,
      timestamp TEXT NOT NULL,
      createdAt TEXT DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
  `);

  // Initialize default settings if not exists
  const defaults = {
    schoolName: process.env.DEFAULT_SCHOOL_NAME || 'School',
    cooldownMinutes: process.env.DEFAULT_COOLDOWN_MINUTES || '30',
    caregiverNames: process.env.CAREGIVER_NAMES || 'Dad,Mom',
  };

  const insertSetting = db.prepare(
    'INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)'
  );

  for (const [key, value] of Object.entries(defaults)) {
    insertSetting.run(key, value);
  }

  console.log('✅ Database initialized');
}

// ─── Events ──────────────────────────────────────────────

function saveEvent({ actionType, caregiverName, caregiverPhone, schoolName, timestamp, customMessage }) {
  const stmt = db.prepare(`
    INSERT INTO events (actionType, caregiverName, caregiverPhone, schoolName, customMessage, timestamp)
    VALUES (?, ?, ?, ?, ?, ?)
  `);
  const result = stmt.run(actionType, caregiverName, caregiverPhone, schoolName, customMessage || null, timestamp.toISOString());
  return { id: result.lastInsertRowid, actionType, caregiverName, timestamp };
}

function getRecentEvents(limit = 10) {
  return db.prepare('SELECT * FROM events ORDER BY createdAt DESC LIMIT ?').all(limit);
}

function getLastEvent() {
  return db.prepare('SELECT * FROM events ORDER BY createdAt DESC LIMIT 1').get();
}

function getEventsByDate(dateStr) {
  return db.prepare("SELECT * FROM events WHERE DATE(timestamp) = ? ORDER BY timestamp DESC").all(dateStr);
}

function getEventsByCaregiver(caregiverName) {
  return db.prepare('SELECT * FROM events WHERE caregiverName = ? ORDER BY createdAt DESC LIMIT 20').all(caregiverName);
}

function clearEvents() {
  db.prepare('DELETE FROM events').run();
}

// ─── Settings ────────────────────────────────────────────

function getSettings() {
  const rows = db.prepare('SELECT key, value FROM settings').all();
  const settings = {};
  for (const row of rows) {
    settings[row.key] = row.value;
  }
  return {
    schoolName: settings.schoolName || 'School',
    cooldownMinutes: parseInt(settings.cooldownMinutes) || 30,
    caregiverNames: settings.caregiverNames || 'Dad,Mom',
  };
}

function updateSettings(updates) {
  const stmt = db.prepare('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)');
  for (const [key, value] of Object.entries(updates)) {
    stmt.run(key, String(value));
  }
}

// ─── CLI Setup ───────────────────────────────────────────
if (process.argv.includes('--setup')) {
  initDatabase();
  console.log('Database setup complete.');
  process.exit(0);
}

module.exports = {
  initDatabase,
  saveEvent,
  getRecentEvents,
  getLastEvent,
  getEventsByDate,
  getEventsByCaregiver,
  clearEvents,
  getSettings,
  updateSettings,
};
