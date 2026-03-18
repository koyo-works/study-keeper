import React from "react";
import { createRoot } from "react-dom/client";
import MonthlyApp from "./monthly/MonthlyApp";

document.addEventListener("turbo:load", () => {
    const el = document.getElementById("monthly-app");
    if (!el) return;
    const root = createRoot(el);
    root.render(<MonthlyApp />);
});