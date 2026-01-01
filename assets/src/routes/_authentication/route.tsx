import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { createFileRoute, Outlet } from "@tanstack/react-router"

export const Route = createFileRoute('/_authentication')({
    component: AuthenticationLayout,
  })
  

export default function AuthenticationLayout() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <div className="absolute lg:top-32 sm:left-32 sm:right-32 lg:bottom-40 my-auto">
        <Card className="flex flex-col lg:flex-row p-0 justify-between rounded-3xl overflow-clip h-full">
          <CardHeader className="bg-[url(/images/bg.png)] bg-cover bg-bottom lg:w-5/12 xl:w-5/12 flex flex-col justify-center items-center pt-4">
            <CardTitle className="text-5xl flex flex-col gap-4 2xl:text-7xl">
              <img
                className="w-24 2xl:w-40 h-24 2xl:h-40 rounded-full mx-auto"
                src="https://media.istockphoto.com/id/1214084790/vector/black-cat-circle-symbol.jpg?s=612x612&w=0&k=20&c=7mafIEvOw7_Nf01hA4pHGzZIexKcI3HTcHqz0OQrt0s="
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
