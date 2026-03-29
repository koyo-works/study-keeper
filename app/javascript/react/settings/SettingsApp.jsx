import React, { useEffect, useState } from "react";
import CategoryList from "./CategoryList";
import CategoryFormModal from "./CategoryFormModal";

export default function SettingsApp() {
    const [data, setData] = useState(null);
    const [categories, setCategories] = useState([]);
    const [error, setError] = useState(null);
    const [isCategoryModalOpen, setIsCategoryModalOpen] = useState(false);

    useEffect(() => {
        fetch("/api/settings")
            .then((res) => {
                if (!res.ok) throw new Error("取得失敗");
                return res.json();
            })
            .then((json) => {
                setData(json);
                setCategories(json.categories);
            })
            .catch((err) => setError(err.message));
    }, []);

    const handleToggle = (id) => {
        setCategories((prev) =>
            prev.map((cat) => 
                cat.id === id ? { ...cat, active: !cat.active} : cat
            )
        );
    };

    const handleAdd = (newCategory) => {
        setCategories((prev) => [...prev, newCategory]);
    };

    if (error) return <p>{error}</p>;
    if (!data) return <p>読み込み中…</p>;

    return (
        <div className="setting-wrap">
            <h1 className="setting-title">ユーザー設定(仮)</h1>
            <section className="settings-section">
                <h2 className="settings-section-title">行動カテゴリ</h2>
                <CategoryList categories={categories} onToggle={handleToggle} />
                <button
                    className="category-add-btn"
                    onClick={() => setIsCategoryModalOpen(true)}
                >
                    + カテゴリ追加
                </button>
            </section>
            {isCategoryModalOpen && (
                <CategoryFormModal onClose={() => setIsCategoryModalOpen(false)} onAdd={handleAdd} />
            )}
        </div>
    );
}