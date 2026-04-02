import React from "react";

export default function CategoryList({ categories, onToggle, onDelete }) {
    if (categories.length === 0) {
        return <p>カテゴリがありません</p>
    }

    return (
        <ul className="category-list">
            {categories.map((cat) => (
                <li key={cat.id} className="category-list-item">
                    <span className="category-icon">{cat.icon}</span>
                    <span className="category-name">{cat.name}</span>
                    <button 
                        className="category-delete-btn"
                        onClick={() => onDelete(cat.id)}
                    >
                        削除
                    </button>
                    <button
                        className={`category-toggle ${cat.active ? "on" : "off"}`}
                        onClick={() => onToggle(cat.id)}
                    >
                        {cat.active ? "ON" : "OFF"}
                    </button>
                </li>
            ))}
        </ul>
    );
}