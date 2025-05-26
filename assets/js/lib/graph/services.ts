import { gql } from "@apollo/client"
import create_client from "../apollo"

export interface OAuthService {
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

const CREATE_SERVICE_MUTATION = gql`
  mutation CreateService($input: CreateServiceInput!) {
    createService(input: $input) {
      id
      name
      plainClientSecret: plain_client_secret
      ownerEmail
    }
  }
`

export async function createService(input: {
  name: string
  description: string
  redirectUris: string[]
  scopes: string[]
  applicationType: string
  status: boolean
  emailRestrictionType: "none" | "whitelist" | "blacklist"
  restrictedEmails: string[]
}) {
  const processed_input = { ...input, url: "n/a", iconUrl: "n/a" }

  const variables = {
    input: processed_input
  }

  return await create_client().mutate({
    mutation: CREATE_SERVICE_MUTATION,
    variables: variables
  })
}


export async function getServices(): Promise<OAuthService[]> {
  return []
}
