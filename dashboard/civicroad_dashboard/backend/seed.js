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

// Seed admin user
const hash = bcrypt.hashSync("admin123", 10);
db.prepare(
  "INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?)"
).run("admin@civicroad.gov", hash, "Sarah Mitchell", "admin");

db.prepare(
  "INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?)"
).run("ops@civicroad.gov", hash, "John Carter", "operator");

// Seed reports
const reports = [
  {
    title: "Large pothole on Market St",
    description: "Approx. 40cm wide. Dangerous for cyclists at night.",
    category: "road",
    status: "in_progress",
    image_url: "https://images.unsplash.com/photo-1592859600972-1b0834d83747?w=400",
    latitude: 37.7749,
    longitude: -122.4194,
    location_text: "Market St & 5th St, San Francisco",
    user_name: "Maria Lopez",
    assigned_to: "Road Maintenance Unit B",
  },
  {
    title: "Streetlight out near park",
    description: "The light has been off for 3 days.",
    category: "lighting",
    status: "pending",
    image_url: "https://images.unsplash.com/photo-1517524206127-48bbd363f3d7?w=400",
    latitude: 37.7849,
    longitude: -122.4094,
    location_text: "Dolores Park East entrance",
    user_name: "James Chen",
    assigned_to: null,
  },
  {
    title: "Overflowing trash bin",
    description: "Garbage piling up around the bin near the bus stop.",
    category: "sanitation",
    status: "resolved",
    image_url: "https://images.unsplash.com/photo-1605600659908-0ef719419d41?w=400",
    latitude: 37.7649,
    longitude: -122.4294,
    location_text: "16th St BART Station",
    user_name: "Aisha Williams",
    assigned_to: "Sanitation Team A",
  },
  {
    title: "Cracked sidewalk causing trips",
    description: "Several elderly residents have stumbled here.",
    category: "road",
    status: "pending",
    image_url: "https://images.unsplash.com/photo-1591768793355-74d04bb6608f?w=400",
    latitude: 37.7549,
    longitude: -122.4394,
    location_text: "Valencia St & 24th St",
    user_name: "Tom Rivera",
    assigned_to: null,
  },
  {
    title: "Graffiti on public mural",
    description: "Tag on the corner of the heritage mural.",
    category: "other",
    status: "in_progress",
    image_url: "https://images.unsplash.com/photo-1547235001-d703406d3f17?w=400",
    latitude: 37.7449,
    longitude: -122.4494,
    location_text: "Mission St & 18th St",
    user_name: "Priya Singh",
    assigned_to: "Cleanup Crew C",
  },
  {
    title: "Flooded crosswalk",
    description: "Drainage clogged after rain. Dangerous for pedestrians.",
    category: "road",
    status: "resolved",
    image_url: "https://images.unsplash.com/photo-1547486983-d1ee2099f8ce?w=400",
    latitude: 37.7349,
    longitude: -122.4094,
    location_text: "Castro St & Market St",
    user_name: "Diego Martinez",
    assigned_to: "Road Maintenance Unit A",
  },
  {
    title: "Broken park bench",
    description: "Bench plank broken — child got a splinter.",
    category: "other",
    status: "pending",
    image_url: "https://images.unsplash.com/photo-1568712320089-5cf5b3686b6c?w=400",
    latitude: 37.7249,
    longitude: -122.4194,
    location_text: "Alamo Square Park",
    user_name: "Emma Brown",
    assigned_to: null,
  },
  {
    title: "Faulty traffic light",
    description: "The red signal flickers — could cause accidents.",
    category: "lighting",
    status: "in_progress",
    image_url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400",
    latitude: 37.7949,
    longitude: -122.3994,
    location_text: "Embarcadero & Folsom",
    user_name: "Liam O'Brien",
    assigned_to: "Lighting Crew B",
  },
];

const insert = db.prepare(
  `INSERT INTO reports
    (title, description, category, status, image_url, latitude, longitude, location_text, user_name, assigned_to, created_at)
   VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now', ?))`
);

reports.forEach((r, i) => {
  insert.run(
    r.title,
    r.description,
    r.category,
    r.status,
    r.image_url,
    r.latitude,
    r.longitude,
    r.location_text,
    r.user_name,
    r.assigned_to,
    `-${i} days`
  );
});

console.log("✓ Seeded admin (admin@civicroad.gov / admin123)");
console.log(`✓ Seeded ${reports.length} reports`);
