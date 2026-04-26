import { useEffect, useState } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import L from "leaflet";
import { api } from "../api.js";

const colorIcon = (color) =>
  L.divIcon({
    className: "",
    html: `<div style="width:20px;height:20px;border-radius:50%;background:${color};border:3px solid white;box-shadow:0 2px 6px rgba(0,0,0,0.3);"></div>`,
    iconSize: [20, 20],
    iconAnchor: [10, 10],
  });

const COLORS = {
  pending: "#F59E0B",
  in_progress: "#3B82F6",
  resolved: "#10B981",
};

export default function MapView() {
  const [reports, setReports] = useState([]);

  useEffect(() => {
    api.get("/reports").then((r) => setReports(r.data));
  }, []);

  useEffect(() => {
    const refresh = () => {
      api.get("/reports").then((r) => setReports(r.data));
    };

    window.addEventListener("civicroad:reports-changed", refresh);
    return () => window.removeEventListener("civicroad:reports-changed", refresh);
  }, []);

  const center = reports.length
    ? [reports[0].latitude, reports[0].longitude]
    : [37.7749, -122.4194];

  return (
    <div className="space-y-4 h-[calc(100vh-7rem)] flex flex-col">
      <div>
        <h1 className="text-2xl font-bold dark:text-white">Map View</h1>
        <p className="text-sm text-slate-500">All reports plotted on an interactive map.</p>
      </div>

      <div className="card flex-1 overflow-hidden">
        <MapContainer center={center} zoom={13} style={{ height: "100%", width: "100%" }}>
          <TileLayer
            attribution='&copy; OpenStreetMap contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          {reports.map((r) =>
            r.latitude && r.longitude ? (
              <Marker
                key={r.id}
                position={[r.latitude, r.longitude]}
                icon={colorIcon(COLORS[r.status] || "#94A3B8")}
              >
                <Popup>
                  <div className="space-y-1">
                    <div className="font-semibold">{r.title}</div>
                    <div className="text-xs text-slate-500">{r.location_text}</div>
                    <div className="text-xs">Status: {r.status}</div>
                  </div>
                </Popup>
              </Marker>
            ) : null
          )}
        </MapContainer>
      </div>
    </div>
  );
}
