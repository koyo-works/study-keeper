import React, { useEffect, useState } from "react";
import { fetchWeekly } from "./api";

export default function WeeklyApp() {
    const [data, setData] = useState(null);
    const [error, setError] = useState(null);
    const [currentWeekStart, setCurrentWeekStart] = useState(null);

    useEffect(() => {
        fetchWeekly(currentWeekStart)
            .then((json) => setData(json))
            .catch((e) => setError(e.message));
    }, [currentWeekStart]);

    if (error) return <p>{error}</p>

    if (data == null) return <p>読み込み中…</p>

    return (
        <div>
            <button onClick={() => {
                const d = new Date(data.week_start);
                d.setDate(d.getDate() - 7);
                setCurrentWeekStart(d.toISOString().slice(0, 10));
            }}>＜ 前の週</button>
            <p>{data.week_start} ～ {data.week_end}</p>
            <button onClick={() => {
                const d = new Date(data.week_start);
                d.setDate(d.getDate() + 7);
                setCurrentWeekStart(d.toISOString().slice(0, 10));
            }}>次の週 ＞</button>
            <p>{data.total_minutes}</p>
        </div>
    )
}