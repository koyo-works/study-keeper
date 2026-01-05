document.addEventListener("DOMContentLoaded", () => {
  fetch("/records/analytics.json")
    .then(res => res.json())
    .then(data => {
      const labels = data.chart.labels;
      const counts = data.chart.counts;

      if (counts.length === 0) {
        document.getElementById("weeklyChart").remove();
        document.getElementById("activityCounts").innerHTML =
          "<p>今週の記録はまだありません</p>";
        return;
      }

      // ▼ 円グラフ
      const ctx = document.getElementById("weeklyChart").getContext("2d");

      new Chart(ctx, {
        type: "pie",
        data: {
          labels: labels, // ← 凡例は名前だけ
          datasets: [{
            data: counts,
            backgroundColor: [
              "#60a5fa",
              "#34d399",
              "#fbbf24",
              "#f87171",
              "#a78bfa"
            ]
          }]
        },
        options: {
          plugins: {
            legend: {
              position: "top"
            },
            tooltip: {
              callbacks: {
                label: function(context) {
                  const label = context.label;
                  const value = context.raw;
                  const total = context.dataset.data.reduce((a, b) => a + b, 0);
                  const percent = Math.round((value / total) * 100);
                  return `${label}: ${value}回（${percent}%）`;
                }
              }
            }
          }
        }
      });

      const colors = [
        "#60a5fa",
        "#34d399",
        "#fbbf24",
        "#f87171",
        "#a78bfa"
      ];

      // ▼ 下の回数リスト（ここで数値を見せる）
      const list = document.getElementById("activityCounts");
      list.innerHTML = "";

      labels.forEach((label, i) => {
        const li = document.createElement("li");
        li.className = "activity-count-item";
        li.innerHTML = `
          <div class="activity-left">
            <span class="activity-color" style="background-color:${colors[i % colors.length]}"></span>
            <span>${label}</span>
          </div>
          <span class="activity-count">${counts[i]}回</span>
        `;
        list.appendChild(li);
      });
    });
});