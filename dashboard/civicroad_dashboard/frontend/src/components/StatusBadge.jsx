const styles = {
  pending: "bg-amber-100 text-amber-700",
  in_progress: "bg-blue-100 text-blue-700",
  resolved: "bg-green-100 text-green-700",
};

const labels = {
  pending: "Pending",
  in_progress: "In Progress",
  resolved: "Resolved",
};

export default function StatusBadge({ status }) {
  return (
    <span className={`px-2.5 py-1 rounded-full text-xs font-semibold ${styles[status] || ""}`}>
      {labels[status] || status}
    </span>
  );
}
