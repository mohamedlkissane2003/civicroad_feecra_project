import { useEffect, useState } from "react";
import { ClipboardList, Clock, Loader2, CheckCircle2 } from "lucide-react";
import { Link } from "react-router-dom";
import { api } from "../api.js";
import StatCard from "../components/StatCard.jsx";
import StatusBadge from "../components/StatusBadge.jsx";

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [recent, setRecent] = useState([]);

  useEffect(() => {
    const load = () => {
      api.get("/reports/stats").then((r) => setStats(r.data));
      api.get("/reports").then((r) => setRecent(r.data.slice(0, 5)));
    };

    load();

    const onReportsChanged = () => load();
    window.addEventListener("civicroad:reports-changed", onReportsChanged);
    return () => window.removeEventListener("civicroad:reports-changed", onReportsChanged);
  }, []);

  const totals = stats?.totals || {};
  const resolutionRate = totals.total
    ? Math.round((totals.resolved / totals.total) * 100)
    : 0;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold dark:text-white">Dashboard Overview</h1>
        <p className="text-sm text-slate-500">Live snapshot of all citizen reports.</p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard icon={ClipboardList} label="Total Reports" value={totals.total ?? 0} color="indigo" />
        <StatCard icon={Clock} label="Pending" value={totals.pending ?? 0} color="amber" />
        <StatCard icon={Loader2} label="In Progress" value={totals.inProgress ?? 0} color="blue" />
        <StatCard icon={CheckCircle2} label="Resolved" value={totals.resolved ?? 0} color="green" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="card p-5 lg:col-span-2">
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-semibold dark:text-white">Recent Reports</h2>
            <Link to="/reports" className="text-sm text-primary font-medium">View all →</Link>
          </div>
          <div className="divide-y divide-slate-100 dark:divide-slate-800">
            {recent.map((r) => (
              <Link key={r.id} to={`/reports/${r.id}`} className="flex items-center gap-3 py-3">
                <img
                  src={r.image_url}
                  alt=""
                  className="w-12 h-12 rounded-lg object-cover bg-slate-100"
                />
                <div className="flex-1 min-w-0">
                  <div className="font-medium text-sm dark:text-white truncate">{r.title}</div>
                  <div className="text-xs text-slate-500 truncate">{r.location_text}</div>
                </div>
                <StatusBadge status={r.status} />
              </Link>
            ))}
          </div>
        </div>

        <div className="card p-5">
          <h2 className="font-semibold mb-4 dark:text-white">Resolution Rate</h2>
          <div className="flex flex-col items-center justify-center py-4">
            <div className="relative w-32 h-32">
              <svg className="w-32 h-32 -rotate-90">
                <circle cx="64" cy="64" r="54" stroke="#E2E8F0" strokeWidth="12" fill="none" />
                <circle
                  cx="64"
                  cy="64"
                  r="54"
                  stroke="#2563EB"
                  strokeWidth="12"
                  fill="none"
                  strokeDasharray={`${(resolutionRate / 100) * 339.3} 339.3`}
                  strokeLinecap="round"
                />
              </svg>
              <div className="absolute inset-0 flex items-center justify-center text-2xl font-bold dark:text-white">
                {resolutionRate}%
              </div>
            </div>
            <p className="text-sm text-slate-500 mt-3">of all reports resolved</p>
          </div>
        </div>
      </div>
    </div>
  );
}
