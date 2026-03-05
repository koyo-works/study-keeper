export async function fetchWeekly() {
  const res = await fetch("/api/weekly", {
    headers: { Accept: "application/json" },
  });
  if (!res.ok) throw new Error("今週のデータ取得に失敗しました");
  return await res.json();
}