import React from "react";
import DonutChart from "./charts/DonutChart";

const COLORS = ["#818cf8", "#fb923c", "#34d399", "#f59e0b", "#f87171"];

const MESSAGES = ["ナイスペース！", "いい調子だよ！", "継続は力なり！", "今日もお疲れ様！"];

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
      width: "100%",
      background: "rgba(255,255,255,0.75)",
      backdropFilter: "blur(16px)",
      borderRadius: 20,
      border: "1px solid rgba(255,255,255,0.9)",
      padding: "22px 24px",
      boxShadow: "0 4px 24px rgba(0,0,0,0.06), 0 1px 4px rgba(0,0,0,0.04)",
    }}>
      {/* タイトル */}
      <div style={{
        fontSize: 15, fontWeight: 800, color: "#1e293b",
        marginBottom: 18, display: "flex", alignItems: "center", gap: 8,
        paddingBottom: 12, borderBottom: "2px solid #f1f5f9",
      }}>
        <div style={{ width: 28, height: 28, borderRadius: 8, background: "linear-gradient(135deg, #fef3c7, #fde68a)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14 }}>📊</div>
        今日の記録まとめ
      </div>

      {summary.length === 0 ? (
        <p style={{ color: "#9ca3af", fontSize: 13 }}>まだ記録がありません</p>
      ) : (
        <>
          <div style={{ display: "flex", flexDirection: "column", gap: 6, marginBottom: 16 }}>
            {summary.map((s, i) => {
              const hours = Math.floor(s.total_minutes / 60);
              const minutes = s.total_minutes % 60;
              const timeStr = hours > 0 ? `${hours}時間${minutes}分` : `${minutes}分`;
              return (
                <div key={s.activity_id} style={{ display: "flex", alignItems: "center", gap: 10, padding: "10px 12px", borderRadius: 12, background: "rgba(248,250,252,0.8)", transition: "all 0.15s" }}>
                  <div style={{ width: 10, height: 10, borderRadius: "50%", background: COLORS[i % COLORS.length], flexShrink: 0, boxShadow: "0 2px 4px rgba(0,0,0,0.15)" }} />
                  <span style={{ fontSize: 13, color: "#334155", flex: 1, fontWeight: 700 }}>{s.activity_name}</span>
                  <span style={{ fontSize: 12, color: "#64748b", fontFamily: "monospace" }}>{timeStr}</span>
                  <span style={{ fontSize: 11, color: "#94a3b8", background: "#f1f5f9", padding: "2px 6px", borderRadius: 20 }}>{s.count}回</span>
                </div>
              );
            })}
          </div>

          <div style={{ display: "flex", justifyContent: "center", marginBottom: 16 }}>
            <DonutChart
              labels={summary.map((s) => s.activity_name)}
              values={summary.map((s) => s.total_minutes === 0 ? 1 : s.total_minutes)}
              colors={summary.map((_, i) => COLORS[i % COLORS.length])}
            />
          </div>

          <div style={{
            textAlign: "center", fontSize: 13, color: "#4f46e5", fontWeight: 800,
            padding: "10px 14px", background: "linear-gradient(135deg, rgba(238,242,255,0.9), rgba(224,231,255,0.9))",
            borderRadius: 12, border: "1px solid rgba(199,210,254,0.5)",
          }}>
            🐹「{getMessage(logs)}」
          </div>
        </>
      )}
    </div>
  );
}