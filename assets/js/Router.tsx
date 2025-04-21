import React from "react"
import { createBrowserRouter } from "react-router"
import { Layout } from "./pages/Layout"
import { Home } from "./pages/Home"
import Login from "./pages/Authentication/Login"
import AuthenticationLayout from "./pages/Authentication/AuthLayout"
import Register from "./pages/Authentication/Register"

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
        },{
          path: "/",
          element: <AuthenticationLayout/>,
          children: [
            {
              path: "/login",
              element: <Login />
            },
            {
              path: "/register",
              element: <Register />
            }
          ]
        }
      ]
    }
  ])
