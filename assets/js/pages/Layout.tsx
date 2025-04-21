import React from "react"
import { Outlet } from "react-router"
import { Toaster } from "@/components/ui/sonner"
import { Background } from "@/components/Background"

export function Layout() {
  return (
    <>
      <Background />
      <Outlet />
      <Toaster />
    </>
  )
}
