import React from "react";

export default function CategoryFormModal({ onClose }) {
    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <button className="modal-close" onClick={onClose}>×</button>
                <h2 className="modal-title">カテゴリを追加</h2>
                <p>（フォームは次のイシューで実装）</p>
            </div>
        </div>
    );
}