"use client"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import React from "react"
import { Label } from "@/components/ui/label"
import { useSearchParams } from 'react-router-dom';

const OK_STATUS = 200

export default function Login() {
    const [searchParams] = useSearchParams();

    console.log(searchParams)
  return (
    <>

      <div className="flex flex-col gap-4 h-full">
        <h1 className="text-3xl mb-3">Sign in</h1>
        <div className="flex flex-col gap-8 mt-auto mb-auto">
          <div className="flex flex-col gap-2 mt-auto">
            <Label htmlFor="email" className="">
              Email
            </Label>
            <Input id="email" type="email" className="" placeholder="Email" onChange={(e) => {}} required />
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
            <Input id="password" type="password" className="2xl:text-3xl 2xl:h-14" placeholder="password" onChange={(e) => {}} required />
          </div>
          <Button className="w-full" onClick={(e) => {}}>
            Login
          </Button>
        </div>
      </div>
      <div className="mt-4 text-center text-sm">
        Don&apos;t have an account?{" "}
        <a href={"#"} className="underline hover:opacity-70">
          Sign up
        </a>
      </div>
    </>
  )
}
