import React from "react";
import DonutChart from "./charts/DonutChart";

const COLORS = ["#818cf8", "#fb923c", "#34d399", "#f43f5e", "#900ce9"];

const MESSAGES = ["ナイスペース！", "いい調子だよ！", "継続は力なり！", "今日もお疲れ様！"];

function getMessage(logs) {
  if (!logs || logs.length === 0) return "さあ、はじめよう！";
  if (logs.length >= 5) return "すごいペース！";
  return MESSAGES[logs.length % MESSAGES.length];
}

function buildLiveSummary(summary, currentLog, now) {
  if (!currentLog || !summary.length) return summary;
  const elapsedMinutes = Math.min(
    Math.floor((now - new Date(currentLog.logged_at)) / 1000 / 60),
    360
  );
  return summary.map((s) => {
    if (s.activity_id === currentLog.activity.id) {
      return { ...s, total_minutes: s.total_minutes + elapsedMinutes };
    }
    return s;
  });
}

export default function SummaryStatus({ dashboard, now }) {
  const summary = dashboard?.summary_per_category ?? [];
  const logs = dashboard?.logs ?? [];
  const currentLog = dashboard?.current_log ?? null;
  const currentNow = now ?? new Date();

  const liveSummary = buildLiveSummary(summary, currentLog, currentNow);
  const total = liveSummary.reduce((acc, x) => acc + x.total_minutes, 0);
  const liveSummaryFiltered = liveSummary.filter((s) => s.total_minutes > 0);

  // 中心に表示する合計時間
  const totalH = Math.floor(total / 60);
  const totalM = total % 60;
  const totalStr = totalH > 0 ? `${totalH}h${totalM}m` : `${totalM}m`;

  return (
    <div style={{
      width: "100%",
      height: "100%",
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

      {liveSummary.length === 0 ? (
        <p style={{ color: "#9ca3af", fontSize: 13 }}>まだ記録がありません</p>
      ) : (
        <>
          {/* 円グラフ＋レジェンド横並び */}
          <div className="summary-chart-row" style={{ display: "flex", alignItems: "center", gap: 24, marginBottom: 16 }}>

            {/* 円グラフ（中心に合計時間） */}
            <div className="summary-donut" style={{ position: "relative", flexShrink: 0 }}>
              <DonutChart
                labels={liveSummaryFiltered.map((s) => s.activity_name)}
                values={liveSummaryFiltered.map((s) => s.total_minutes)}
                colors={liveSummaryFiltered.map((_, i) => COLORS[i % COLORS.length])}
                size={160}
              />
              <div style={{
                position: "absolute", top: "50%", left: "50%",
                transform: "translate(-50%, -50%)",
                textAlign: "center", pointerEvents: "none",
              }}>
                <div style={{ fontSize: 18, fontWeight: 800, color: "#1e293b", lineHeight: 1.2 }}>{totalStr}</div>
                <div style={{ fontSize: 10, color: "#94a3b8", fontWeight: 600 }}>今日の合計</div>
              </div>
            </div>

            {/* レジェンド */}
            <div className="summary-legend" style={{ flex: 1, display: "flex", flexDirection: "column", gap: 8 }}>
              {liveSummary.map((s, i) => {
                const h = Math.floor(s.total_minutes / 60);
                const m = s.total_minutes % 60;
                const timeStr = h > 0 ? `${h}時間${m}分` : `${m}分`;
                const pct = total > 0 ? Math.round((s.total_minutes / total) * 100) : 0;
                return (
                  <div key={s.activity_id} style={{ display: "flex", alignItems: "center", gap: 8, padding: "8px 10px", borderRadius: 10, transition: "background 0.15s" }}
                    onMouseEnter={(e) => e.currentTarget.style.background = "rgba(238,242,255,0.6)"}
                    onMouseLeave={(e) => e.currentTarget.style.background = "transparent"}
                  >
                    <div style={{ width: 10, height: 10, borderRadius: "50%", background: COLORS[i % COLORS.length], flexShrink: 0, boxShadow: "0 2px 4px rgba(0,0,0,0.15)" }} />
                    <span style={{ fontSize: 12, color: "#334155", flex: 1, fontWeight: 700 }}>{s.activity_name}</span>
                    <span style={{ fontSize: 11, color: "#64748b", fontFamily: "monospace" }}>{timeStr}</span>
                    <span style={{ fontSize: 11, color: "#6366f1", background: "#eef2ff", padding: "2px 6px", borderRadius: 20, fontWeight: 700 }}>{pct}%</span>
                    <span style={{ fontSize: 10, color: "#94a3b8", background: "#f1f5f9", padding: "2px 5px", borderRadius: 20 }}>{s.count}回</span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* ハムスターコメント */}
          <div style={{
            textAlign: "center", fontSize: 13, color: "#4f46e5", fontWeight: 800,
            padding: "10px 14px",
            background: "linear-gradient(135deg, rgba(238,242,255,0.9), rgba(224,231,255,0.9))",
            borderRadius: 12, border: "1px solid rgba(199,210,254,0.5)",
          }}>
            🐹「{getMessage(logs)}」
          </div>
        </>
      )}
    </div>
  );
}