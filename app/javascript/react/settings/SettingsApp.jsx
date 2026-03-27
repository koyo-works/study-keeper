import React, { useEffect, useState } from "react";

export default function SettingsApp() {
    const [data, setData] = useState(null);
    const [error, setError] = useState(null);

    useEffect(() => {
        fetch("/api/settings")
            .then((res) => {
                if (!res.ok) throw new Error("取得失敗");
                return res.json();
            })
            .then((json) => setData(json))
            .catch((err
            ) => setError(err.message));
    }, []);

    if (error) return <p>{error}</p>;
    if (!data) return <p>読み込み中…</p>;

    return (
        <div>
            <h1>ユーザー設定(仮)</h1>
            <pre>{JSON.stringify(data, null, 2)}</pre>
        </div>
    )
}