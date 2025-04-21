/**
 * File from tailwindui
 */
import React, { useState } from "react"
import { Outlet } from "react-router"

export function Layout() {
  const [sidebarOpen, setSidebarOpen] = useState(false)

  return (
    <>
      <Outlet />
    </>
  )
}
