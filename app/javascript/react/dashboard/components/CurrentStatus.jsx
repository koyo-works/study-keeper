import React from "react";

export default function CurrentStatus({ dashboard, activities }) {
  const currentLog = dashboard?.current_log ?? null;
  const now = dashboard?.now ? new Date(dashboard.now) : new Date();

  const activity = activities.find((a) => a.id === currentLog?.activity?.id);
  const activityName = activity ? `${activity.icon} ${activity.name}` : "未選択";

  const elapsedMinutes = currentLog
    ? Math.min(Math.floor((now - new Date(currentLog.logged_at)) / 1000 / 60), 360)
    : 0;

  return (
    <div style={{
      width: "100%",
      background: "rgba(255,255,255,0.75)",
      backdropFilter: "blur(16px)",
      borderRadius: 20,
      border: "1px solid rgba(255,255,255,0.9)",
      padding: "22px 24px",
      boxShadow: "0 4px 24px rgba(0,0,0,0.06), 0 1px 4px rgba(0,0,0,0.04)",
    }}>
      <div style={{
        fontSize: 15, fontWeight: 800, color: "#1e293b",
        marginBottom: 18, display: "flex", alignItems: "center", gap: 8,
        paddingBottom: 12, borderBottom: "2px solid #f1f5f9",
      }}>
        <div style={{ width: 28, height: 28, borderRadius: 8, background: "linear-gradient(135deg, #fce7f3, #fbcfe8)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14 }}>⏱️</div>
        今日の推定時間
      </div>

      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
          <div style={{ fontSize: 15, fontWeight: 800, color: "#1e293b" }}>
            現在：{activityName}中
          </div>
          <div style={{ fontSize: 13, color: "#64748b", fontWeight: 600 }}>
            推定経過時間：<span style={{ color: "#4f46e5", fontFamily: "monospace", fontWeight: 700, fontSize: 16 }}>{elapsedMinutes}分</span>
          </div>
        </div>
      </div>
    </div>
  );
}