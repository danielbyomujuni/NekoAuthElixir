import { Button } from "@/components/ui/button"
import { login } from "@/lib/neko_auth"
import { Cat } from 'lucide-react'
import React from "react"

export function Home() {
  return (
    <div className="flex min-h-screen flex-col">
      <header className="sticky top-0 z-40 w-full border-b bg-background">
        <div className="container flex h-16 items-center space-x-4 sm:justify-between sm:space-x-0 mx-auto">
          <div className="flex gap-2 items-center text-xl font-bold">
            <Cat className="h-6 w-6 text-pink-500" />
            <span>Neko Auth</span>
          </div>
          <div className="flex flex-1 items-center justify-end space-x-4 mx-auto">
            <nav className="flex items-center space-x-1">
              <a
                href="#features"
                className="px-4 py-2 text-sm font-medium hover:text-pink-500 transition-colors"
              >
                Features
              </a>
              <a
                href="#docs"
                className="px-4 py-2 text-sm font-medium hover:text-pink-500 transition-colors"
              >
                Docs
              </a>
              <Button className="bg-pink-500 hover:bg-pink-600" onClick={login}>
                Login to Portal
              </Button>
            </nav>
          </div>
        </div>
      </header>
      <main className="flex-1 mx-auto">
        <section className="w-full py-12 md:py-24 lg:py-32 xl:py-48">
          <div className="container px-4 md:px-6">
            <div className="grid gap-6 lg:grid-cols-[1fr_400px] lg:gap-12 xl:grid-cols-[1fr_500px]">
              <div className="flex flex-col justify-center space-y-4">
                <div className="space-y-2">
                  <h1 className="text-3xl font-bold tracking-tighter sm:text-5xl xl:text-6xl/none">
                    Simplify Authentication for Your Personal Projects
                  </h1>
                  <p className="max-w-[600px] text-muted-foreground md:text-xl">
                    Neko Auth is your personal OAuth provider that makes authentication easy, secure, and hassle-free for all your projects.
                  </p>
                </div>
                <div className="flex flex-col gap-2 min-[400px]:flex-row">
                  <Button size="lg" className="bg-pink-500 hover:bg-pink-600" onClick={login}>
                    Login to Portal
                  </Button>
                  <Button variant="outline" size="lg">
                    <a href="#docs">Read Documentation</a>
                  </Button>
                </div>
              </div>
              <img
                src="https://picsum.photos/550/550"
                alt="Neko Auth Illustration"
                className="mx-auto aspect-square overflow-hidden rounded-xl object-cover w-[550px] h-[550px]"
              />
            </div>
          </div>
        </section>
        
        <section id="features" className="w-full py-12 md:py-24 lg:py-32 ">
          <div className="container px-4 md:px-6">
            <div className="flex flex-col items-center justify-center space-y-4 text-center">
              <div className="space-y-2">
                <h2 className="text-3xl font-bold tracking-tighter sm:text-5xl">Features</h2>
                <p className="max-w-[900px] text-muted-foreground md:text-xl/relaxed lg:text-base/relaxed xl:text-xl/relaxed">
                  Everything you need for authentication in your personal projects
                </p>
              </div>
            </div>
            <div className="mx-auto grid max-w-5xl items-center gap-6 py-12 lg:grid-cols-3 lg:gap-12">
              <div className="flex flex-col justify-center space-y-4 rounded-lg border bg-background p-6 shadow-sm">
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-pink-100">
                  <Cat className="h-6 w-6 text-pink-500" />
                </div>
                <div className="space-y-2">
                  <h3 className="text-xl font-bold">OAuth 2.0</h3>
                  <p className="text-muted-foreground">
                    Full support for OAuth 2.0 flows with secure token handling
                  </p>
                </div>
              </div>
              <div className="flex flex-col justify-center space-y-4 rounded-lg border bg-background p-6 shadow-sm">
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-pink-100">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="24"
                    height="24"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    className="h-6 w-6 text-pink-500"
                  >
                    <rect width="18" height="11" x="3" y="11" rx="2" ry="2" />
                    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                  </svg>
                </div>
                <div className="space-y-2">
                  <h3 className="text-xl font-bold">Secure by Default</h3>
                  <p className="text-muted-foreground">
                    Built with security best practices and regular updates
                  </p>
                </div>
              </div>
              <div className="flex flex-col justify-center space-y-4 rounded-lg border bg-background p-6 shadow-sm">
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-pink-100">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="24"
                    height="24"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    className="h-6 w-6 text-pink-500"
                  >
                    <path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z" />
                    <circle cx="12" cy="12" r="3" />
                  </svg>
                </div>
                <div className="space-y-2">
                  <h3 className="text-xl font-bold">Easy Integration</h3>
                  <p className="text-muted-foreground">
                    Simple API and SDKs for all your favorite frameworks
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>
        
        <section id="docs" className="w-full py-12 md:py-24 lg:py-32">
          <div className="container px-4 md:px-6">
            <div className="grid gap-10 px-10 md:gap-16 lg:grid-cols-2">
              <div className="space-y-4">
                <div className="inline-block rounded-lg bg-pink-100 px-3 py-1 text-sm text-pink-700">Documentation</div>
                <h2 className="text-3xl font-bold tracking-tighter sm:text-4xl md:text-5xl">
                  Get started in minutes
                </h2>
                <p className="max-w-[600px] text-muted-foreground md:text-xl/relaxed">
                  Our documentation covers everything from basic setup to advanced configurations. Integrate Neko Auth into your projects with ease using your favorite oauth 2.0 client.
                </p>
                <Button className="bg-pink-500 hover:bg-pink-600" onClick={login}>
                  Login to Portal
                </Button>
              </div>
              <div className="rounded-lg border bg-card p-6 shadow-sm">
                <pre className="overflow-x-auto rounded bg-muted p-4">
                  <code className="text-sm font-mono">
                    {`// auth.ts
import NextAuth from "next-auth"
import NekoAuth from "neko_auth/clients/authjs"
export const { auth, handlers } = NextAuth({ providers: [NekoAuth] })

// middleware.ts
export { auth as middleware } from "@/auth"

// app/api/auth/[...nextauth]/route.ts
import { handlers } from "@/auth"
export const { GET, POST } = handlers`}
                  </code>
                </pre>
              </div>
            </div>
          </div>
        </section>
        
        <section className="w-full py-12 md:py-24 lg:py-32">
          <div className="container grid items-center justify-center gap-4 px-4 text-center md:px-6">
            <div className="space-y-3">
              <h2 className="text-3xl font-bold tracking-tighter md:text-4xl/tight">
                Ready to simplify authentication?
              </h2>
              <p className="mx-auto max-w-[600px] text-muted-foreground md:text-xl/relaxed lg:text-base/relaxed xl:text-xl/relaxed">
                Access your personal OAuth portal and start integrating with your projects today.
              </p>
            </div>
            <div className="mx-auto w-full max-w-sm space-y-2">
              <Button size="lg" className="w-full bg-pink-500 hover:bg-pink-600" onClick={login}>
               Login to Portal
              </Button>
            </div>
          </div>
        </section>
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