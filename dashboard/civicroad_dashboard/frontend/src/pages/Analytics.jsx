import { useEffect, useState } from "react";
import { api } from "../api.js";
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend, LineChart, Line,
} from "recharts";

const COLORS = ["#2563EB", "#F59E0B", "#10B981", "#8B5CF6", "#EF4444"];

export default function Analytics() {
  const [stats, setStats] = useState(null);

  useEffect(() => {
    api.get("/reports/stats").then((r) => setStats(r.data));
  }, []);

  if (!stats) return <div className="text-slate-500">Loading…</div>;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold dark:text-white">Analytics</h1>
        <p className="text-sm text-slate-500">Visualize trends and category breakdowns.</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card p-5">
          <h2 className="font-semibold mb-4 dark:text-white">Reports by Category</h2>
          <ResponsiveContainer width="100%" height={260}>
            <BarChart data={stats.byCategory}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
              <XAxis dataKey="category" />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Bar dataKey="count" fill="#2563EB" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="card p-5">
          <h2 className="font-semibold mb-4 dark:text-white">Category Distribution</h2>
          <ResponsiveContainer width="100%" height={260}>
            <PieChart>
              <Pie
                data={stats.byCategory}
                dataKey="count"
                nameKey="category"
                outerRadius={90}
                label
              >
                {stats.byCategory.map((_, i) => (
                  <Cell key={i} fill={COLORS[i % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>

        <div className="card p-5 lg:col-span-2">
          <h2 className="font-semibold mb-4 dark:text-white">Reports — Last 7 Days</h2>
          <ResponsiveContainer width="100%" height={260}>
            <LineChart data={stats.last7Days}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
              <XAxis dataKey="day" />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Line type="monotone" dataKey="count" stroke="#2563EB" strokeWidth={3} dot={{ r: 5 }} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}
