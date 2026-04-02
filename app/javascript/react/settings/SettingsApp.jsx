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
        const cat = categories.find((c) => c.id === id);
        const newActive = !cat.active;

        fetch(`/api/activities/${id}`, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content,
            },
            body: JSON.stringify({ active: newActive }),
        })
            .then((res) => {
                if (!res.ok) throw new Error("更新失敗");
                setCategories((prev) =>
                    prev.map((c) => c.id === id ? { ...c, active: newActive } : c)
                );
            })
            .catch(() => alert("更新に失敗しました"));
    };

    const handleAdd = (newCategory) => {
        setCategories((prev) => [...prev, newCategory]);
    };

    const handleDelete = (id) => {
        if(!confirm("削除しますか？")) return;
        fetch(`/api/activities/${id}`, {
            method: "DELETE",
            headers: {
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content,
            },
        })
            .then((res) => {
                if(!res.ok) throw new Error("削除失敗");
                setCategories((prev) => prev.filter((c) => c.id !== id));
            })
            .catch(() => alert("削除に失敗しました"));
    }

    if (error) return <p>{error}</p>;
    if (!data) return <p>読み込み中…</p>;

    return (
        <div className="setting-wrap">
            <h1 className="setting-title">ユーザー設定(仮)</h1>
            <section className="settings-section">
                <h2 className="settings-section-title">行動カテゴリ</h2>
                <CategoryList categories={categories} onToggle={handleToggle} onDelete={handleDelete} />
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
