import React from "react";

export default function CurrentStatus({ dashboard, activities }) {
    const currentLog = dashboard?.current_log ?? null;

    console.log("CurrentStatus", { currentLog, activities });


    const now = dashboard?.now ? new Date(dashboard.now) : new Date();

    // 現在の行動名
    const activity = activities.find((a) => a.id === currentLog?.activity?.id);
    const activityName = activity ? `${activity.icon} ${activity.name}` : "未選択";

    // 推定経過時間（分）、最大360分
    const elapsedMinutes = currentLog
    ? Math.min(
        Math.floor((now - new Date(currentLog.logged_at)) /1000 /60),
        360
    )
    : 0;

    return (
        <div style={{
            width: 320,
            background: "#ffffff",
            borderRadius: 16,
            border: "1px solid #e5e7eb",
            padding: "20px",
            bosShadow: "0 4px 24px rgba(0, 0, 0, 0.08)",
        }}>
          <p style={{
            color: "#9ca3af",
            fontSize: 10,
            letterSpacing: "0.5em",
            textTransform: "uppercase",
            margin: "0 0 12px",
          }}>TODAY'S ESTIMATE</p>

          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            <div style={{ display: "flex", aliginItems: "center", gap: 8}}>
                <span style={{ color: "#6b7280", fontSize: 13 }}>現在</span>
                <span style={{ fontSize: 14, fontWeight: 700, color: "#111827" }}>
                    {activityName}中
                </span>
            </div>
            <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ color: "#6b7280", fontSize: 13 }}>推定経過時間</span>
                <span style={{ fontSize: 14, fontWeight: 700, color: "#7c3aed" }}>
                    {elapsedMinutes}分
                </span>
            </div>
          </div>
        </div>
    );
}