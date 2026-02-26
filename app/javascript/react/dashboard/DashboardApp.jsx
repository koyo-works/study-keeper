import React, { useEffect, useState } from "react";
import LogForm from "./components/LogForm";
import TodayHistory from "./components/TodayHistory";
import CurrentStatus from "./components/CurrentStatus"; 
import SummaryStatus from "./components/SummaryStatus";
import { fetchToday, fetchActivities, postLog, stopLog } from "./api";

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

  async function handleStopTimer() {
    try {
      await stopLog();
      setDashboard((prev) => ({
        ...prev,
        current_log: null,
      }));
    } catch (e) {
      console.error(e);
      setError(e.message);
    }
  }

  const logs = dashboard?.logs ?? [];

  return (
    <div className="dashboard-wrap">
      {error && <div className="alert alert-danger">{error}</div>}

      <div className="dashboard-top-row">
        <div className="dashboard-form-col">
          <LogForm
            activities={activities}
            onSubmit={handleSubmit}
            isSubmitting={isSubmitting}
          />
        </div>
        <div className="dashboard-right-col">
          {/* PC：推定時間→記録まとめの順 / SP：推定時間→記録まとめの順 */}
          <div className="dashboard-current-status">
            <CurrentStatus dashboard={dashboard} activities={activities} now={now} onStop={handleStopTimer} />
          </div>
          <div className="dashboard-summary">
            <SummaryStatus dashboard={dashboard} now={now} />
          </div>
        </div>
      </div>

      <TodayHistory logs={logs} activities={activities} now={now} dashboard={dashboard} />
    </div>
  );
}