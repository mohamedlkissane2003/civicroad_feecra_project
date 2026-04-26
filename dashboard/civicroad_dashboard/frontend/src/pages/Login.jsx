import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Building2 } from "lucide-react";
import { useAuth } from "../auth.jsx";

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState("admin@civicroad.gov");
  const [password, setPassword] = useState("admin123");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function onSubmit(e) {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      await login(email, password);
      navigate("/");
    } catch (err) {
      setError(err.response?.data?.error || "Login failed");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-50 px-4">
      <form onSubmit={onSubmit} className="card p-8 w-full max-w-sm">
        <div className="flex flex-col items-center mb-6">
          <div className="w-14 h-14 rounded-xl bg-primary flex items-center justify-center mb-3">
            <Building2 className="w-7 h-7 text-white" />
          </div>
          <h1 className="text-xl font-bold">CivicRoad Admin</h1>
          <p className="text-sm text-slate-500 mt-1">Sign in to manage city reports</p>
        </div>

        {error && (
          <div className="mb-4 p-3 rounded-lg bg-red-50 text-red-600 text-sm">{error}</div>
        )}

        <label className="block text-sm font-medium mb-1">Email</label>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full px-3 py-2 rounded-lg border border-slate-200 mb-4 outline-none focus:border-primary"
          required
        />

        <label className="block text-sm font-medium mb-1">Password</label>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="w-full px-3 py-2 rounded-lg border border-slate-200 mb-5 outline-none focus:border-primary"
          required
        />

        <button
          disabled={loading}
          className="w-full bg-primary text-white py-2.5 rounded-lg font-semibold hover:bg-primary-dark disabled:opacity-50"
        >
          {loading ? "Signing in…" : "Log In"}
        </button>

        <p className="mt-4 text-center text-xs text-slate-500">
          Demo: admin@civicroad.gov / admin123
        </p>
      </form>
    </div>
  );
}
