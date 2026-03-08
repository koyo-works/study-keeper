import React, { useEffect, useState } from "react";
import { fetchWeekly } from "./api";
import WeeklyChart from "./WeeklyChart";
import WeeklyTable from "./WeeklyTable";

function formatMinutes(minutes) {
    const h = Math.floor(minutes / 60);
    const m = minutes % 60;
    return h > 0 ? `${h}時間${m}分` : `${m}分`;
}

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

            {data.summary.length === 0 ? (
                <p>データがありません</p>
            ):(
                <WeeklyChart summary={data.summary} />
            )}
            <ul>
                {data.summary.map((s) => (
                    <li key={s.activity_id}>
                        {s.activity_name}:{formatMinutes(s.total_minutes)}
                    </li>
                ))}
            </ul>
            <p>今週の合計：{formatMinutes(data.total_minutes)}</p>
            <p>🔥 ストリーク：{data.streak_days}日</p>

            <WeeklyTable summary={data.summary} formatMinutes={formatMinutes}/>
        </div>
    )
}