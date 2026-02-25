import React, { useEffect, useRef } from "react";

export default function DonutChart({ labels, values, colors, size = 160 }) {
  const canvasRef = useRef(null);
  const chartRef = useRef(null);

  useEffect(() => {
    if (!canvasRef.current) return;

    chartRef.current = new window.Chart(canvasRef.current.getContext("2d"), {
      type: "doughnut",
      data: {
        labels,
        datasets: [{
          data: values,
          backgroundColor: colors,
          borderWidth: 2,
          borderColor: "#ffffff",
        }],
      },
      options: {
        responsive: false,
        animation: {
          duration: 600,
          easing: "easeInOutQuart",
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: (context) => {
                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                const value = context.parsed;
                const pct = Math.round((value / total) * 100);
                const h = Math.floor(value / 60);
                const m = value % 60;
                const timeStr = h > 0 ? `${h}時間${m}分` : `${m}分`;
                return ` ${timeStr}（${pct}%）`;
              },
            },
          },
        },
      },
    });

    return () => {
      if (chartRef.current) chartRef.current.destroy();
    };
  }, []);

  useEffect(() => {
    if (!chartRef.current || values.length === 0) return;
    chartRef.current.data.labels = labels;
    chartRef.current.data.datasets[0].data = values;
    chartRef.current.data.datasets[0].backgroundColor = colors;
    chartRef.current.update();
  }, [labels.join(","), values.join(","), colors.join(",")]);

  return <canvas ref={canvasRef} width={size} height={size} />;
}