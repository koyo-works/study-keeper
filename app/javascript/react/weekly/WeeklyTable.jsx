import React from "react";

export default function WeeklyTable({ summary, prevSummary = [], formatSeconds }) {
    const prevMap = Object.fromEntries(prevSummary.map((s) => [s.activity_id, s.total_seconds]));

    return (
        <div style={{ overflowX: "auto", width: "100%" }}>
            <table style={{ width: "max-content", minWidth: "100%" }}>
                <thead>
                    <tr>
                        <th>カテゴリ</th>
                        <th>回数</th>
                        <th>実施時間</th>
                        <th>割合</th>
                        <th>先週比</th>
                    </tr>
                </thead>
                <tbody>
                    {summary.map((s) => {
                        const prev = prevMap[s.activity_id];
                        const diff = prev != null ? s.total_seconds - prev : null;
                        const isNew = prev == null;

                        let diffLabel, diffColor;
                        if (isNew) {
                            diffLabel = "NEW";
                            diffColor = "#6366f1";
                        } else if (diff > 0) {
                            diffLabel = `+${formatSeconds(diff)}`;
                            diffColor = "#22c55e";
                        } else if (diff < 0) {
                            diffLabel = `▼${formatSeconds(Math.abs(diff))}`;
                            diffColor = "#f43f5e";
                        } else {
                            diffLabel = "±0";
                            diffColor = "#94a3b8";
                        }

                        return (
                            <tr key={s.activity_id}>
                                <td>{s.activity_name}</td>
                                <td>{s.count}回</td>
                                <td>{formatSeconds(s.total_seconds)}</td>
                                <td>{s.percentage}%</td>
                                <td style={{ color: diffColor, fontWeight: 700 }}>{diffLabel}</td>
                            </tr>
                        );
                    })}
                </tbody>
            </table>
        </div>
    );
}
