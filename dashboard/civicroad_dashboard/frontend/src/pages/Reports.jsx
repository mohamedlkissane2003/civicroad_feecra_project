import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Download, Trash2 } from "lucide-react";
import { api } from "../api.js";
import StatusBadge from "../components/StatusBadge.jsx";

const CATEGORIES = ["all", "road", "lighting", "sanitation", "other"];
const STATUSES = ["all", "pending", "in_progress", "resolved"];

export default function Reports() {
  const [reports, setReports] = useState([]);
  const [filters, setFilters] = useState({ category: "all", status: "all", search: "" });

  function load() {
    api.get("/reports", { params: filters }).then((r) => setReports(r.data));
  }

  useEffect(load, [filters]);

  useEffect(() => {
    const refresh = () => load();
    window.addEventListener("civicroad:reports-changed", refresh);
    return () => window.removeEventListener("civicroad:reports-changed", refresh);
  }, [filters]);

  async function updateStatus(id, status) {
    await api.put(`/reports/${id}`, { status });
    load();
  }

  async function deleteReport(id) {
    if (!confirm("Delete this report?")) return;
    await api.delete(`/reports/${id}`);
    load();
  }

  function exportCSV() {
    const header = "id,title,category,status,location,date\n";
    const rows = reports
      .map((r) => `${r.id},"${r.title}",${r.category},${r.status},"${r.location_text}",${r.created_at}`)
      .join("\n");
    const blob = new Blob([header + rows], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "civicroad-reports.csv";
    a.click();
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold dark:text-white">Reports Management</h1>
          <p className="text-sm text-slate-500">Filter, update, and manage all citizen reports.</p>
        </div>
        <button
          onClick={exportCSV}
          className="flex items-center gap-2 px-4 py-2 bg-primary text-white rounded-lg text-sm font-medium hover:bg-primary-dark"
        >
          <Download className="w-4 h-4" /> Export CSV
        </button>
      </div>

      <div className="card p-4 flex flex-wrap gap-3">
        <div className="flex flex-col gap-1 flex-1 min-w-[200px]">
          <span className="text-xs font-semibold uppercase tracking-wide text-slate-500">Search</span>
          <input
            placeholder="Search…"
            value={filters.search}
            onChange={(e) => setFilters({ ...filters, search: e.target.value })}
            className="px-3 py-2 rounded-lg border border-slate-200 text-sm dark:bg-slate-800 dark:border-slate-700 dark:text-white outline-none focus:border-primary"
          />
        </div>
        <div className="flex flex-col gap-1 min-w-[180px]">
          <span className="text-xs font-semibold uppercase tracking-wide text-slate-500">Category filter</span>
          <select
            value={filters.category}
            onChange={(e) => setFilters({ ...filters, category: e.target.value })}
            className="px-3 py-2 rounded-lg border border-slate-200 text-sm dark:bg-slate-800 dark:border-slate-700 dark:text-white"
          >
            {CATEGORIES.map((c) => <option key={c} value={c}>{c === "all" ? "All categories" : c}</option>)}
          </select>
        </div>
        <div className="flex flex-col gap-1 min-w-[180px]">
          <span className="text-xs font-semibold uppercase tracking-wide text-slate-500">Status filter</span>
          <select
            value={filters.status}
            onChange={(e) => setFilters({ ...filters, status: e.target.value })}
            className="px-3 py-2 rounded-lg border border-slate-200 text-sm dark:bg-slate-800 dark:border-slate-700 dark:text-white"
          >
            {STATUSES.map((s) => <option key={s} value={s}>{s === "all" ? "All statuses" : s.replace("_", " ")}</option>)}
          </select>
        </div>
      </div>

      <div className="card overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-slate-50 dark:bg-slate-800 text-left">
            <tr>
              <th className="px-4 py-3 font-semibold">Report</th>
              <th className="px-4 py-3 font-semibold">Category</th>
              <th className="px-4 py-3 font-semibold">Location</th>
              <th className="px-4 py-3 font-semibold">Date</th>
              <th className="px-4 py-3 font-semibold">Status</th>
              <th className="px-4 py-3 font-semibold text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
            {reports.map((r) => (
              <tr key={r.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/50">
                <td className="px-4 py-3">
                  <Link to={`/reports/${r.id}`} className="flex items-center gap-3">
                    <img src={r.image_url} className="w-12 h-12 rounded-lg object-cover bg-slate-100" alt="" />
                    <span className="font-medium dark:text-white">{r.title}</span>
                  </Link>
                </td>
                <td className="px-4 py-3 capitalize">{r.category}</td>
                <td className="px-4 py-3 text-slate-500">{r.location_text}</td>
                <td className="px-4 py-3 text-slate-500">{new Date(r.created_at).toLocaleDateString()}</td>
                <td className="px-4 py-3"><StatusBadge status={r.status} /></td>
                <td className="px-4 py-3">
                  <div className="flex items-center gap-2 justify-end">
                    <select
                      value={r.status}
                      onChange={(e) => updateStatus(r.id, e.target.value)}
                      className="px-2 py-1 text-xs rounded border border-slate-200 dark:bg-slate-800 dark:border-slate-700 dark:text-white"
                    >
                      <option value="pending">Pending</option>
                      <option value="in_progress">In Progress</option>
                      <option value="resolved">Resolved</option>
                    </select>
                    <button
                      onClick={() => deleteReport(r.id)}
                      className="p-1.5 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
            {reports.length === 0 && (
              <tr>
                <td colSpan={6} className="text-center py-8 text-slate-500">No reports found.</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
