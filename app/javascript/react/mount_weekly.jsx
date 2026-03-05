// app/javascript/react/mount_weekly.jsx
import React from "react";
import { createRoot } from "react-dom/client";
import WeeklyApp  from "./weekly/WeeklyApp";

document.addEventListener("turbo:load", () => {
  const el = document.getElementById("weekly-app");
  console.log("★ mount_dashboard: イベント発火したよ！ el=", el);
  if (!el) return;

  console.log("★ React マウント開始！");
  const root = createRoot(el);
  root.render(<WeeklyApp  />);
  console.log("★ React マウント完了（WeeklyApp 書き換え済みのはず）");
});
