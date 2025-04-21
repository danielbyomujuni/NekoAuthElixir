import React from "react"
import { createRoot } from "react-dom/client"
import "../css/app.css"
import { RouterProvider } from "react-router"
import { router } from "../js/Router"

const container = document.getElementById("root")

if (container) {
  const root = createRoot(container!)

  root.render(
    <React.StrictMode>
      <RouterProvider router={router()} />
    </React.StrictMode>
  )
}
