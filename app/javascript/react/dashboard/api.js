function csrfToken() {
  const tag = document.querySelector('meta[name="csrf-token"]');
  return tag && tag.content;
}

export async function fetchToday() {
  const res = await fetch("/api/dashboard/today", {
    headers: { Accept: "application/json" },
  });
  if (!res.ok) throw new Error("今日のデータ取得に失敗しました");
  return await res.json();
}

export async function fetchActivities() {
  const res = await fetch("/api/activities", {
    headers: { Accept: "application/json" },
  });
  if (!res.ok) throw new Error("カテゴリ取得に失敗しました");
  return await res.json();
}

export async function postLog({ activityId, memo }) {
  const res = await fetch("/api/dashboard/logs", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      "X-CSRF-Token": csrfToken(),
    },
    body: JSON.stringify({
      activity_id: activityId, // ← ここは snake_case
      memo,
    }),
  });

  const data = await res.json().catch(() => ({}));

  if (!res.ok || data.ok === false) {
    throw new Error(data.error || "行動の記録に失敗しました");
  }

  return data;
}

export async function stopLog() {
  const res = await fetch("/api/dashboard/stop", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      "X-CSRF-Token": csrfToken(),
    },
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok || data.ok === false) {
    throw new Error(data.error || "計測の停止に失敗しました");
  }
  return data;
}