export async function fetchWeekly(week = null) {
  const url = week ? `/api/weekly?week=${week}` : "/api/weekly";
  const res = await fetch(url, {
    headers: { Accept: "application/json" },
  });
  if (!res.ok) throw new Error("今週のデータ取得に失敗しました");
  return await res.json();
}