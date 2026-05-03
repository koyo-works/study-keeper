import React from "react";
import DonutChart from "../dashboard/components/charts/DonutChart";
import { activityColor } from "../activityColor";

export default function WeeklyChart({ summary }) {
    return (
        <DonutChart
            labels={summary.map((s) => s.activity_name)}
            values={summary.map((s) => s.total_seconds)}
            colors={summary.map((s) => activityColor(s.activity_id))}
            size={240}
        />
    );
}
