import React from "react"
import { createBrowserRouter } from "react-router"
import { Layout } from "./pages/Layout"
import { Home } from "./pages/Home"

export const router = () =>
  createBrowserRouter([
    {
      id: "root",
      path: "/",
      element: <Layout />,
      children: [
        {
          path: "",
          element: <Home />
        }
      ]
    }
  ])
