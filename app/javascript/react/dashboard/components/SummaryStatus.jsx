import React from "react";
import DonutChart from "./charts/DonutChart";

const COLORS = ["#a855f7", "#3b82f6", "#10b981", "#f59e0b", "#ef4444"];

const MESSAGES = [
  "ナイスペース！",
  "いい調子だよ！",
  "継続は力なり！",
  "今日もお疲れ様！",
];

function getMessage(logs) {
  if (!logs || logs.length === 0) return "さあ、はじめよう！";
  if (logs.length >= 5) return "すごいペース！";
  return MESSAGES[logs.length % MESSAGES.length];
}

export default function SummaryStatus({ dashboard }) {
  const summary = dashboard?.summary_per_category ?? [];
  const logs = dashboard?.logs ?? [];

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
      }}>TODAY'S SUMMARY</p>

      {summary.length === 0 ? (
        <p style={{ color: "#9ca3af", fontSize: 13 }}>まだ記録がありません</p>
      ) : (
        <>
          {/* カテゴリ別時間・回数 */}
          <ul style={{ listStyle: "none", padding: 0, margin: "0 0 16px", display: "flex", flexDirection: "column", gap: 6 }}>
            {summary.map((s, i) => {
              const hours = Math.floor(s.total_minutes / 60);
              const minutes = s.total_minutes % 60;
              const timeStr = hours > 0 ? `${hours}時間${minutes}分` : `${minutes}分`;
              return (
                <li key={s.activity_id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", fontSize: 13 }}>
                  <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
                    <span style={{ width: 10, height: 10, borderRadius: "50%", background: COLORS[i % COLORS.length], display: "inline-block" }} />
                    <span style={{ color: "#374151" }}>{s.activity_name}</span>
                  </span>
                  <span style={{ color: "#6b7280" }}>{timeStr}（{s.count}回）</span>
                </li>
              );
            })}
          </ul>

          {/* 円グラフ */}
          <div style={{ display: "flex", justifyContent: "center", marginBottom: 16 }}>
            <DonutChart
              labels={summary.map((s) => s.activity_name)}
              values={summary.map((s) => s.total_minutes)}
              colors={summary.map((_, i) => COLORS[i % COLORS.length])}
            />
          </div>

          {/* コメント */}
          <p style={{
            textAlign: "center",
            fontSize: 13,
            color: "#7c3aed",
            fontWeight: 600,
            margin: 0,
          }}>
            🐹「{getMessage(logs)}」
          </p>
        </>
      )}
    </div>
  );
}