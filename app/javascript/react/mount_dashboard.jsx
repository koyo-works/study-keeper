// app/javascript/react/dashboard/mount_dashboard.js
import React from "react";
import { createRoot } from "react-dom/client";
import DashboardApp from "./dashboard/DashboardApp";

document.addEventListener("turbo:load", () => {
  const el = document.getElementById("dashboard-app");
  console.log("★ mount_dashboard: イベント発火したよ！ el=", el);
  if (!el) return;

  console.log("★ React マウント開始！");
  const root = createRoot(el);
  root.render(<DashboardApp />);
  console.log("★ React マウント完了（DashboardApp 書き換え済みのはず）");
});
