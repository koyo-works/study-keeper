import React, { useEffect, useState } from "react";
import { fetchToday, fetchActivities, postLog } from "./api";
import LogForm from "./components/LogForm";
import TodayHistory from "./components/TodayHistory";
import CurrentStatus from "./components/CurrentStatus"; 
import SummaryStatus from "./components/SummaryStatus";

export default function DashboardApp() {
  const [dashboard, setDashboard] = useState(null);
  const [activities, setActivities] = useState([]);
  const [error, setError] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [now, setNow] = useState(new Date());

  async function loadAll() {
    setError(null);
    try {
      const [todayData, activityList] = await Promise.all([fetchToday(), fetchActivities()]);
      setDashboard(todayData);
      setActivities(activityList);
    } catch (e) {
      console.error(e);
      setError(e.message);
    }
  }

  useEffect(() => { loadAll(); }, []);

  // 1秒ごとにnowを更新
  useEffect(() => {
    const currentLog = dashboard?.current_log;
    if (!currentLog) return; //ログが無ければタイマー不要

    const timer = setInterval(() => {
      setNow(new Date());
    }, 1000);

    return () => clearInterval(timer); // unmount時にクリア
  }, [dashboard?.current_log]);

  async function handleSubmit({ activityId, memo, onSuccess }) {
    setError(null);
    try {
      setIsSubmitting(true);
      const data = await postLog({ activityId, memo });

      // POSTレスポンスで直接stateを更新（loadAll不要）
      setDashboard((prev) => ({
        ...prev,
        logs: [...(prev?.logs ?? []), data.record],
        summary_per_category: data.summary_per_category,
        current_log: data.record,
        now: data.now,
      }));

      setNow(new Date()); // タイマーリセット

      onSuccess?.();
    } catch (e) {
      console.error(e);
      setError(e.message);
    } finally {
      setIsSubmitting(false);
    }
  }

  const logs = dashboard?.logs ?? [];

  return (
    <div style={{ padding: "24px 32px", display: "flex", flexDirection: "column", gap: 16, maxWidth: 1100,  margin: "0 auto",}}>
      {error && <div className="alert alert-danger">{error}</div>}

      {/* 上段：フォーム＋サマリー */}
      <div style={{ display: "flex", gap: 16, alignItems: "stretch" }}>  
        <div style={{ flex: "0 0 500px" }}>  {/* ← flex: 1 から固定幅に変更 */}
          <LogForm
            activities={activities}
            onSubmit={handleSubmit}
            isSubmitting={isSubmitting}
          />
        </div>
        <div style={{ flex: 1 }}>  {/* ← width: 320 から残り幅に変更 */}
          <SummaryStatus dashboard={dashboard} now={now}/>
        </div>
      </div>

      {/* 中段：推定時間 */}
      <CurrentStatus dashboard={dashboard} activities={activities} />
      
      {/* 下段：今日の履歴 */}
      <TodayHistory logs={logs} activities={activities} />

    </div>
  );
}