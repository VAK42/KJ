import initSqlJs from 'sql.js';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import bcrypt from 'bcryptjs';
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const dbPath = join(__dirname, '..', 'data', 'kj.db');
const dataDir = join(__dirname, '..', 'data');
if (!existsSync(dataDir)) mkdirSync(dataDir, { recursive: true });
let db;
async function getDb() {
  if (db) return db;
  const sql = await initSqlJs();
  if (existsSync(dbPath)) {
    const data = readFileSync(dbPath);
    db = new sql.Database(data);
  } else {
    db = new sql.Database();
  }
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      passwordHash TEXT NOT NULL,
      isVerified INTEGER NOT NULL DEFAULT 0,
      verificationCode TEXT,
      codeExpiresAt INTEGER,
      resetCode TEXT,
      resetExpiresAt INTEGER,
      createdAt INTEGER NOT NULL DEFAULT (strftime('%s','now'))
    );
    CREATE TABLE IF NOT EXISTS quizResults (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      level TEXT NOT NULL,
      score INTEGER NOT NULL,
      total INTEGER NOT NULL,
      date TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users(id)
    );
  `);
  const em='vutrandangkhoa7@gmail.com';
  const stmt=db.prepare('SELECT id FROM users WHERE email=?');
  stmt.bind([em]);
  const hasUser=stmt.step();
  stmt.free();
  if(!hasUser){
    db.run('INSERT INTO users (email,passwordHash,isVerified) VALUES (?,?,?)',[em,bcrypt.hashSync('password',12),1]);
  }
  persist();
  return db;
}
function persist() {
  if (!db) return;
  const data = db.export();
  writeFileSync(dbPath, Buffer.from(data));
}
function dbGet(sql, params = []) {
  const stmt = db.prepare(sql);
  stmt.bind(params);
  if (stmt.step()) {
    const row = stmt.getAsObject();
    stmt.free();
    return row;
  }
  stmt.free();
  return null;
}
function dbAll(sql, params = []) {
  const stmt = db.prepare(sql);
  stmt.bind(params);
  const rows = [];
  while (stmt.step()) rows.push(stmt.getAsObject());
  stmt.free();
  return rows;
}
function dbRun(sql, params = []) {
  db.run(sql, params);
  persist();
}
export default { getDb, dbGet, dbAll, dbRun };