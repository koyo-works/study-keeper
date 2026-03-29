import React, { useState } from "react";

const COLORS = ["#818cf8", "#fb923c", "#34d399", "#f43f5e", "#900ce9"];

export default function CategoryFormModal({ onClose, onAdd }) {
    const [name, setName] = useState("");
    const [icon, setIcon] = useState("");
    const [error, setError] = useState(null);

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!name.trim()) {
            setError("カテゴリ名を入力してください");
            return;
        }
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
        fetch("/api/activities", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": csrfToken,
            },
            body: JSON.stringify({ activity: { name, icon } }),
        })
            .then((res) => res.json().then((data) => ({ ok: res.ok, data})))
            .then(({ ok, data }) => {
                if (!ok) {
                    setError(data.errors?.join(", ") || "登録失敗");
                    return;
                }
                onAdd(data);
                onClose();
            })
            .catch(() => setError("通信エラーが発生しました"));
    };

    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <button className="modal-close" onClick={onClose}>×</button>
                <h2 className="modal-title">カテゴリを追加</h2>
                {error && <p className="modal-error">{error}</p>}
                <form onSubmit={handleSubmit}>
                    <div className="modal-field">
                        <label>アイコン(絵文字)</label>
                        <input
                            type="text"
                            value={icon}
                            onChange={(e) => setIcon(e.target.value)}
                            placeholder="例：📚"
                            maxLength={2}
                        />
                    </div>
                    <div className="modal-field">
                        <label>カテゴリ名</label>
                        <input
                            type="text"
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                            placeholder="例：勉強"
                        />
                    </div>
                    <button type="submit" className="modal-submit-btn">追加する</button>
                </form>
            </div>
        </div>
    );
}