import React from "react";

export default function CurrentStatus({ dashboard, activities, now, onStop }) {
  const currentLog = dashboard?.current_log ?? null;
  const currentNow = now ?? new Date();

  const activity = activities.find((a) => a.id === currentLog?.activity?.id);
  const activityName = activity ? `${activity.icon} ${activity.name}` : "未選択";

  const elapsedSeconds = currentLog
    ? Math.max(0, Math.floor((currentNow - new Date(currentLog.logged_at)) / 1000))
    : 0;

  const cappedSeconds = Math.min(elapsedSeconds, 21600);
  const hours = Math.floor(cappedSeconds / 3600);
  const minutes = Math.floor((cappedSeconds % 3600) / 60);
  const seconds = cappedSeconds % 60;
  const timeStr = currentLog
    ? hours > 0
      ? `${hours}時間${minutes}分${seconds}秒`
      : `${minutes}分${seconds}秒`
    : "0分0秒";

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
            推定経過時間：<span style={{ color: "#4f46e5", fontFamily: "monospace", fontWeight: 700, fontSize: 16 }}>{timeStr}</span>
          </div>
        </div>

        {currentLog && (
          <button
            onClick={onStop}
            style={{
              padding: "11px 22px",
              borderRadius: 14,
              border: "none",
              background: "linear-gradient(135deg, #fb7185, #f43f5e)",
              color: "white",
              fontSize: 13,
              fontWeight: 800,
              cursor: "pointer",
              fontFamily: "inherit",
              transition: "all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1)",
              boxShadow: "0 4px 16px rgba(244,63,94,0.3)",
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.transform = "translateY(-2px)";
              e.currentTarget.style.boxShadow = "0 8px 24px rgba(244,63,94,0.4)";
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = "none";
              e.currentTarget.style.boxShadow = "0 4px 16px rgba(244,63,94,0.3)";
            }}
          >
            計測を止める
          </button>
        )}
      </div>
    </div>
  );
}