import React from "react";

export default function TodayHistory({ logs, activities }) {
  const sorted = [...logs].sort((a, b) => new Date(a.logged_at) - new Date(b.logged_at));

  return (
    <div style={{
      width: "100%",
      background: "rgba(255,255,255,0.75)",
      backdropFilter: "blur(16px)",
      borderRadius: 20,
      border: "1px solid rgba(255,255,255,0.9)",
      padding: "22px 24px",
      boxShadow: "0 4px 24px rgba(0,0,0,0.06), 0 1px 4px rgba(0,0,0,0.04)",
      maxHeight: 400,
      overflowY: "auto",
    }}>
      <div style={{
        fontSize: 15, fontWeight: 800, color: "#1e293b",
        marginBottom: 18, display: "flex", alignItems: "center", gap: 8,
        paddingBottom: 12, borderBottom: "2px solid #f1f5f9",
      }}>
        <div style={{ width: 28, height: 28, borderRadius: 8, background: "linear-gradient(135deg, #dcfce7, #bbf7d0)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14 }}>📋</div>
        今日の履歴
      </div>

      {sorted.length === 0 ? (
        <p style={{ color: "#9ca3af", fontSize: 13 }}>今日の記録はまだありません</p>
      ) : (
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {sorted.map((log) => {
            const time = new Date(log.logged_at).toLocaleTimeString("ja-JP", { hour: "2-digit", minute: "2-digit" });
            const activity = activities.find((a) => a.id === log.activity.id);
            return (
              <div key={log.id} style={{
                display: "flex", alignItems: "center", gap: 12,
                padding: "12px 16px",
                background: "rgba(248,250,252,0.8)",
                borderRadius: 14,
                border: "1px solid rgba(226,232,240,0.6)",
                transition: "all 0.18s ease",
                cursor: "default",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.background = "rgba(238,242,255,0.8)";
                e.currentTarget.style.borderColor = "rgba(199,210,254,0.6)";
                e.currentTarget.style.transform = "translateX(4px)";
                e.currentTarget.style.boxShadow = "0 4px 12px rgba(99,102,241,0.1)";
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.background = "rgba(248,250,252,0.8)";
                e.currentTarget.style.borderColor = "rgba(226,232,240,0.6)";
                e.currentTarget.style.transform = "none";
                e.currentTarget.style.boxShadow = "none";
              }}>
                <span style={{ fontSize: 11, color: "#94a3b8", fontFamily: "monospace", minWidth: 38 }}>{time}</span>
                <span style={{ fontSize: 18 }}>{activity?.icon}</span>
                <span style={{ fontSize: 13, fontWeight: 700, color: "#334155", flex: 1 }}>{log.activity.name}</span>
                {log.memo && (
                  <span style={{ fontSize: 11, color: "#94a3b8", background: "#f8fafc", padding: "2px 8px", borderRadius: 20, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", maxWidth: 240 }}>
                    {log.memo}
                  </span>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}