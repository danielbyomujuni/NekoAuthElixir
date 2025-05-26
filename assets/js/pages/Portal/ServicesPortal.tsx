"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Checkbox } from "@/components/ui/checkbox"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Alert, AlertDescription } from "@/components/ui/alert"
import {
  Copy,
  Eye,
  EyeOff,
  MoreHorizontal,
  Plus,
  Settings,
  Trash2,
  AlertTriangle,
  Key,
  Mail,
  Shield,
} from "lucide-react"
import React from "react"

interface OAuthService {
  id: string
  name: string
  clientId: string
  clientSecret?: string
  secretGenerated: boolean
  description: string
  redirectUris: string[]
  scopes: string[]
  applicationType: string
  status: "active" | "inactive"
  emailRestrictionType: "none" | "whitelist" | "blacklist"
  restrictedEmails: string[]
  createdAt: string
}

const mockServices: OAuthService[] = [
  {
    id: "1",
    name: "My Web App",
    clientId: "web_app_client_123",
    secretGenerated: false,
    description: "Main web application for user authentication",
    redirectUris: ["https://myapp.com/callback", "http://localhost:3000/callback"],
    scopes: ["read", "write", "profile"],
    applicationType: "web",
    status: "active",
    emailRestrictionType: "whitelist",
    restrictedEmails: ["admin@myapp.com", "user@myapp.com"],
    createdAt: "2024-01-15",
  },
  {
    id: "2",
    name: "Mobile App",
    clientId: "mobile_client_456",
    secretGenerated: false,
    description: "iOS and Android mobile application",
    redirectUris: ["myapp://callback"],
    scopes: ["read", "profile"],
    applicationType: "mobile",
    status: "active",
    emailRestrictionType: "blacklist",
    restrictedEmails: ["spam@example.com", "test@blocked.com"],
    createdAt: "2024-01-10",
  },
  {
    id: "3",
    name: "Analytics Dashboard",
    clientId: "analytics_789",
    secretGenerated: false,
    description: "Internal analytics and reporting dashboard",
    redirectUris: ["https://analytics.myapp.com/auth"],
    scopes: ["read", "analytics"],
    applicationType: "web",
    status: "inactive",
    emailRestrictionType: "none",
    restrictedEmails: [],
    createdAt: "2024-01-05",
  },
]

const availableScopes = [
  { id: "read", label: "Read", description: "Read access to user data" },
  { id: "write", label: "Write", description: "Write access to user data" },
  { id: "profile", label: "Profile", description: "Access to user profile information" },
  { id: "email", label: "Email", description: "Access to user email address" },
  { id: "analytics", label: "Analytics", description: "Access to analytics data" },
  { id: "admin", label: "Admin", description: "Administrative access" },
]

export default function ServicesPortal() {
  const [services, setServices] = useState<OAuthService[]>(mockServices)
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [editingService, setEditingService] = useState<OAuthService | null>(null)
  const [showSecrets, setShowSecrets] = useState<Record<string, boolean>>({})
  const [newlyGeneratedSecret, setNewlyGeneratedSecret] = useState<{ serviceId: string; secret: string } | null>(null)
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    applicationType: "",
    redirectUris: "",
    scopes: [] as string[],
    emailRestrictionType: "none" as "none" | "whitelist" | "blacklist",
    restrictedEmails: "",
  })

  const resetFormData = () => {
    setFormData({
      name: "",
      description: "",
      applicationType: "",
      redirectUris: "",
      scopes: [],
      emailRestrictionType: "none",
      restrictedEmails: "",
    })
  }

  const populateFormData = (service: OAuthService) => {
    setFormData({
      name: service.name,
      description: service.description,
      applicationType: service.applicationType,
      redirectUris: service.redirectUris.join("\n"),
      scopes: service.scopes,
      emailRestrictionType: service.emailRestrictionType,
      restrictedEmails: service.restrictedEmails.join("\n"),
    })
  }

  const handleCreateService = () => {
    const newService: OAuthService = {
      id: Date.now().toString(),
      name: formData.name,
      clientId: `client_${Date.now()}`,
      secretGenerated: false,
      description: formData.description,
      redirectUris: formData.redirectUris.split("\n").filter((uri) => uri.trim()),
      scopes: formData.scopes,
      applicationType: formData.applicationType,
      status: "active",
      emailRestrictionType: formData.emailRestrictionType,
      restrictedEmails: formData.restrictedEmails.split("\n").filter((email) => email.trim()),
      createdAt: new Date().toISOString().split("T")[0],
    }

    setServices([...services, newService])
    setIsCreateDialogOpen(false)
    resetFormData()
  }

  const handleEditService = () => {
    if (!editingService) return

    const updatedService: OAuthService = {
      ...editingService,
      name: formData.name,
      description: formData.description,
      applicationType: formData.applicationType,
      redirectUris: formData.redirectUris.split("\n").filter((uri) => uri.trim()),
      scopes: formData.scopes,
      emailRestrictionType: formData.emailRestrictionType,
      restrictedEmails: formData.restrictedEmails.split("\n").filter((email) => email.trim()),
    }

    setServices((prev) => prev.map((service) => (service.id === editingService.id ? updatedService : service)))
    setIsEditDialogOpen(false)
    setEditingService(null)
    resetFormData()
  }

  const openEditDialog = (service: OAuthService) => {
    setEditingService(service)
    populateFormData(service)
    setIsEditDialogOpen(true)
  }

  const generateSecret = (serviceId: string) => {
    const newSecret = `secret_${Math.random().toString(36).substring(2)}_${Date.now()}`

    setServices((prev) =>
      prev.map((service) =>
        service.id === serviceId ? { ...service, clientSecret: newSecret, secretGenerated: true } : service,
      ),
    )

    setNewlyGeneratedSecret({ serviceId, secret: newSecret })
    setShowSecrets((prev) => ({ ...prev, [serviceId]: true }))
  }

  const regenerateSecret = (serviceId: string) => {
    const newSecret = `secret_${Math.random().toString(36).substring(2)}_${Date.now()}`

    setServices((prev) =>
      prev.map((service) => (service.id === serviceId ? { ...service, clientSecret: newSecret } : service)),
    )

    setNewlyGeneratedSecret({ serviceId, secret: newSecret })
    setShowSecrets((prev) => ({ ...prev, [serviceId]: true }))
  }

  const toggleSecretVisibility = (serviceId: string) => {
    setShowSecrets((prev) => ({
      ...prev,
      [serviceId]: !prev[serviceId],
    }))
  }

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text)
  }

  const handleScopeChange = (scopeId: string, checked: boolean) => {
    setFormData((prev) => ({
      ...prev,
      scopes: checked ? [...prev.scopes, scopeId] : prev.scopes.filter((s) => s !== scopeId),
    }))
  }

  const deleteService = (serviceId: string) => {
    setServices(services.filter((service) => service.id !== serviceId))
  }

  const dismissSecretWarning = () => {
    setNewlyGeneratedSecret(null)
  }

  const getEmailRestrictionBadge = (service: OAuthService) => {
    if (service.emailRestrictionType === "none") return null

    const variant = service.emailRestrictionType === "whitelist" ? "default" : "destructive"
    const icon =
      service.emailRestrictionType === "whitelist" ? (
        <Shield className="w-3 h-3 mr-1" />
      ) : (
        <Mail className="w-3 h-3 mr-1" />
      )

    return (
      <Badge variant={variant} className="text-xs">
        {icon}
        {service.emailRestrictionType} ({service.restrictedEmails.length})
      </Badge>
    )
  }

  return (
    <div className="container mx-auto py-8 space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">OAuth Services</h1>
          <p className="text-muted-foreground mt-2">Manage your OAuth applications and API credentials</p>
        </div>
        <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              Create Service
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Create OAuth Service</DialogTitle>
              <DialogDescription>
                Create a new OAuth application to enable third-party integrations. You'll need to generate a client
                secret after creation.
              </DialogDescription>
            </DialogHeader>
            <Alert className="mx-6 mt-4">
              <AlertTriangle className="h-4 w-4" />
              <AlertDescription>
                <strong>Note:</strong> After creating your service, you'll need to generate a client secret. The secret
                will only be shown once for security reasons.
              </AlertDescription>
            </Alert>
            <div className="grid gap-6 py-4">
              <div className="grid gap-2">
                <Label htmlFor="name">Application Name</Label>
                <Input
                  id="name"
                  placeholder="My Application"
                  value={formData.name}
                  onChange={(e) => setFormData((prev) => ({ ...prev, name: e.target.value }))}
                />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  placeholder="Describe what this application does..."
                  value={formData.description}
                  onChange={(e) => setFormData((prev) => ({ ...prev, description: e.target.value }))}
                />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="type">Application Type</Label>
                <Select
                  value={formData.applicationType}
                  onValueChange={(value) => setFormData((prev) => ({ ...prev, applicationType: value }))}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select application type" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="web">Web Application</SelectItem>
                    <SelectItem value="mobile">Mobile Application</SelectItem>
                    <SelectItem value="desktop">Desktop Application</SelectItem>
                    <SelectItem value="server">Server-to-Server</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="grid gap-2">
                <Label htmlFor="redirectUris">Redirect URIs</Label>
                <Textarea
                  id="redirectUris"
                  placeholder="https://myapp.com/callback&#10;http://localhost:3000/callback"
                  value={formData.redirectUris}
                  onChange={(e) => setFormData((prev) => ({ ...prev, redirectUris: e.target.value }))}
                  className="min-h-[100px]"
                />
                <p className="text-sm text-muted-foreground">
                  Enter one URI per line. These are the allowed callback URLs for your application.
                </p>
              </div>
              <div className="grid gap-3">
                <Label>Scopes</Label>
                <div className="grid grid-cols-2 gap-3">
                  {availableScopes.map((scope) => (
                    <div key={scope.id} className="flex items-start space-x-2">
                      <Checkbox
                        id={scope.id}
                        checked={formData.scopes.includes(scope.id)}
                        onCheckedChange={(checked) => handleScopeChange(scope.id, checked as boolean)}
                      />
                      <div className="grid gap-1.5 leading-none">
                        <Label
                          htmlFor={scope.id}
                          className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                        >
                          {scope.label}
                        </Label>
                        <p className="text-xs text-muted-foreground">{scope.description}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              <div className="grid gap-3">
                <Label>Email Restrictions</Label>
                <RadioGroup
                  value={formData.emailRestrictionType}
                  onValueChange={(value) =>
                    setFormData((prev) => ({
                      ...prev,
                      emailRestrictionType: value as "none" | "whitelist" | "blacklist",
                    }))
                  }
                >
                  <div className="flex items-center space-x-2">
                    <RadioGroupItem value="none" id="none" />
                    <Label htmlFor="none">No restrictions</Label>
                  </div>
                  <div className="flex items-center space-x-2">
                    <RadioGroupItem value="whitelist" id="whitelist" />
                    <Label htmlFor="whitelist">Whitelist (only allow specific emails)</Label>
                  </div>
                  <div className="flex items-center space-x-2">
                    <RadioGroupItem value="blacklist" id="blacklist" />
                    <Label htmlFor="blacklist">Blacklist (block specific emails)</Label>
                  </div>
                </RadioGroup>
                {formData.emailRestrictionType !== "none" && (
                  <div className="grid gap-2">
                    <Label htmlFor="restrictedEmails">
                      {formData.emailRestrictionType === "whitelist" ? "Allowed Emails" : "Blocked Emails"}
                    </Label>
                    <Textarea
                      id="restrictedEmails"
                      placeholder="user@example.com&#10;admin@company.com"
                      value={formData.restrictedEmails}
                      onChange={(e) => setFormData((prev) => ({ ...prev, restrictedEmails: e.target.value }))}
                      className="min-h-[80px]"
                    />
                    <p className="text-sm text-muted-foreground">
                      Enter one email per line.{" "}
                      {formData.emailRestrictionType === "whitelist"
                        ? "Only these emails will be allowed to authenticate."
                        : "These emails will be blocked from authentication."}
                    </p>
                  </div>
                )}
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsCreateDialogOpen(false)}>
                Cancel
              </Button>
              <Button onClick={handleCreateService} disabled={!formData.name || !formData.applicationType}>
                Create Service
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>

      {/* Edit Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Edit OAuth Service</DialogTitle>
            <DialogDescription>Update your OAuth application settings and configuration.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-6 py-4">
            <div className="grid gap-2">
              <Label htmlFor="edit-name">Application Name</Label>
              <Input
                id="edit-name"
                placeholder="My Application"
                value={formData.name}
                onChange={(e) => setFormData((prev) => ({ ...prev, name: e.target.value }))}
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="edit-description">Description</Label>
              <Textarea
                id="edit-description"
                placeholder="Describe what this application does..."
                value={formData.description}
                onChange={(e) => setFormData((prev) => ({ ...prev, description: e.target.value }))}
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="edit-type">Application Type</Label>
              <Select
                value={formData.applicationType}
                onValueChange={(value) => setFormData((prev) => ({ ...prev, applicationType: value }))}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select application type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="web">Web Application</SelectItem>
                  <SelectItem value="mobile">Mobile Application</SelectItem>
                  <SelectItem value="desktop">Desktop Application</SelectItem>
                  <SelectItem value="server">Server-to-Server</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="grid gap-2">
              <Label htmlFor="edit-redirectUris">Redirect URIs</Label>
              <Textarea
                id="edit-redirectUris"
                placeholder="https://myapp.com/callback&#10;http://localhost:3000/callback"
                value={formData.redirectUris}
                onChange={(e) => setFormData((prev) => ({ ...prev, redirectUris: e.target.value }))}
                className="min-h-[100px]"
              />
              <p className="text-sm text-muted-foreground">
                Enter one URI per line. These are the allowed callback URLs for your application.
              </p>
            </div>
            <div className="grid gap-3">
              <Label>Scopes</Label>
              <div className="grid grid-cols-2 gap-3">
                {availableScopes.map((scope) => (
                  <div key={scope.id} className="flex items-start space-x-2">
                    <Checkbox
                      id={`edit-${scope.id}`}
                      checked={formData.scopes.includes(scope.id)}
                      onCheckedChange={(checked) => handleScopeChange(scope.id, checked as boolean)}
                    />
                    <div className="grid gap-1.5 leading-none">
                      <Label
                        htmlFor={`edit-${scope.id}`}
                        className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                      >
                        {scope.label}
                      </Label>
                      <p className="text-xs text-muted-foreground">{scope.description}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className="grid gap-3">
              <Label>Email Restrictions</Label>
              <RadioGroup
                value={formData.emailRestrictionType}
                onValueChange={(value) =>
                  setFormData((prev) => ({
                    ...prev,
                    emailRestrictionType: value as "none" | "whitelist" | "blacklist",
                  }))
                }
              >
                <div className="flex items-center space-x-2">
                  <RadioGroupItem value="none" id="edit-none" />
                  <Label htmlFor="edit-none">No restrictions</Label>
                </div>
                <div className="flex items-center space-x-2">
                  <RadioGroupItem value="whitelist" id="edit-whitelist" />
                  <Label htmlFor="edit-whitelist">Whitelist (only allow specific emails)</Label>
                </div>
                <div className="flex items-center space-x-2">
                  <RadioGroupItem value="blacklist" id="edit-blacklist" />
                  <Label htmlFor="edit-blacklist">Blacklist (block specific emails)</Label>
                </div>
              </RadioGroup>
              {formData.emailRestrictionType !== "none" && (
                <div className="grid gap-2">
                  <Label htmlFor="edit-restrictedEmails">
                    {formData.emailRestrictionType === "whitelist" ? "Allowed Emails" : "Blocked Emails"}
                  </Label>
                  <Textarea
                    id="edit-restrictedEmails"
                    placeholder="user@example.com&#10;admin@company.com"
                    value={formData.restrictedEmails}
                    onChange={(e) => setFormData((prev) => ({ ...prev, restrictedEmails: e.target.value }))}
                    className="min-h-[80px]"
                  />
                  <p className="text-sm text-muted-foreground">
                    Enter one email per line.{" "}
                    {formData.emailRestrictionType === "whitelist"
                      ? "Only these emails will be allowed to authenticate."
                      : "These emails will be blocked from authentication."}
                  </p>
                </div>
              )}
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsEditDialogOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleEditService} disabled={!formData.name || !formData.applicationType}>
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {newlyGeneratedSecret && (
        <Alert className="border-amber-200 bg-amber-50">
          <AlertTriangle className="h-4 w-4 text-amber-600" />
          <AlertDescription className="text-amber-800">
            <div className="flex items-center justify-between">
              <div>
                <strong>Important:</strong> Copy your client secret now. You won{"'"}t be able to see it again for
                security reasons.
              </div>
              <div className="flex items-center gap-2 ml-4">
                <code className="bg-amber-100 px-2 py-1 rounded text-sm font-mono">{newlyGeneratedSecret.secret}</code>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => copyToClipboard(newlyGeneratedSecret.secret)}
                  className="h-8"
                >
                  <Copy className="h-3 w-3" />
                </Button>
                <Button variant="outline" size="sm" onClick={dismissSecretWarning} className="h-8">
                  Got it
                </Button>
              </div>
            </div>
          </AlertDescription>
        </Alert>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Your OAuth Services</CardTitle>
          <CardDescription>
            {services.length} service{services.length !== 1 ? "s" : ""} configured
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Client ID</TableHead>
                <TableHead>Client Secret</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Scopes</TableHead>
                <TableHead>Email Restrictions</TableHead>
                <TableHead>Created</TableHead>
                <TableHead className="w-[50px]"></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {services.map((service) => (
                <TableRow key={service.id}>
                  <TableCell>
                    <div>
                      <div className="font-medium">{service.name}</div>
                      <div className="text-sm text-muted-foreground">{service.description}</div>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      <code className="text-sm bg-muted px-2 py-1 rounded">{service.clientId}</code>
                      <Button variant="ghost" size="sm" onClick={() => copyToClipboard(service.clientId)}>
                        <Copy className="h-3 w-3" />
                      </Button>
                    </div>
                  </TableCell>
                  <TableCell>
                    {!service.secretGenerated ? (
                      <Button variant="outline" size="sm" onClick={() => generateSecret(service.id)}>
                        <Key className="mr-2 h-3 w-3" />
                        Generate Secret
                      </Button>
                    ) : (
                      <div className="flex items-center gap-2">
                        <code className="text-sm bg-muted px-2 py-1 rounded">
                          {showSecrets[service.id] ? service.clientSecret : "••••••••••••"}
                        </code>
                        <Button variant="ghost" size="sm" onClick={() => toggleSecretVisibility(service.id)}>
                          {showSecrets[service.id] ? <EyeOff className="h-3 w-3" /> : <Eye className="h-3 w-3" />}
                        </Button>
                        {showSecrets[service.id] && (
                          <Button variant="ghost" size="sm" onClick={() => copyToClipboard(service.clientSecret!)}>
                            <Copy className="h-3 w-3" />
                          </Button>
                        )}
                      </div>
                    )}
                  </TableCell>
                  <TableCell>
                    <Badge variant="outline">{service.applicationType}</Badge>
                  </TableCell>
                  <TableCell>
                    <Badge variant={service.status === "active" ? "default" : "secondary"}>{service.status}</Badge>
                  </TableCell>
                  <TableCell>
                    <div className="flex flex-wrap gap-1">
                      {service.scopes.map((scope) => (
                        <Badge key={scope} variant="outline" className="text-xs">
                          {scope}
                        </Badge>
                      ))}
                    </div>
                  </TableCell>
                  <TableCell>{getEmailRestrictionBadge(service)}</TableCell>
                  <TableCell className="text-sm text-muted-foreground">{service.createdAt}</TableCell>
                  <TableCell>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="sm">
                          <MoreHorizontal className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuItem onClick={() => openEditDialog(service)}>
                          <Settings className="mr-2 h-4 w-4" />
                          Edit
                        </DropdownMenuItem>
                        {service.secretGenerated && (
                          <DropdownMenuItem onClick={() => regenerateSecret(service.id)}>
                            <Key className="mr-2 h-4 w-4" />
                            Regenerate Secret
                          </DropdownMenuItem>
                        )}
                        <DropdownMenuItem className="text-destructive" onClick={() => deleteService(service.id)}>
                          <Trash2 className="mr-2 h-4 w-4" />
                          Delete
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  )
}
