import { useEffect, useState } from "react";
import { Link, NavLink, useNavigate } from "react-router-dom";
import {
  LayoutDashboard,
  ClipboardList,
  Map,
  BarChart3,
  Users,
  Settings,
  Search,
  Bell,
  LogOut,
  Moon,
  Sun,
  Building2,
} from "lucide-react";
import { useAuth } from "../auth.jsx";
import { connectWebSocket } from "../api.js";

const navItems = [
  { to: "/", label: "Dashboard", Icon: LayoutDashboard },
  { to: "/reports", label: "Reports", Icon: ClipboardList },
  { to: "/map", label: "Map", Icon: Map },
  { to: "/analytics", label: "Analytics", Icon: BarChart3 },
  { to: "/users", label: "Users", Icon: Users },
  { to: "/settings", label: "Settings", Icon: Settings },
];

export default function Layout({ children }) {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [dark, setDark] = useState(
    () => localStorage.getItem("theme") === "dark"
  );
  const [notifications, setNotifications] = useState([]);
  const [showNotif, setShowNotif] = useState(false);

  useEffect(() => {
    document.documentElement.classList.toggle("dark", dark);
    localStorage.setItem("theme", dark ? "dark" : "light");
  }, [dark]);

  useEffect(() => {
    const ws = connectWebSocket((msg) => {
      if (msg.event === "report:created") {
        setNotifications((n) => [
          { id: Date.now(), text: `New report: ${msg.payload.title}` },
          ...n.slice(0, 9),
        ]);
        window.dispatchEvent(new CustomEvent("civicroad:reports-changed", { detail: msg.payload }));
      }

      if (msg.event === "report:updated" || msg.event === "report:deleted") {
        window.dispatchEvent(new CustomEvent("civicroad:reports-changed", { detail: msg.payload }));
      }
    });
    return () => ws.close();
  }, []);

  return (
    <div className="flex h-screen overflow-hidden">
      {/* Sidebar */}
      <aside className="w-60 shrink-0 bg-white dark:bg-slate-900 border-r border-slate-200 dark:border-slate-800 flex flex-col">
        <Link to="/" className="flex items-center gap-2 px-5 py-5 border-b border-slate-200 dark:border-slate-800">
          <div className="w-9 h-9 rounded-lg bg-primary flex items-center justify-center">
            <Building2 className="w-5 h-5 text-white" />
          </div>
          <span className="font-bold text-lg dark:text-white">CivicRoad</span>
        </Link>

        <nav className="flex-1 px-3 py-4 space-y-1">
          {navItems.map(({ to, label, Icon }) => (
            <NavLink
              key={to}
              to={to}
              end={to === "/"}
              className={({ isActive }) =>
                `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition ${
                  isActive
                    ? "bg-primary/10 text-primary"
                    : "text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800"
                }`
              }
            >
              <Icon className="w-5 h-5" />
              {label}
            </NavLink>
          ))}
        </nav>

        <div className="px-4 py-4 border-t border-slate-200 dark:border-slate-800">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-primary/10 text-primary flex items-center justify-center font-semibold">
              {user?.name?.[0] ?? "A"}
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-sm font-semibold dark:text-white truncate">{user?.name}</div>
              <div className="text-xs text-slate-500 capitalize">{user?.role}</div>
            </div>
            <button onClick={logout} className="text-slate-400 hover:text-slate-700 dark:hover:text-white">
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        </div>
      </aside>

      {/* Main */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Topbar */}
        <header className="h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex items-center px-6 gap-4">
          <div className="flex-1 max-w-lg relative">
            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              placeholder="Search reports, users, locations…"
              className="w-full pl-9 pr-4 py-2 rounded-lg bg-slate-100 dark:bg-slate-800 dark:text-white text-sm border border-transparent focus:border-primary focus:bg-white dark:focus:bg-slate-900 outline-none"
            />
          </div>

          <button
            onClick={() => setDark((v) => !v)}
            className="p-2 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-300"
          >
            {dark ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
          </button>

          <div className="relative">
            <button
              onClick={() => setShowNotif((v) => !v)}
              className="p-2 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-300 relative"
            >
              <Bell className="w-5 h-5" />
              {notifications.length > 0 && (
                <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
              )}
            </button>
            {showNotif && (
              <div className="absolute right-0 mt-2 w-80 card shadow-lg z-10 max-h-96 overflow-auto">
                <div className="p-3 border-b border-slate-200 dark:border-slate-700 font-semibold">
                  Notifications
                </div>
                {notifications.length === 0 ? (
                  <div className="p-4 text-sm text-slate-500">No new notifications</div>
                ) : (
                  notifications.map((n) => (
                    <div key={n.id} className="p-3 border-b border-slate-100 dark:border-slate-800 text-sm">
                      {n.text}
                    </div>
                  ))
                )}
              </div>
            )}
          </div>

          <div className="flex items-center gap-3 pl-3 border-l border-slate-200 dark:border-slate-700">
            <div className="w-9 h-9 rounded-full bg-primary text-white flex items-center justify-center font-semibold text-sm">
              {user?.name?.[0]}
            </div>
            <div className="hidden md:block">
              <div className="text-sm font-semibold dark:text-white">{user?.name}</div>
              <div className="text-xs text-slate-500">{user?.email}</div>
            </div>
          </div>
        </header>

        <main className="flex-1 overflow-auto p-6 bg-slate-50 dark:bg-slate-950">
          {children}
        </main>
      </div>
    </div>
  );
}
