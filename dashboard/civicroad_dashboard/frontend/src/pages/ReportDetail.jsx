import { useEffect, useState } from "react";
import { useParams, Link } from "react-router-dom";
import { ArrowLeft, MapPin, Calendar, User, Tag } from "lucide-react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import { api } from "../api.js";
import StatusBadge from "../components/StatusBadge.jsx";

export default function ReportDetail() {
  const { id } = useParams();
  const [report, setReport] = useState(null);
  const [assignedTo, setAssignedTo] = useState("");

  function load() {
    api.get(`/reports/${id}`).then((r) => {
      setReport(r.data);
      setAssignedTo(r.data.assigned_to || "");
    });
  }

  useEffect(load, [id]);

  async function updateStatus(status) {
    await api.put(`/reports/${id}`, { status });
    load();
  }

  async function assignTeam() {
    await api.put(`/reports/${id}`, { assigned_to: assignedTo });
    load();
  }

  if (!report) return <div className="text-slate-500">Loading…</div>;

  return (
    <div className="space-y-6 max-w-5xl">
      <Link to="/reports" className="inline-flex items-center gap-2 text-sm text-slate-600 dark:text-slate-300 hover:text-primary">
        <ArrowLeft className="w-4 h-4" /> Back to Reports
      </Link>

      <div className="card overflow-hidden">
        <img src={report.image_url} alt="" className="w-full h-72 object-cover bg-slate-100" />
        <div className="p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <h1 className="text-2xl font-bold dark:text-white mb-1">{report.title}</h1>
              <p className="text-slate-500 dark:text-slate-400">Report #{report.id}</p>
            </div>
            <StatusBadge status={report.status} />
          </div>

          <p className="text-slate-700 dark:text-slate-300 mb-6">{report.description}</p>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
            <Detail icon={Tag} label="Category" value={report.category} />
            <Detail icon={MapPin} label="Location" value={report.location_text} />
            <Detail icon={Calendar} label="Submitted" value={new Date(report.created_at).toLocaleString()} />
            <Detail icon={User} label="Reported by" value={report.user_name} />
          </div>

          <div className="card p-4 mb-6">
            <div className="font-semibold mb-2 dark:text-white">Assign Team</div>
            <div className="flex gap-2">
              <input
                value={assignedTo}
                onChange={(e) => setAssignedTo(e.target.value)}
                placeholder="e.g. Road Maintenance Unit B"
                className="flex-1 px-3 py-2 rounded-lg border border-slate-200 dark:bg-slate-800 dark:border-slate-700 dark:text-white text-sm"
              />
              <button
                onClick={assignTeam}
                className="px-4 py-2 bg-primary text-white rounded-lg text-sm font-medium hover:bg-primary-dark"
              >
                Assign
              </button>
            </div>
            {report.assigned_to && (
              <div className="text-sm text-slate-500 mt-2">Currently assigned to: <strong>{report.assigned_to}</strong></div>
            )}
          </div>

          <div className="flex gap-2 mb-6">
            <button
              onClick={() => updateStatus("in_progress")}
              className="px-4 py-2 bg-blue-100 text-blue-700 rounded-lg text-sm font-medium hover:bg-blue-200"
            >
              Mark In Progress
            </button>
            <button
              onClick={() => updateStatus("resolved")}
              className="px-4 py-2 bg-green-100 text-green-700 rounded-lg text-sm font-medium hover:bg-green-200"
            >
              Mark Resolved
            </button>
          </div>

          {report.latitude && report.longitude && (
            <div className="rounded-xl overflow-hidden border border-slate-200 dark:border-slate-700">
              <MapContainer
                center={[report.latitude, report.longitude]}
                zoom={15}
                style={{ height: "300px", width: "100%" }}
              >
                <TileLayer
                  attribution='&copy; OpenStreetMap'
                  url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                />
                <Marker position={[report.latitude, report.longitude]}>
                  <Popup>{report.title}</Popup>
                </Marker>
              </MapContainer>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function Detail({ icon: Icon, label, value }) {
  return (
    <div className="flex items-start gap-3">
      <Icon className="w-5 h-5 text-slate-400 mt-0.5" />
      <div>
        <div className="text-xs text-slate-500 uppercase tracking-wide">{label}</div>
        <div className="font-medium dark:text-white capitalize">{value || "—"}</div>
      </div>
    </div>
  );
}
