import React, { useEffect, useState } from "react";
import { fetchWeekly } from "./api";
import WeeklyChart from "./WeeklyChart";
import WeeklyTable from "./WeeklyTable";

const COLORS = ["#818cf8", "#fb923c", "#34d399", "#f43f5e", "#900ce9"];

function formatMinutes(minutes) {
    const h = Math.floor(minutes / 60);
    const m = minutes % 60;
    return h > 0 ? `${h}時間${m}分` : `${m}分`;
}

function buildWeeklyShareText(data) {
    const total = formatMinutes(data.total_minutes);
    const top = data.summary.slice(0,3)
        .map((s) => `${s.activity_name}：${formatMinutes(s.total_minutes)}（${s.percentage}%）`)
        .join("\n");
    return `今週（${data.week_start} ～ ${data.week_end}）の勉強記録\n合計：${total}\n${top}\nストリーク：${data.streak_days}日\n#StudyKeeper\n`;
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
        <div className="weekly-wrap">
            <div className="weekly-nav mb-3">
                <button onClick={() => {
                    const d = new Date(data.week_start);
                    d.setDate(d.getDate() - 7);
                    setCurrentWeekStart(d.toISOString().slice(0, 10));
                }}>＜ 前の週</button>
                <span>{data.week_start} ～ {data.week_end}</span>
                <button onClick={() => {
                    const d = new Date(data.week_start);
                    d.setDate(d.getDate() + 7);
                    setCurrentWeekStart(d.toISOString().slice(0, 10));
                }}>次の週 ＞</button>
            </div>

            <div className="weekly-card">
                <div className="weekly-chart-area">
                    {data.summary.length === 0 ? (
                        <p>データがありません</p>
                    ):(
                        <WeeklyChart summary={data.summary} />
                    )}
                    <p className="weekly-card-title">今週の勉強時間の割合</p>
                    <ul className="weekly-legend">
                        {data.summary.map((s, i) => (
                            <li key={s.activity_id} className="weekly-legend-item">
                                <span className="weekly-legend-color" style={{ backgroundColor: COLORS[i % COLORS.length] }}></span>
                                {s.activity_name}：{formatMinutes(s.total_minutes)}
                            </li>
                        ))}
                    </ul>
                    <p>● 今週の合計：{formatMinutes(data.total_minutes)}</p>
                    <p>🔥 ストリーク：{data.streak_days}日</p>

                    <button className="weekly-share-btn" onClick={() => {
                        const text = buildWeeklyShareText(data);
                        const shareUrl = `${window.location.origin}/weekly?week=${data.week_start}`;
                        const url = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(shareUrl)}`;
                        window.open(url, "_blank");
                    }}>𝕏 シェアする</button>
                </div>
            </div>

            <div className="weekly-card">
                <p className="weekly-card-title">カテゴリ別詳細（表形式）</p>
                <WeeklyTable summary={data.summary} formatMinutes={formatMinutes}/>
            </div>
        </div>
    )
}