import React from "react";
import { createRoot } from "react-dom/client";
import SettingsApp from "./settings/SettingsApp";

document.addEventListener("turbo:load", () => {
    const el = document.getElementById("settings-app");
    if (!el) return;
    const root = createRoot(el);
    root.render(<SettingsApp />);
});