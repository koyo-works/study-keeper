import React, { useEffect, useRef } from "react";

export default function DonutChart({ labels, values, colors, size = 160 }) {
  const canvasRef = useRef(null);
  const chartRef = useRef(null);

  useEffect(() => {
    if (!canvasRef.current || values.length === 0) return;

    if (chartRef.current) chartRef.current.destroy();

    const ctx = canvasRef.current.getContext("2d");
    chartRef.current = new window.Chart(ctx, {
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
        plugins: {
          legend: { display: false },
        },
      },
    });

    return () => {
      if (chartRef.current) chartRef.current.destroy();
    };
  }, [labels, values, colors]);

  return <canvas ref={canvasRef} width={size} height={size} />;
}