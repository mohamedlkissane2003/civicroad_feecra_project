# CivicRoad Project

This repository contains:

- `application_mobile`: Flutter mobile app for citizens to submit urban issue reports.
- `dashboard/civicroad_dashboard/backend`: Node.js + Express + SQLite API.
- `dashboard/civicroad_dashboard/frontend`: React + Vite municipal dashboard.

## Prerequisites

- Flutter SDK (compatible with Dart `^3.10.7`)
- Node.js 18+
- npm
- Android Studio (or another emulator/device setup) for mobile testing

## 1. Run the Dashboard Backend (API)

Open a terminal in:

`dashboard/civicroad_dashboard/backend`

Run:

```bash
npm install
copy .env.example .env
npm run seed
npm run dev
```

Backend runs on:

- `http://localhost:4000`

Default admin credentials:

- Email: `admin@civicroad.gov`
- Password: `admin123`

## 2. Run the Dashboard Frontend

Open a second terminal in:

`dashboard/civicroad_dashboard/frontend`

Run:

```bash
npm install
npm run dev
```

Dashboard URL:

- `http://localhost:5173`

The frontend is already configured to proxy `/api` and `/ws` to `localhost:4000`.

## 3. Run the Flutter Mobile App

Open a third terminal in:

`application_mobile`

Run:

```bash
flutter pub get
flutter run
```

### Mobile API base URL behavior

The app uses this logic:

- Android emulator: `http://10.0.2.2:4000`
- Other platforms (default): `http://localhost:4000`
- Optional override with compile-time define: `CIVICROAD_API_BASE_URL`

Example override:

```bash
flutter run --dart-define=CIVICROAD_API_BASE_URL=http://<YOUR_IP>:4000
```

Use this override when running on a real phone or when `localhost` is not reachable from your device.

## Typical Startup Order

1. Start backend (`npm run dev`)
2. Start dashboard frontend (`npm run dev`)
3. Start Flutter mobile app (`flutter run`)

## Quick Verification

- Open dashboard at `http://localhost:5173` and login with admin credentials.
- Submit a report from the mobile app.
- Confirm the new report appears on the dashboard and updates in real time.