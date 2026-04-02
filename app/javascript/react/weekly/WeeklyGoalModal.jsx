import React, { useState } from "react";

export default function WeeklyGoalModal({ weekStart, categories, currentGoal, onClose, onSave }) {
    const [activityId, setActivityId] = useState(currentGoal?.activity_id || "");
    const [percentage, setPercentage] = useState(currentGoal?.percentage || 50);
    const [error, setError] = useState(null);

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!activityId) {
            setError("カテゴリを選択してください");
            return;
        }
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
        fetch("/api/weekly_goals/upsert", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": csrfToken,
            },
            body: JSON.stringify({ week_start: weekStart, activity_id: activityId, percentage }),
        })
            .then((res) => res.json().then((json) => ({ ok: res.ok, json })))
            .then(({ ok, json }) => {
                if (!ok) {
                    setError(json.errors?.join(", ") || "保存失敗");
                    return;
                }
                onSave(json);
                onClose();
            })
            .catch(() => setError("通信エラーが発生しました"));
    };

    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <button className="modal-close" onClick={onClose}>×</button>
                <h2 className="modal-title">今週の目標を設定</h2>
                {error && <p className="modal-error">{error}</p>}
                <form onSubmit={handleSubmit}>
                    <div className="modal-field">
                        <label>目標カテゴリ</label>
                        <select value={activityId} onChange={(e) => setActivityId(e.target.value)}>
                            <option value="">選択してください</option>
                            {categories.map((cat) => (
                                <option key={cat.id} value={cat.id}>
                                    {cat.icon} {cat.name}
                                </option>
                            ))}
                        </select>
                    </div>
                    <div className="modal-field">
                        <label>目標割合</label>
                        <input
                            type="number"
                            min={0}
                            max={100}
                            value={percentage}
                            onChange={(e) => setPercentage(Number(e.target.value))}
                        /> %
                    </div>
                    <button type="submit" className="modal-submit-btn">設定する</button>
                </form>
            </div>
        </div>
    );
}
