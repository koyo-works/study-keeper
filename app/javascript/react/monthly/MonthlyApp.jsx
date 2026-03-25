import React, { useEffect, useState } from "react";
import DailyArchiveModal from "./DailyArchiveModal";

function buildCalendarDays(monthStart, monthEnd) {
    const days = [];
    const start = new Date(monthStart);
    const end = new Date(monthEnd);

    // 1日の曜日に合わせて前の空白を追加（月曜始まり）
    const firstDow = (start.getUTCDay() + 6) % 7; // 0=月, 6=日
    for (let i = 0; i < firstDow; i++) days.push(null);

    // 月の全日付を追加（UTC基準で統一）
    const cur = new Date(start);
    while (cur <= end) {
        days.push(cur.toISOString().slice(0, 10));
        cur.setUTCDate(cur.getUTCDate() + 1);
    }

    return days;
}

export default function MonthlyApp() {
    const [data, setData] = useState(null);
    const [error, setError] = useState(null);
    const [currentMonth, setCurrentMonth] = useState(null);
    const [selectedDate, setSelectedDate] = useState(null);

    useEffect(() => {
        const param = currentMonth ? `?month=${currentMonth}` : "";
        fetch(`/api/monthly${param}`, { headers: { "X-Requested-With": "XMLHttpRequest" } })
            .then((r) => r.json())
            .then((json) => setData(json))
            .catch((e) => setError(e.message));
    }, [currentMonth]);

    if (error) return <p>{error}</p>;
    if (!data) return <p>読み込み中…</p>;

    const days = buildCalendarDays(data.month_start, data.month_end);
    const yearMonth = data.month_start.slice(0, 7); // "2026-03"
    const today = new Date().toISOString().slice(0, 10);

    return (
        <div className="monthly-wrap">
            <div className="monthly-nav">
                <button onClick={() => {
                    const d = new Date(data.month_start);
                    d.setMonth(d.getMonth() - 1);
                    setCurrentMonth(d.toISOString().slice(0, 7));
                }}>＜ 前の月</button>
                <span>{yearMonth}</span>
                <button onClick={() => {
                    const d = new Date(data.month_start);
                    d.setMonth(d.getMonth() + 1);
                    setCurrentMonth(d.toISOString().slice(0, 7));
                }}>次の月 ＞</button>
            </div>

            <div className="monthly-card">
                <div className="monthly-calendar">
                    {["月", "火", "水", "木", "金", "土", "日"].map((d) => (
                        <div key={d} className="monthly-day-header">{d}</div>
                    ))}
                    {days.map((date, i) => {
                        if (!date) return <div key={`empty-${i}`} className="monthly-day empty"></div>;
                        const summary = data.daily_summaries[date];
                        const isToday = date === today;
                        const dow = new Date(date).getUTCDay();
                        const isSat = dow === 6;
                        const isSun = dow === 0;
                        const hasLog = !!summary;
                        const classes = [
                            "monthly-day",
                            isToday ? "today" : "",
                            isSat ? "saturday" : "",
                            isSun ? "sunday" : "",
                            hasLog ? "has-log" : "",
                        ].filter(Boolean).join(" ");
                        return (
                            <div key={date} className={classes} onClick={() => setSelectedDate(date)}>
                                <span className="monthly-day-num">{parseInt(date.slice(8))}</span>
                                {summary ? (
                                    <span className="monthly-day-icon">{summary.dominant_icon}</span>
                                ) : null}
                            </div>
                        );
                    })}
                </div>
            </div>

            {selectedDate && (
                <DailyArchiveModal
                    date={selectedDate}
                    onClose={() => setSelectedDate(null)}
                />
            )}
        </div>
    );
}
