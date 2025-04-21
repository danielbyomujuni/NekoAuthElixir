import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import React from "react"
import { Outlet } from "react-router"

export default function AuthenticationLayout() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <div className="absolute top-6 lg:top-32 left-32 right-32 lg:bottom-40">
        <Card className="flex flex-col lg:flex-row p-0 justify-between rounded-3xl overflow-clip h-full">
          <CardHeader className="bg-[url(/images/bg.png)] bg-cover bg-bottom lg:w-5/12 xl:w-5/12 flex flex-col justify-center items-center pt-4">
            <CardTitle className="text-5xl flex flex-col gap-4 2xl:text-7xl">
              <img
                className="w-24 2xl:w-80 h-24 2xl:h-80 rounded-full mx-auto"
                src="http://cdn.nekosyndicate.com/assets/NekoSyndicate/logo-v1.png"
                alt="Neko Logo"
              />
            </CardTitle>
            <CardDescription className="pt-5 text-3xl 2xl:text-3xl text-foreground mx-auto text-shadow h-full">
              Nekosyndicate
            </CardDescription>
          </CardHeader>
          <CardContent className="lg:w-7/12 xl:w-7/12 my-auto h-full flex flex-col pt-6 pb-6">
            <Outlet />
          </CardContent>
        </Card>
        <div className="flex justify-end gap-4 mt-2 mr-4">
          <a href="#" className="hover:opacity-60">
            Privacy
          </a>
          <a href="#" className="hover:opacity-60">
            Terms of Service
          </a>
        </div>
      </div>
    </main>
  )
}
