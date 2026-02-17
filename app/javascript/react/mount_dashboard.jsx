import React from "react";
import { createRoot } from "react-dom/client"
import DashboardApp from "./DashboardApp";

const mount = () => {
    const el = document.getElementById("dashboard-app");
    if (!el) return;

    createRoot(el).render(<DashboardApp />);
};

document.addEventListener("turbo:load", mount);
document.addEventListener("DOMContentLoaded", mount);