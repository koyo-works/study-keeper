import React from "react";

export default function WeeklyTable({ summary, formatMinutes }) {
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
                    {summary.map((s) => (
                        <tr key={s.activity_id}>
                            <td>{s.activity_name}</td>
                            <td>{s.count}回</td>
                            <td>{formatMinutes(s.total_minutes)}</td>
                            <td>{s.percentage}%</td>
                            <td>-</td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}