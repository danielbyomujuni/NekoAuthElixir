import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import React from "react"
import { useSearchParams } from 'react-router-dom';
import { toast } from "sonner";

export default function Register() {
    const [searchParams] = useSearchParams();

    const [email, setEmail] = React.useState("");
    const [username, setUsername] = React.useState("");
    const [display_name, setDisplayName] = React.useState("");
    const [password, setPassword] = React.useState("");
    const [password_confirmation, setPasswordConfirmation] = React.useState("");
    const [date_of_birth, setDateOfBirth] = React.useState("");

    const handleSubmit = async () => {
      console.log(JSON.stringify({
        email,
        display_name,
        user_name: username,
        password,
        password_confirmation,
        date_of_birth,
      }))

        const res = await fetch("/api/v1/register", {
          method: "POST",
          body: JSON.stringify({
            email,
            display_name,
            user_name: username,
            password,
            password_confirmation,
            date_of_birth,
          }),
        });
    
        if (res.status !== 200) {
          toast((await res.json()).value);
        }
      };
    
  

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
              onChange={(e) => {setEmail(e.target.value);}}
              required
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="date_of_birth">Date of Birth</Label>
            <Input
              id="date_of_birth"
              type="date"
              className={false ? "text-destructive border-destructive focus:border-destructive focus-visible:ring-destructive" : ""}
              onChange={(e) => {setDateOfBirth(e.target.value);}}
              required
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="username">Username</Label>
            <Input
              id="username"
              type="text"
              className={false ? "text-destructive border-destructive focus:border-destructive focus-visible:ring-destructive" : ""}
              onChange={(e) => {setUsername(e.target.value)}}
              required
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="display_name">Display Name</Label>
            <Input
              id="display_name"
              type="text"
              className={false ? "text-destructive border-destructive focus:border-destructive focus-visible:ring-destructive" : ""}
              onChange={(e) => {setDisplayName(e.target.value)}}
              required
            />
          </div>

          <div className="grid gap-2">
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              className={false ? "text-destructive border-destructive focus:border-destructive focus-visible:ring-destructive" : ""}
              onChange={(e) => {setPassword(e.target.value)}}
              required
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="password_confirmation">Confim Password</Label>
            <Input
              id="password_confirmation"
              type="password"
              className={false ? "text-destructive border-destructive focus:border-destructive focus-visible:ring-destructive" : ""}
              onChange={(e) => {setPasswordConfirmation(e.target.value)}}
              required
            />
          </div>
        </div>

        <Button className="w-full mt-4" onClick={() => {handleSubmit()}}>
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
