import React, { useState } from "react";

export default function LogForm({ activities, onSubmit, isSubmitting }) {
  const [selectedId, setSelectedId] = useState(null);
  const [memo, setMemo] = useState("");
  const [hoveredId, setHoveredId] = useState(null);
  const [btnHover, setBtnHover] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    if (!selectedId) {
      alert("行動カテゴリを1つ選んでから記録してね");
      return;
    }
    await onSubmit({
      activityId: selectedId,
      memo,
      onSuccess: () => setMemo(""),
    });
  }

  const selected = activities.find((a) => a.id === selectedId);

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
        <div style={{ width: 28, height: 28, borderRadius: 8, background: "linear-gradient(135deg, #eef2ff, #e0e7ff)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14 }}>✏️</div>
        今、何をしようとしてる？
      </div>

      <form onSubmit={handleSubmit}>
        {/* カードグリッド */}
        <div style={{
          display: "grid",
          gridTemplateColumns: "repeat(5, 1fr)",
          gap: 10,
          marginBottom: 14,
        }}>
          {activities.map((a) => {
            const isSelected = selectedId === a.id;
            const isHovered = hoveredId === a.id;
            return (
              <button
                key={a.id}
                type="button"
                onClick={() => setSelectedId(isSelected ? null : a.id)}
                onMouseEnter={() => setHoveredId(a.id)}
                onMouseLeave={() => setHoveredId(null)}
                style={{
                  border: isSelected ? "2px solid #818cf8" : isHovered ? "2px solid #c7d2fe" : "2px solid rgba(255,255,255,0.8)",
                  borderRadius: 16,
                  padding: "14px 8px",
                  cursor: "pointer",
                  background: isSelected
                    ? "linear-gradient(135deg, rgba(238,242,255,0.95), rgba(224,231,255,0.95))"
                    : isHovered ? "rgba(238,242,255,0.9)" : "rgba(255,255,255,0.6)",
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "center",
                  gap: 6,
                  transition: "all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1)",
                  transform: isSelected ? "translateY(-4px) scale(1.04)" : isHovered ? "translateY(-4px)" : "none",
                  boxShadow: isSelected
                    ? "0 10px 28px rgba(99,102,241,0.28)"
                    : isHovered ? "0 8px 20px rgba(99,102,241,0.2)" : "0 2px 8px rgba(0,0,0,0.04)",
                }}
              >
                <span style={{ fontSize: 26 }}>{a.icon || "⚡"}</span>
                <span style={{
                  color: isSelected ? "#4f46e5" : "#475569",
                  fontSize: 11,
                  fontWeight: 700,
                }}>{a.name}</span>
              </button>
            );
          })}
        </div>

        {/* メモ欄 */}
        <textarea
          rows={2}
          placeholder="今の気分ややることをメモしておこう"
          value={memo}
          onChange={(e) => setMemo(e.target.value)}
          style={{
            width: "100%",
            background: "rgba(255,255,255,0.7)",
            border: "2px solid rgba(226,232,240,0.8)",
            borderRadius: 12,
            padding: "11px 14px",
            color: "#1e293b",
            fontSize: 13,
            resize: "none",
            outline: "none",
            boxSizing: "border-box",
            marginBottom: 12,
            fontFamily: "inherit",
            transition: "all 0.15s",
          }}
        />

        {/* 記録ボタン */}
        <button
          type="submit"
          disabled={!selectedId || isSubmitting}
          onMouseEnter={() => setBtnHover(true)}
          onMouseLeave={() => setBtnHover(false)}
          style={{
            width: "100%",
            padding: "13px",
            borderRadius: 14,
            border: "none",
            background: selectedId
              ? "linear-gradient(135deg, #818cf8, #6366f1, #4f46e5)"
              : "rgba(241,245,249,0.8)",
            color: selectedId ? "#fff" : "#94a3b8",
            fontSize: 14,
            fontWeight: 800,
            cursor: selectedId ? "pointer" : "not-allowed",
            transition: "all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1)",
            transform: btnHover && selectedId ? "translateY(-2px)" : "none",
            boxShadow: btnHover && selectedId
              ? "0 8px 28px rgba(99,102,241,0.5)"
              : selectedId ? "0 4px 20px rgba(99,102,241,0.4)" : "none",
            letterSpacing: "0.02em",
          }}
        >
          {isSubmitting ? "記録中..." : "記録する"}
        </button>
      </form>
    </div>
  );
}