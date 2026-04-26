# CivicRoad — Municipality Dashboard

A production-ready full-stack smart city dashboard for municipalities to monitor and manage citizen-submitted road and infrastructure reports.

## Tech Stack

- **Frontend:** React + Vite + Tailwind CSS, React Router, Recharts, React-Leaflet, Axios
- **Backend:** Node.js + Express, SQLite (better-sqlite3), JWT auth, WebSockets (`ws`)
- **Real-time:** WebSocket broadcast of new/updated/deleted reports

## Features

- ✅ JWT-based admin authentication (login screen + protected routes)
- ✅ Sidebar navigation: Dashboard, Reports, Map, Analytics, Users, Settings
- ✅ Topbar with search, dark-mode toggle, and live notifications
- ✅ Dashboard with KPI cards (Total / Pending / In Progress / Resolved) + resolution-rate ring
- ✅ Reports management with category/status/search filters
- ✅ Update status, assign teams, delete reports
- ✅ CSV export
- ✅ Interactive Leaflet map with color-coded status markers
- ✅ Analytics: bar chart, pie chart, 7-day line chart (Recharts)
- ✅ Real-time updates via WebSockets — new reports appear instantly
- ✅ Dark-mode support (toggle in topbar)
- ✅ Public `POST /api/reports` endpoint for the mobile app to submit reports

## Project Structure

```
civicroad_dashboard/
├── backend/
│   ├── server.js          # Express + WebSocket + all routes
│   ├── seed.js            # Seeds admin user + 8 sample reports
│   ├── package.json
│   └── .env.example
└── frontend/
    ├── index.html
    ├── vite.config.js     # Proxies /api and /ws to backend
    ├── tailwind.config.js
    ├── postcss.config.js
    ├── package.json
    └── src/
        ├── main.jsx
        ├── App.jsx        # Router + auth gate
        ├── api.js         # Axios + WebSocket helper
        ├── auth.jsx       # AuthContext (login / logout / me)
        ├── index.css
        ├── components/
        │   ├── Layout.jsx       # Sidebar + Topbar + dark mode + notifications
        │   ├── StatCard.jsx
        │   └── StatusBadge.jsx
        └── pages/
            ├── Login.jsx
            ├── Dashboard.jsx
            ├── Reports.jsx
            ├── ReportDetail.jsx # Includes embedded Leaflet map
            ├── MapView.jsx
            ├── Analytics.jsx
            ├── Users.jsx
            └── Settings.jsx
```

## Setup & Run

### 1. Backend

```bash
cd backend
npm install
cp .env.example .env       # edit JWT_SECRET if you want
npm run seed               # creates DB + admin + 8 sample reports
npm run dev                # http://localhost:4000
```

Default admin login:
- **Email:** `admin@civicroad.gov`
- **Password:** `admin123`

### 2. Frontend

In a separate terminal:

```bash
cd frontend
npm install
npm run dev                # http://localhost:5173
```

The Vite dev server proxies `/api` and `/ws` to the backend automatically.

Open **http://localhost:5173** and log in with the demo credentials above.

## API Endpoints

| Method | Path                       | Auth     | Description                                   |
|--------|----------------------------|----------|-----------------------------------------------|
| POST   | `/api/auth/login`          | No       | Returns `{ token, user }`                     |
| GET    | `/api/auth/me`             | Yes      | Current logged-in user                        |
| GET    | `/api/reports`             | Yes      | List all reports (filter: category/status/search) |
| GET    | `/api/reports/stats`       | Yes      | Totals + by-category + last-7-days            |
| GET    | `/api/reports/:id`         | Yes      | Single report                                 |
| POST   | `/api/reports`             | **No**   | Public — used by mobile app to submit         |
| PUT    | `/api/reports/:id`         | Yes      | Update status / assigned_to / etc.            |
| DELETE | `/api/reports/:id`         | Yes      | Delete                                        |
| GET    | `/api/users`               | Yes      | List dashboard users                          |
| WS     | `/ws`                      | No       | Broadcasts `report:created/updated/deleted`   |

## Mobile App Integration

The mobile app should `POST` to `/api/reports` with this body:

```json
{
  "title": "Pothole on Market St",
  "description": "Approx 40cm wide…",
  "category": "road",
  "image_url": "https://…",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "location_text": "Market St & 5th, SF",
  "user_name": "Jane Doe"
}
```

Dashboard clients receive the new report via WebSocket immediately and a toast notification fires in the topbar.

## Production Build

```bash
cd frontend && npm run build       # outputs to frontend/dist
cd ../backend && NODE_ENV=production npm start
```

You can serve `frontend/dist` from any static host (Nginx, Vercel, Netlify, S3, etc.) and point it at your deployed backend.

---

Built for hackathon-grade demos and ready to extend for real city deployments.
