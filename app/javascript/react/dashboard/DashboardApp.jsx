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

  async function handleSubmit({ activityId, memo, onSuccess }) {
    setError(null);
    try {
      setIsSubmitting(true);
      await postLog({ activityId, memo });
      onSuccess?.();
      await loadAll();
    } catch (e) {
      console.error(e);
      setError(e.message);
    } finally {
      setIsSubmitting(false);
    }
  }

  const logs = dashboard?.logs ?? [];

  return (
    <div style={{ display: "flex", gap: 24, alignItems: "flex-start", padding: 24 }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
        {error && <div className="alert alert-danger">{error}</div>}
        <LogForm
          activities={activities}
          onSubmit={handleSubmit}
          isSubmitting={isSubmitting}
        />
        <CurrentStatus dashboard={dashboard} activities={activities} />
      </div>
      <SummaryStatus dashboard={dashboard} />
      <TodayHistory logs={logs} activities={activities} />
    </div>
  );
}