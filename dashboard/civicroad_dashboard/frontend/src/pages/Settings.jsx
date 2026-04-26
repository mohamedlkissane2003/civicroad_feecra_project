import { useAuth } from "../auth.jsx";

export default function Settings() {
  const { user } = useAuth();

  return (
    <div className="space-y-6 max-w-2xl">
      <div>
        <h1 className="text-2xl font-bold dark:text-white">Settings</h1>
        <p className="text-sm text-slate-500">Account, notifications, and appearance.</p>
      </div>

      <div className="card p-5 space-y-4">
        <h2 className="font-semibold dark:text-white">Profile</h2>
        <div>
          <label className="block text-sm font-medium mb-1">Name</label>
          <input defaultValue={user?.name} className="w-full px-3 py-2 rounded-lg border border-slate-200 dark:bg-slate-800 dark:border-slate-700 dark:text-white" />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Email</label>
          <input defaultValue={user?.email} disabled className="w-full px-3 py-2 rounded-lg border border-slate-200 bg-slate-50 dark:bg-slate-800 dark:border-slate-700 dark:text-white" />
        </div>
      </div>

      <div className="card p-5 space-y-3">
        <h2 className="font-semibold dark:text-white">Notifications</h2>
        <ToggleRow label="Email me when a new report is submitted" defaultChecked />
        <ToggleRow label="Daily summary report" />
        <ToggleRow label="Push notifications" defaultChecked />
      </div>

      <div className="card p-5 space-y-3">
        <h2 className="font-semibold dark:text-white">Appearance</h2>
        <p className="text-sm text-slate-500">Toggle dark mode using the moon/sun icon in the top bar.</p>
      </div>
    </div>
  );
}

function ToggleRow({ label, defaultChecked }) {
  return (
    <label className="flex items-center justify-between py-2">
      <span className="text-sm dark:text-white">{label}</span>
      <input type="checkbox" defaultChecked={defaultChecked} className="w-10 h-5 accent-primary" />
    </label>
  );
}
