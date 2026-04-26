const VAPID_PUBLIC_KEY = document.querySelector("meta[name='vapid-public-key']")?.content;

function urlBase64ToUint8Array(base64String) {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/");
  const rawData = atob(base64);
  return Uint8Array.from([...rawData].map((c) => c.charCodeAt(0)));
}

async function subscribePush() {
  if (!("serviceWorker" in navigator) || !("PushManager" in window)) return;
  if (!VAPID_PUBLIC_KEY) return;

  const reg = await navigator.serviceWorker.register("/service_worker.js");
  const permission = await Notification.requestPermission();
  if (permission !== "granted") return;

  const subscription = await reg.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(VAPID_PUBLIC_KEY),
  });

  const json = subscription.toJSON();
  const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;

  await fetch("/api/push_subscriptions", {
    method: "POST",
    headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
    body: JSON.stringify({
      endpoint: json.endpoint,
      p256dh: json.keys.p256dh,
      auth: json.keys.auth,
    }),
  });
}

document.addEventListener("DOMContentLoaded", () => {
  const btn = document.getElementById("push-notify-btn");
  if (btn) btn.addEventListener("click", subscribePush);
});
