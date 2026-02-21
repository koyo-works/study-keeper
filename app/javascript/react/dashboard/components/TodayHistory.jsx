import React from "react";

export default function TodayHistory({ logs, activities }) {
  const sorted = [...logs].sort((a, b) => new Date(a.logged_at) - new Date(b.logged_at));

  return (
    <div style={{
      width: 320,
      background: "#ffffff",
      borderRadius: 16,
      border: "1px solid #e5e7eb",
      padding: "20px",
      boxShadow: "0 4px 24px rgba(0,0,0,0.08)",
    }}>
      <p style={{
        color: "#9ca3af",
        fontSize: 10,
        letterSpacing: "0.15em",
        textTransform: "uppercase",
        margin: "0 0 12px",
      }}>TODAY'S LOG</p>

      {sorted.length === 0 ? (
        <p style={{ color: "#9ca3af", fontSize: 13 }}>今日の記録はまだありません</p>
      ) : (
        <ul style={{ listStyle: "none", padding: 0, margin: 0, display: "flex", flexDirection: "column", gap: 10 }}>
          {sorted.map((log) => {
            const time = new Date(log.logged_at).toLocaleTimeString("ja-JP", {
              hour: "2-digit",
              minute: "2-digit",
            });
            const activity = activities.find((a) => a.id === log.activity.id);
            return (
              <li key={log.id} style={{
                display: "flex",
                alignItems: "flex-start",
                gap: 10,
                padding: "10px 12px",
                background: "#f9fafb",
                borderRadius: 10,
                border: "1px solid #e5e7eb",
              }}>
                <span style={{ color: "#9ca3af", fontSize: 12, minWidth: 36 }}>{time}</span>
                <div>
                  <span style={{ fontSize: 14 }}>{activity?.icon} </span>
                  <span style={{ fontSize: 13, fontWeight: 600, color: "#111827" }}>{log.activity.name}</span>
                  {log.memo && (
                    <p style={{
                      fontSize: 11,
                      color: "#6b7280",
                      margin: "2px 0 0",
                      overflow: "hidden",
                      textOverflow: "ellipsis",
                      whiteSpace: "nowrap",
                      maxWidth: 200,
                    }}>{log.memo}</p>
                  )}
                </div>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}