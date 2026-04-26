import "dotenv/config";
import Database from "better-sqlite3";
import bcrypt from "bcryptjs";

const DB_FILE = process.env.DB_FILE || "./civicroad.db";
const db = new Database(DB_FILE);

db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'admin',
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    image_url TEXT,
    latitude REAL,
    longitude REAL,
    location_text TEXT,
    user_name TEXT,
    assigned_to TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
  );
`);

// Wipe existing
db.exec("DELETE FROM users; DELETE FROM reports;");
db.prepare("DELETE FROM reports").run();

// Seed admin user
const hash = bcrypt.hashSync("admin123", 10);
db.prepare(
  "INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?)"
).run("admin@civicroad.gov", hash, "Sarah Mitchell", "admin");

db.prepare(
  "INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?)"
).run("ops@civicroad.gov", hash, "John Carter", "operator");

console.log("✓ Seeded admin (admin@civicroad.gov / admin123)");
console.log("✓ Cleared reports and left the dashboard empty by default");
