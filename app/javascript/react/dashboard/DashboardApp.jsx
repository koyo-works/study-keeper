import React, { useEffect, useState } from "react";
import { fetchToday, fetchActivities, postLog } from "./api";
import LogForm from "./components/LogForm";

export default function DashboardApp() {
  const [dashboard, setDashboard] = useState(null);
  const [activities, setActivities] = useState([]);
  const [error, setError] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function loadToday() {
    const data = await fetchToday();
    setDashboard(data);
  }

  async function loadActivities() {
    const list = await fetchActivities();
    setActivities(list);
  }

  async function loadAll() {
    setError(null);
    try {
      await Promise.all([loadToday(), loadActivities()]);
    } catch (e) {
      console.error(e);
      setError(e.message);
    }
  }

  useEffect(() => {
    loadAll();
  }, []);

  async function handleSubmit({ activityId, memo, onSuccess }) {
    setError(null);
    console.log("DashboardApp.handleSubmit", { activityId, memo });

    try {
      setIsSubmitting(true);
      await postLog({ activityId, memo });

      onSuccess?.();

      // 動作確認しやすいようにリダイレクト
      window.location.href = "/learning_path";
    } catch (e) {
      console.error(e);
      setError(e.message);
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div>
      {error && <div className="alert alert-danger">{error}</div>}

      <LogForm
        activities={activities}
        onSubmit={handleSubmit}
        isSubmitting={isSubmitting}
      />

      <hr />

      <pre style={{ whiteSpace: "pre-wrap" }}>
        {dashboard ? JSON.stringify(dashboard, null, 2) : "loading..."}
      </pre>
    </div>
  );
}