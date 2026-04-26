import "dotenv/config";
import express from "express";
import cors from "cors";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import Database from "better-sqlite3";
import { WebSocketServer } from "ws";
import http from "http";

const PORT = process.env.PORT || 4000;
const JWT_SECRET = process.env.JWT_SECRET || "dev-secret";
const DB_FILE = process.env.DB_FILE || "./civicroad.db";

// ─── Database setup ──────────────────────────────────────────────────────────
const db = new Database(DB_FILE);
db.pragma("journal_mode = WAL");

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

// ─── App setup ──────────────────────────────────────────────────────────────
const app = express();
app.use(cors());
app.use(express.json({ limit: "10mb" }));

const server = http.createServer(app);
const wss = new WebSocketServer({ server, path: "/ws" });

function broadcast(event, payload) {
  const message = JSON.stringify({ event, payload });
  wss.clients.forEach((c) => {
    if (c.readyState === 1) c.send(message);
  });
}

// ─── Auth middleware ─────────────────────────────────────────────────────────
function authRequired(req, res, next) {
  const header = req.headers.authorization;
  if (!header) return res.status(401).json({ error: "Missing token" });
  const token = header.replace("Bearer ", "");
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: "Invalid token" });
  }
}

// ─── Auth routes ─────────────────────────────────────────────────────────────
app.post("/api/auth/login", (req, res) => {
  const { email, password } = req.body;
  const user = db.prepare("SELECT * FROM users WHERE email = ?").get(email);
  if (!user || !bcrypt.compareSync(password, user.password)) {
    return res.status(401).json({ error: "Invalid credentials" });
  }
  const token = jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    JWT_SECRET,
    { expiresIn: "7d" }
  );
  res.json({
    token,
    user: { id: user.id, email: user.email, name: user.name, role: user.role },
  });
});

app.get("/api/auth/me", authRequired, (req, res) => {
  const user = db
    .prepare("SELECT id, email, name, role FROM users WHERE id = ?")
    .get(req.user.id);
  res.json(user);
});

// ─── Reports routes ──────────────────────────────────────────────────────────
app.get("/api/reports", authRequired, (req, res) => {
  const { category, status, search } = req.query;
  let sql = "SELECT * FROM reports WHERE 1=1";
  const params = [];
  if (category && category !== "all") {
    sql += " AND category = ?";
    params.push(category);
  }
  if (status && status !== "all") {
    sql += " AND status = ?";
    params.push(status);
  }
  if (search) {
    sql += " AND (title LIKE ? OR description LIKE ? OR location_text LIKE ?)";
    const q = `%${search}%`;
    params.push(q, q, q);
  }
  sql += " ORDER BY created_at DESC";
  res.json(db.prepare(sql).all(...params));
});

app.get("/api/public/reports", (_req, res) => {
  res.json(db.prepare("SELECT * FROM reports ORDER BY created_at DESC").all());
});

app.get("/api/public/reports/:id", (req, res) => {
  const report = db.prepare("SELECT * FROM reports WHERE id = ?").get(req.params.id);
  if (!report) return res.status(404).json({ error: "Not found" });
  res.json(report);
});

app.get("/api/reports/stats", authRequired, (_req, res) => {
  const totals = db
    .prepare(
      `SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) AS pending,
        SUM(CASE WHEN status='in_progress' THEN 1 ELSE 0 END) AS inProgress,
        SUM(CASE WHEN status='resolved' THEN 1 ELSE 0 END) AS resolved
       FROM reports`
    )
    .get();

  const byCategory = db
    .prepare("SELECT category, COUNT(*) AS count FROM reports GROUP BY category")
    .all();

  const last7Days = db
    .prepare(
      `SELECT DATE(created_at) AS day, COUNT(*) AS count
       FROM reports
       WHERE created_at >= DATE('now', '-6 days')
       GROUP BY DATE(created_at)
       ORDER BY day`
    )
    .all();

  res.json({ totals, byCategory, last7Days });
});

app.get("/api/reports/:id", authRequired, (req, res) => {
  const r = db.prepare("SELECT * FROM reports WHERE id = ?").get(req.params.id);
  if (!r) return res.status(404).json({ error: "Not found" });
  res.json(r);
});

app.post("/api/reports", (req, res) => {
  // Public endpoint so the mobile app can submit reports
  const {
    title,
    description,
    category,
    image_url,
    latitude,
    longitude,
    location_text,
    user_name,
  } = req.body;

  const result = db
    .prepare(
      `INSERT INTO reports
        (title, description, category, status, image_url, latitude, longitude, location_text, user_name)
       VALUES (?, ?, ?, 'pending', ?, ?, ?, ?, ?)`
    )
    .run(
      title,
      description,
      category,
      image_url,
      latitude,
      longitude,
      location_text,
      user_name
    );

  const created = db
    .prepare("SELECT * FROM reports WHERE id = ?")
    .get(result.lastInsertRowid);

  broadcast("report:created", created);
  res.status(201).json(created);
});

app.put("/api/reports/:id", authRequired, (req, res) => {
  const { status, assigned_to, category, description, title } = req.body;
  const existing = db
    .prepare("SELECT * FROM reports WHERE id = ?")
    .get(req.params.id);
  if (!existing) return res.status(404).json({ error: "Not found" });

  db.prepare(
    `UPDATE reports
       SET status      = COALESCE(?, status),
           assigned_to = COALESCE(?, assigned_to),
           category    = COALESCE(?, category),
           description = COALESCE(?, description),
           title       = COALESCE(?, title)
     WHERE id = ?`
  ).run(status, assigned_to, category, description, title, req.params.id);

  const updated = db
    .prepare("SELECT * FROM reports WHERE id = ?")
    .get(req.params.id);
  broadcast("report:updated", updated);
  res.json(updated);
});

app.delete("/api/reports/:id", authRequired, (req, res) => {
  db.prepare("DELETE FROM reports WHERE id = ?").run(req.params.id);
  broadcast("report:deleted", { id: Number(req.params.id) });
  res.json({ ok: true });
});

// ─── Users routes ────────────────────────────────────────────────────────────
app.get("/api/users", authRequired, (_req, res) => {
  res.json(
    db.prepare("SELECT id, email, name, role, created_at FROM users").all()
  );
});

// ─── Start ────────────────────────────────────────────────────────────────────
server.listen(PORT, () => {
  console.log(`CivicRoad API running on http://localhost:${PORT}`);
  console.log(`WebSocket server on ws://localhost:${PORT}/ws`);
});
