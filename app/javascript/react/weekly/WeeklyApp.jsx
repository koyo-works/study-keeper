import React, { useEffect, useState } from "react";
import { fetchWeekly } from "./api";
import WeeklyChart from "./WeeklyChart";
import WeeklyTable from "./WeeklyTable";
import WeeklyGoalModal from "./WeeklyGoalModal";

const COLORS = ["#818cf8", "#fb923c", "#818cf8", "#f43f5e", "#900ce9"];

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
    const [categories, setCategories] = useState([]);
    const [isGoalModalOpen, setIsGoalModalOpen] = useState(false);

    useEffect(() => {
        fetchWeekly(currentWeekStart)
            .then((json) => setData(json))
            .catch((e) => setError(e.message));
    }, [currentWeekStart]);

    useEffect(() => {
        fetch("/api/activities")
            .then((res) => res.json())
            .then((json) => setCategories(json));
    }, []);

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
                    <div className="weekly-summary-cards">
                        <div className="weekly-summary-card">
                            <span className="weekly-summary-label">今週の合計</span>
                            <span className="weekly-summary-value">{formatMinutes(data.total_minutes)}</span>
                        </div>
                        <div className="weekly-summary-card">
                            <span className="weekly-summary-label">🔥 ストリーク</span>
                            <span className="weekly-summary-value">{data.streak_days}日</span>
                        </div>
                    </div>

                    <button className="weekly-goal-btn" onClick={() => setIsGoalModalOpen(true)}>
                        🎯 今週の目標を設定
                    </button>
                    {data.goal_activity_id && (
                        <p className="weekly-goal-current">
                            現在：{data.goal_activity_icon || ""} {data.goal_activity_name} {data.goal_percentage}%
                        </p>
                    )}

                    {data.goal_activity_id && (() => {
                        const goal = data.summary.find((s) => s.db_id === data.goal_activity_id);
                        const actual = goal ? goal.percentage : 0;
                        const diff = actual - data.goal_percentage;
                        const achieved = diff >= 0;
                        const barWidth = Math.min(actual, 100);
                        return (
                            <div className="weekly-goal">
                                <p className="weekly-goal-title">目標達成状況</p>
                                <p className="weekly-goal-label">
                                    {data.goal_activity_icon || ""} {data.goal_activity_name}　目標：{data.goal_percentage}%
                                </p>
                                <div className="weekly-goal-bar-wrap">
                                    <div
                                        className="weekly-goal-bar"
                                        style={{
                                            width: `${barWidth}%`,
                                            backgroundColor: achieved ? "#818cf8" : "#f43f5e",
                                        }}
                                    ></div>
                                </div>
                                <p className="weekly-goal-result" style={{ color: achieved ? "#818cf8" : "#f43f5e" }}>
                                    {achieved ? "🎉 目標達成！" : "💪 もう少し！"}　実績：{actual}%　{achieved ? `+${diff}%` : `▼${Math.abs(diff)}%`}
                                </p>
                            </div>
                        );
                    })()}

                    <button className="weekly-share-btn" onClick={() => {
                        const text = buildWeeklyShareText(data);
                        const shareUrl = `${window.location.origin}/share/weekly/${data.share_token}`;
                        const url = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(shareUrl)}`;
                        window.open(url, "_blank");
                    }}>𝕏 シェアする</button>
                </div>
            </div>

            <div className="weekly-card">
                <p className="weekly-card-title">カテゴリ別詳細（表形式）</p>
                <WeeklyTable summary={data.summary} formatMinutes={formatMinutes}/>
            </div>
        {isGoalModalOpen && (
            <WeeklyGoalModal
                weekStart={data.week_start}
                categories={categories}
                currentGoal={data.goal_activity_id ? { activity_id: data.goal_activity_id, percentage: data.goal_percentage } : null}
                onClose={() => setIsGoalModalOpen(false)}
                onSave={(saved) => {
                    setData((prev) => ({
                        ...prev,
                        goal_activity_id:   saved.activity_id,
                        goal_activity_name: saved.activity_name,
                        goal_activity_icon: saved.activity_icon,
                        goal_percentage:    saved.percentage,
                    }));
                }}
            />
        )}
        </div>
    )
}