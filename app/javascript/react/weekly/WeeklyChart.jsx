import React from "react";
import DonutChart from "../dashboard/components/charts/DonutChart";

const COLORS = ["#818cf8", "#fb923c", "#34d399", "#f43f5e", "#900ce9"];

export default function WeeklyChart({ summary }) {
    return (
        <DonutChart
            labels={summary.map((s) => s.activity_name)}
            values={summary.map((s) => s.total_minutes)}
            colors={summary.map((_, i) => COLORS[i % COLORS.length])}
        />
    );
}
