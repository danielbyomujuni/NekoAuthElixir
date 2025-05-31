import React, { useEffect, useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle} from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { toast } from "sonner"
import create_client from "@/lib/apollo"
const mockUser = {
  user_name: "John Doe",
  display_name: "",
  descriminator: 0,
  email_verified: true,
  email: "john@example.com",
  pfp: "/placeholder.svg?height=100&width=100"
}

import { gql } from "@apollo/client"
import { createFileRoute } from "@tanstack/react-router"

export const Route = createFileRoute('/portal/')({
    component: HomePortal,
  })

export default function HomePortal() {
  const [user, setUser] = useState(mockUser)
  const [isUploading, setIsUploading] = useState(false)

  useEffect(() => {
    const query = gql`
      {
        users {
          dateOfBirth
          descriminator
          displayName
          email
          emailVerified
          userName
        }
      }
    `

    create_client()
      .query({
        query,
        variables: undefined
      })
      .then((result) => {
        if (result.data.users != null) {
          setUser({
            user_name: result.data.users[0].userName,
            display_name: result.data.users[0].displayName,
            descriminator: result.data.users[0].descriminator,
            email_verified: result.data.users[0].emailVerified,
            email: result.data.users[0].email,
            pfp: `/api/v1/avatars/${result.data.users[0].userName}/${result.data.users[0].descriminator}`
          })
        }
      })
      .catch(() => {})
  }, [])

  const handleAvatarChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    if (!event.target.files || event.target.files.length === 0) {
      return;
    }

    const file = event.target.files[0];
    if (!file.type.startsWith('image/')) {
      toast.error('Please select an image file');
      return;
    }

    setIsUploading(true);

    try {
      // Convert file to base64
      const base64File = await new Promise((resolve) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result);
        reader.readAsDataURL(file);
      });

      const mutation = gql`
        mutation UpdateUserAvatar($image: Binary!) {
          updateUser(image: $image) {
            image
          }
        }
      `;

      const result = await create_client().mutate({
        mutation,
        variables: {
          image: base64File
        }
      });


      if (result.data.updateUser) {
        // Update the user's avatar in the UI
        setUser(prev => ({
          ...prev,
          pfp: `${base64File}`
        }));
        toast.success('Avatar updated successfully');
      }
    } catch (error) {
      console.error('Error uploading avatar:', error);
      toast.error('Failed to update avatar');
    } finally {
      setIsUploading(false);
    }
  }


  const handleSaveChanges = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    const mutation = gql`
      mutation UpdateUserDisplayName($displayName: String!) {
        updateUser(displayName: $displayName) {
          displayName
        }
      }
    `

    create_client()
      .mutate({
        mutation,
        variables: {
          email: user.email,
          displayName: user.display_name
        }
      })
      .then((result) => {
        toast("Changes saved successfully.")
        console.log("Updated:", result.data.updateUser)
      })
      .catch((error) => {
        console.error(error)
      })
    // Implement save changes logic here
  }

  return (
    <div className="space-y-6 w-full max-w-3xl mx-auto">
      <div>
        <h3 className="text-lg font-medium">Profile</h3>
        <p className="text-sm text-muted-foreground">Manage your account settings and preferences.</p>
      </div>
      <Separator />
      <div className="grid gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Personal Information</CardTitle>
            <CardDescription>Update your personal details here.</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSaveChanges}>
              <div className="grid gap-6">
                <div className="flex items-center space-x-4">
                  <Avatar className="h-24 w-24">
                    <AvatarImage src={user.pfp} alt={user.user_name} />
                    <AvatarFallback>{user.display_name.charAt(0)}</AvatarFallback>
                  </Avatar>
                  <div>
                    <Label htmlFor="avatar-upload" className="cursor-pointer">
                      <div className="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-secondary text-secondary-foreground hover:bg-secondary/80 h-10 px-4 py-2">
                        {isUploading ? "Uploading..." : "Change Avatar"}
                      </div>
                      <Input
                        id="avatar-upload"
                        type="file"
                        accept="image/*"
                        className="sr-only"
                        onChange={handleAvatarChange}
                        disabled={isUploading}
                      />
                    </Label>
                  </div>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="display_name">Display Name</Label>
                  <Input
                    id="display_name"
                    placeholder="Display Name"
                    value={user.display_name}
                    onChange={(e) => setUser((prev) => ({ ...prev, display_name: e.target.value }))}
                  />
                </div>
                <Button type="submit">Save Changes</Button>
              </div>
            </form>
          </CardContent>
        </Card>
       {/*} <Card>
          <CardHeader>
            <CardTitle>Account Activity</CardTitle>
            <CardDescription>View your recent account activity.</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <div>
                  <p className="font-medium">Last login</p>
                  <p className="text-sm text-muted-foreground">May 15, 2023 at 2:30 PM</p>
                </div>
                <Button variant="outline">View All Activity</Button>
              </div>
            </div>
          </CardContent>
        </Card>*/}
      </div>
    </div>
  );

}
