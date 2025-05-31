import { Outlet, createRootRoute } from '@tanstack/react-router'
import { Toaster } from "@/components/ui/sonner"
import Background from "@/components/background"

export const Route = createRootRoute({
  component: () => (
    <>
      <Background />
      <Outlet />
      <Toaster />
    </>
  )
});



