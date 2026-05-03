import React, { useEffect, useState } from "react";
import DonutChart from "../dashboard/components/charts/DonutChart";
import { activityColor } from "../activityColor";

const DAY_NAMES = ["日", "月", "火", "水", "木", "金", "土"];

function formatSeconds(seconds) {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    if (h > 0) return `${h}時間${m}分`;
    if (m > 0) return s > 0 ? `${m}分${s}秒` : `${m}分`;
    return `${s}秒`;
}

function formatDateHeader(dateStr) {
    const d = new Date(dateStr);
    const y = d.getUTCFullYear();
    const m = String(d.getUTCMonth() + 1).padStart(2, "0");
    const day = String(d.getUTCDate()).padStart(2, "0");
    const dow = DAY_NAMES[d.getUTCDay()];
    return `${y}/${m}/${day}（${dow}）`;
}

function formatTime(isoString) {
    const d = new Date(isoString);
    const h = String(d.getHours()).padStart(2, "0");
    const m = String(d.getMinutes()).padStart(2, "0");
    return `${h}:${m}`;
}

function buildDailyShareText(date, data) {
    if(!data || data.total_seconds === 0) return `${date}の記録はありませんでした\n#StudyKeeper\n`;
    const total = formatSeconds(data.total_seconds);
    const top = data.per_category
        .filter((c) => c.seconds > 0)
        .slice(0, 3)
        .map((c) => `${c.icon} ${c.name} : ${formatSeconds(c.seconds)}`)
        .join("\n");
    return `⭐ ${formatDateHeader(date)}の活動記録\n⏱ 合計：${total}\n${top}\n#StudyKeeper\n`;
}

export default function DailyArchiveModal({ date, onClose }) {
    const [data, setData] = useState(null);
    const [error, setError] = useState(null);

    useEffect(() => {
        fetch(`/api/days/${date}`, { headers: { "X-Requested-With": "XMLHttpRequest" } })
            .then((r) => r.json())
            .then((json) => setData(json))
            .catch((e) => setError(e.message));
    }, [date]);

    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal-content daily-modal" onClick={(e) => e.stopPropagation()}>
                <button className="modal-close" onClick={onClose}>×</button>
                <h2 className="daily-modal-title">{formatDateHeader(date)}</h2>

                {error && <p>エラーが発生しました</p>}
                {!data && !error && <p>読み込み中…</p>}

                {data && data.total_seconds === 0 && (
                    <p className="daily-modal-empty">この日は記録がありません</p>
                )}

                {data && data.total_seconds > 0 && (
                    <div className="daily-modal-body">
                        <div className="daily-modal-left">
                            <DonutChart
                                labels={data.per_category.map((c) => c.name)}
                                values={data.per_category.map((c) => c.seconds)}
                                colors={data.per_category.map((c) => activityColor(c.activity_id))}
                                size={180}
                            />
                            <p className="daily-modal-total">合計：{formatSeconds(data.total_seconds)}</p>
                            <ul className="daily-modal-legend">
                                {data.per_category.filter((c) => c.seconds > 0).map((c) => (
                                    <li key={c.name}>
                                        <span className="daily-modal-color" style={{ backgroundColor: activityColor(c.activity_id) }}></span>
                                        {c.name}：{formatSeconds(c.seconds)}
                                    </li>
                                ))}
                            </ul>
                            <button
                                className="weekly-share-btn mt-2"
                                onClick={() => {
                                    const text = buildDailyShareText(date, data);
                                    const shareUrl = `${window.location.origin}/share/daily/${data.share_token}`;
                                    const url = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(shareUrl)}`;
                                    window.open(url, "_blank");
                                }}
                            >
                                𝕏 シェアする
                            </button>
                        </div>

                        <div className="daily-modal-right">
                            <p className="daily-modal-section-title">今日の行動履歴</p>
                            <ul className="daily-modal-logs">
                                {data.logs.map((log, i) => (
                                    <li key={i} className="daily-modal-log-item">
                                        <span className="daily-modal-log-time">{formatTime(log.logged_at)}</span>
                                        <span className="daily-modal-log-name">{log.activity_name}</span>
                                    </li>
                                ))}
                            </ul>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}
