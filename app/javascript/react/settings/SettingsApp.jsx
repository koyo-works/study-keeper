import React, { useEffect, useState } from "react";
import CategoryList from "./CategoryList";
import CategoryFormModal from "./CategoryFormModal";

async function unsubscribePush() {
    if (!("serviceWorker" in navigator)) return false;
    const regs = await navigator.serviceWorker.getRegistrations();
    const subscription = regs.length > 0 ? await regs[0].pushManager.getSubscription() : null;

    if (subscription) {
        const endpoint = subscription.endpoint;
        await subscription.unsubscribe();
        const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;
        await fetch("/api/push_subscriptions", {
            method: "DELETE",
            headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
            body: JSON.stringify({ endpoint }),
        });
    }
    return true;
}

async function subscribePush() {
    if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
        alert("このブラウザはプッシュ通知に対応していません");
        return false;
    }
    const vapidKey = document.querySelector("meta[name='vapid-public-key']")?.content;
    if (!vapidKey) return false;

    const reg = await navigator.serviceWorker.register("/service_worker.js");
    const permission = await Notification.requestPermission();
    if (permission !== "granted") return false;

    const padding = "=".repeat((4 - (vapidKey.length % 4)) % 4);
    const base64 = (vapidKey + padding).replace(/-/g, "+").replace(/_/g, "/");
    const applicationServerKey = Uint8Array.from([...atob(base64)].map((c) => c.charCodeAt(0)));

    const subscription = await reg.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey });
    const json = subscription.toJSON();
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;

    await fetch("/api/push_subscriptions", {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
        body: JSON.stringify({ endpoint: json.endpoint, p256dh: json.keys.p256dh, auth: json.keys.auth }),
    });
    return true;
}

export default function SettingsApp() {
    const [data, setData] = useState(null);
    const [categories, setCategories] = useState([]);
    const [error, setError] = useState(null);
    const [isCategoryModalOpen, setIsCategoryModalOpen] = useState(false);
    const [defaultPage, setDefaultPage] = useState("daily");
    const [notifStatus, setNotifStatus] = useState("default");

    useEffect(() => {
        if (!("serviceWorker" in navigator) || !("PushManager" in window)) return;
        if (typeof Notification === "undefined" || Notification.permission !== "granted") return;
        navigator.serviceWorker.getRegistration("/").then((reg) => {
            if (!reg) return;
            reg.pushManager.getSubscription().then((sub) => {
                if (sub) setNotifStatus("granted");
            });
        });
    }, []);

    useEffect(() => {
        fetch("/api/settings")
            .then((res) => {
                if (!res.ok) throw new Error("取得失敗");
                return res.json();
            })
            .then((json) => {
                setData(json);
                setCategories(json.categories);
                setDefaultPage(json.default_page || "daily");
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

    const handleSave = () => {
        fetch("/api/settings", {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content,
            },
            body: JSON.stringify({ default_page: defaultPage }),
        })
            .then((res) => {
                if (!res.ok) throw new Error("保存失敗");
                alert("保存しました");
            })
            .catch(() => alert("保存に失敗しました"));
    };


    if (error) return <p>{error}</p>;
    if (!data) return <p>読み込み中…</p>;

    return (
        <div className="setting-wrap">
            <h1 className="setting-title">ユーザー設定</h1>
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
            <section className="settings-section">
                <h2 className="settings-section-title">起動時のデフォルト画面</h2>
                {[
                    { value: "daily",   label: "今日の記録" },
                    { value: "weekly",  label: "週次記録" },
                    { value: "monthly", label: "月次記録" },
                ].map(({ value, label }) => (
                    <label key={value} className="default-page-radio">
                        <input
                            type="radio"
                            name="defaultPage"
                            value={value}
                            checked={defaultPage === value}
                            onChange={() => setDefaultPage(value)}
                        />
                        {label}
                    </label>
                ))}
                <button className="default-page-save-btn" onClick={handleSave}>保存する</button>
            </section>
            <section className="settings-section">
                <h2 className="settings-section-title">プッシュ通知</h2>
                {notifStatus === "granted" ? (
                    <>
                        <p className="notif-status-text">通知は有効です</p>
                        <button
                            className="notif-disable-btn"
                            onClick={async () => {
                                try {
                                    const ok = await unsubscribePush();
                                    if (ok) setNotifStatus("default");
                                } catch (e) {
                                    console.error("unsubscribePush error:", e);
                                    alert("無効化に失敗しました: " + e.message);
                                }
                            }}
                        >
                            通知を無効にする
                        </button>
                    </>
                ) : (
                    <button
                        className="notif-enable-btn"
                        onClick={async () => {
                            const ok = await subscribePush();
                            if (ok) setNotifStatus("granted");
                        }}
                    >
                        通知を有効にする
                    </button>
                )}
            </section>
            <section className="settings-section">
                <h2 className="settings-section-title">セキュリティ</h2>
                <a href="/users/edit" className="password-change-btn">パスワードを変更する</a>
            </section>
            {isCategoryModalOpen && (
                <CategoryFormModal onClose={() => setIsCategoryModalOpen(false)} onAdd={handleAdd} />
            )}
        </div>
    );
}
