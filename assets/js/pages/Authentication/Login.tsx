"use client"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import React from "react"
import { Label } from "@/components/ui/label"
import { useSearchParams } from 'react-router-dom';
import { toast } from "sonner"

const OK_STATUS = 200

export default function Login() {
    const [searchParams] = useSearchParams();

    console.log(searchParams)


    const [email, setEmail] = React.useState("");
    const [password, setPassword] = React.useState("");
  
    const handleSubmit = () => {

      const auth: any = {};
      searchParams.forEach((value, key) => {
        auth[key] = value;
      });


      fetch("/api/v1/login", {
        method: "POST",
        body: JSON.stringify({
          user: {
            email,
            password,
          },
          auth,
        }),
      }).then((res) => {
          if (res.status !== 201) {
              toast("Unable to Log into Account");
          } else {
            window.location.href = res.headers.get("Location")!;
          }
      });
    };

    
  return (
    <>

      <div className="flex flex-col gap-4 h-full">
        <h1 className="text-3xl mb-3">Sign in</h1>
        <div className="flex flex-col gap-8 ">
          <div className="flex flex-col gap-2 mt-auto">
            <Label htmlFor="email" className="">
              Email
            </Label>
            <Input id="email" type="email" className="" placeholder="Email" onChange={(e) => {setEmail(e.target.value)}} required />
          </div>
          <div className="grid gap-2 mb-auto">
            <div className="flex items-center">
              <Label htmlFor="password" className="">
                Password
              </Label>
              <a href={"#"} className="ml-auto inline-block text-sm underline hover:opacity-70">
                Forgot your password?
              </a>
            </div>
            <Input id="password" type="password" className="2xl:text-3xl 2xl:h-14" placeholder="password" onChange={(e) => {setPassword(e.target.value)}} required />
          </div>
          <Button className="w-full" onClick={(e) => {handleSubmit()}}>
            Login
          </Button>
        </div>
      </div>
      <div className="mt-4 text-center text-sm">
        Don&apos;t have an account?{" "}
        <a href={`register?${searchParams.toString()}`} className="underline hover:opacity-70">
          Sign up
        </a>
      </div>
    </>
  )
}
