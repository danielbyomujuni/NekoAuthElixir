import { Sidebar } from "@/components/sidebar"
import { createFileRoute, Outlet } from "@tanstack/react-router"
import { Cat } from "lucide-react"


export const Route = createFileRoute('/_portal')({
    component: LayoutPortal,
  })
  

export function LayoutPortal() {
  return (
    <div className="flex min-h-screen flex-col">
      <header className="sticky top-0 z-40 w-full border-b bg-background">
        <div className="container flex h-16 items-center space-x-4 sm:justify-between sm:space-x-0 mx-auto">
          <a href="/">
          <div className="flex gap-2 items-center text-xl font-bold">
            <Cat className="h-6 w-6 text-pink-500" />
            <span>Neko Auth</span>
          </div>
          </a>
        </div>
      </header>
      <main className="py-4 mb-auto">
        <Sidebar />
        <Outlet />
      </main>
      <footer className="w-full border-t py-6 md:py-0 ">
        <div className="container flex flex-col items-center justify-between gap-4 md:h-24 md:flex-row mx-auto">
          <div className="flex gap-2 items-center text-lg font-semibold">
            <Cat className="h-5 w-5 text-pink-500" />
            <span>Neko Auth</span>
          </div>
          <p className="text-center text-sm leading-loose text-muted-foreground md:text-left">
            © {new Date().getFullYear()} Nekosyndicate. All rights reserved. Your personal OAuth provider.
          </p>
        </div>
      </footer>
    </div>
  )
}