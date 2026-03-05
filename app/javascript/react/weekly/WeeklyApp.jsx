import React, { useEffect, useState } from "react";
import { fetchWeekly } from "./api";

export default function WeeklyApp() {
    const [data, setData] = useState(null);
    const [error, setError] = useState(null);

    useEffect(() => {
        fetchWeekly()
            .then((json) => setData(json))
            .catch((e) => setError(e.message));
    }, []);

    if (error) return <p>{error}</p>

    if (data == null) return <p>読み込み中…</p>

    return (
        <div>
            <p>{data.total_minutes}</p>
        </div>
    )
}