import React from "react";

export default function DailyArchiveModal({ date, onClose }) {
    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <button className="modal-close" onClick={onClose}>×</button>
                <h2>{date}</h2>
                <p>（ここに詳細を表示予定）</p>
            </div>
        </div>
    );
}
