import React, { useState } from "react";
import Picker from "@emoji-mart/react";
import data from "@emoji-mart/data";

const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.content;

export default function CategoryFormModal({ onClose, onAdd }) {
    const [name, setName] = useState("");
    const [icon, setIcon] = useState("");
    const [showPicker, setShowPicker] = useState(false);
    const [error, setError] = useState(null);

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!name.trim()) {
            setError("カテゴリ名を入力してください");
            return;
        }
        fetch("/api/activities", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": csrfToken(),
            },
            body: JSON.stringify({ activity: { name, icon } }),
        })
            .then((res) => res.json().then((json) => ({ ok: res.ok, json })))
            .then(({ ok, json }) => {
                if (!ok) {
                    setError(json.errors?.join(", ") || "登録失敗");
                    return;
                }
                onAdd(json);
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
                        <button
                            type="button"
                            className="icon-preview-btn"
                            onClick={() => setShowPicker(!showPicker)}
                        >
                            {icon || "＋ 選択"}
                        </button>
                        {showPicker && (
                            <Picker
                                data={data}
                                locale="ja"
                                onEmojiSelect={(e) => {
                                    setIcon(e.native);
                                    setShowPicker(false);
                                }}
                            />
                            )}
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