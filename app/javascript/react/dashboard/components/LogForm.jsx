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
      width: 480,
      background: "#ffffff",
      borderRadius: 16,
      border: "1px solid #e5e7eb",
      padding: "20px",
      boxShadow: "0 4px 24px rgba(0,0,0,0.08)",
    }}>
      {/* ヘッダー */}
      <div style={{ marginBottom: 16 }}>
        <p style={{
          color: "#9ca3af",
          fontSize: 10,
          letterSpacing: "0.15em",
          textTransform: "uppercase",
          margin: "0 0 4px",
        }}>NOW DOING</p>
        <h2 style={{
          color: "#111827",
          fontSize: 16,
          fontWeight: 700,
          margin: 0,
          minHeight: 24,
        }}>
          {selected ? `${selected.icon} ${selected.name}` : "行動を選んでください"}
        </h2>
      </div>

      <form onSubmit={handleSubmit}>
        {/* カードグリッド */}
        <div style={{
          display: "grid",
          gridTemplateColumns: "1fr 1fr 1fr",
          gap: 8,
          marginBottom: 14,
        }}>
          {activities.map((a) => {
            const isSelected = selectedId === a.id;
            return (
              <button
                key={a.id}
                type="button"
                onClick={() => setSelectedId(isSelected ? null : a.id)}
                onMouseEnter={() => setHoveredId(a.id)}
                onMouseLeave={() => setHoveredId(null)}
                style={{
                  background: isSelected ? "#f3e8ff"  : hoveredId === a.id ? "#ede9fe" : "#f9fafb",
                  border: isSelected ? "2px solid #a855f7" : hoveredId === a.id ? "2px solid #c4b5fd" : "2px solid #e5e7eb",
                  borderRadius: 12,
                  padding: "12px 8px",
                  cursor: "pointer",
                  transition: "all 0.15s ease",
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "center",
                  gap: 4,
                  transform: isSelected ? "scale(1.03)" : hoveredId === a.id ? "scale(1.02)" : "scale(1)",
                }}
              >
                <span style={{ fontSize: 22 }}>{a.icon || "⚡"}</span>
                <span style={{
                  color: isSelected ? "#7c3aed" : "#374151",
                  fontSize: 11,
                  fontWeight: isSelected ? 700 : 500,
                }}>{a.name}</span>
              </button>
            );
          })}
        </div>

        {/* メモ欄 */}
        <textarea
          rows={2}
          placeholder="メモ（任意）"
          value={memo}
          onChange={(e) => setMemo(e.target.value)}
          style={{
            width: "100%",
            background: "#f9fafb",
            border: "1.5px solid #e5e7eb",
            borderRadius: 10,
            padding: "8px 10px",
            color: "#111827",
            fontSize: 12,
            resize: "none",
            outline: "none",
            boxSizing: "border-box",
            marginBottom: 12,
            fontFamily: "inherit",
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
            padding: "11px",
            borderRadius: 10,
            border: "none",
            background: selectedId
              ? "linear-gradient(135deg, #a855f7, #7c3aed)"
              : "#e5e7eb",
            color: selectedId ? "#fff" : "#9ca3af",
            fontSize: 13,
            fontWeight: 700,
            cursor: selectedId ? "pointer" : "not-allowed",
            transition: "all 0.15s ease",
            transform: btnHover && selectedId ? "translateY(-2px)" : "none",
            boxShadow: btnHover && selectedId ? "0 6px 20px rgba(124,58,237,0.4)" : "none",
          }}
        >
          {isSubmitting ? "記録中..." : "記録する"}
        </button>
      </form>
    </div>
  );
}