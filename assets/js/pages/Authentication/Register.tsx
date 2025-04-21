import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import React from "react"
import { useSearchParams } from 'react-router-dom';

export default function Register() {
    const [searchParams] = useSearchParams();

  return (
    <>
      <div className="my-auto flex-col gap-4 h-full">
        <h1 className="text-3xl mb-3">Register</h1>
        <div className="grid gap-4 grid-cols-2 mt-auto mb-auto">
          <div className="grid gap-2">
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              placeholder="d@nekosyndicate.com"
              className={false ? "text-destructive border-destructive focus:border-destructive focus-visible:ring-destructive" : ""}
              onChange={(e) => {}}
              required
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="date_of_birth">Date of Birth</Label>
            <Input
              id="date_of_birth"
              type="date"
              className={false ? "text-destructive border-destructive focus:border-destructive focus-visible:ring-destructive" : ""}
              onChange={(e) => {}}
              required
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="username">Username</Label>
            <Input
              id="username"
              type="text"
              className={false ? "text-destructive border-destructive focus:border-destructive focus-visible:ring-destructive" : ""}
              onChange={(e) => {}}
              required
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="display_name">Display Name</Label>
            <Input
              id="display_name"
              type="text"
              className={false ? "text-destructive border-destructive focus:border-destructive focus-visible:ring-destructive" : ""}
              onChange={(e) => {}}
              required
            />
          </div>

          <div className="grid gap-2">
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              className={false ? "text-destructive border-destructive focus:border-destructive focus-visible:ring-destructive" : ""}
              onChange={(e) => {}}
              required
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="password_confirmation">Confim Password</Label>
            <Input
              id="password_confirmation"
              type="password"
              className={false ? "text-destructive border-destructive focus:border-destructive focus-visible:ring-destructive" : ""}
              onChange={(e) => {}}
              required
            />
          </div>
        </div>

        <Button className="w-full mt-4" onClick={() => {}}>
          Register
        </Button>

        <div className="mt-4 text-center text-sm">
          Already have an account?{" "}
          <a href={`login?${searchParams.toString()}`} className="underline">
            Login
          </a>
        </div>
      </div>
    </>
  )
}
