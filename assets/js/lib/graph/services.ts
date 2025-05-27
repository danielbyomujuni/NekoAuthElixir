import { gql } from "@apollo/client"
import create_client, { runWithTokens } from "../apollo"

export interface OAuthService {
  id: string
  name: string
  clientSecret?: string
  secretGenerated: boolean
  description: string
  redirectUris: string[]
  scopes: string[]
  applicationType: string
  status: boolean
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
}): Promise<{
  id: string
  plainClientSecret: string
}> {
  return await runWithTokens(async () => {
    const processed_input = { ...input, url: "n/a", iconUrl: "n/a" }

    const variables = {
      input: processed_input
    }
    return (
      await create_client().mutate({
        mutation: CREATE_SERVICE_MUTATION,
        variables: variables
      })
    ).data.createService
  })
}

const GET_SERVICES_QUERY = gql`
  {
    services {
      id
      name
      description
      redirectUris
      scopes
      applicationType
      status
      emailRestrictionType
      restrictedEmails
      createdAt
    }
  }
`

export async function getServices(): Promise<OAuthService[]> {
  return await runWithTokens(async () => {
    const res = await create_client().query({
      query: GET_SERVICES_QUERY,
      variables: undefined
    })
    return (res.data.services as OAuthService[]) || []
  })
}

const DELETE_SERVICE_MUTATION = gql`
  mutation DeleteService($id: ID!) {
    deleteService(id: $id) {
      id
    }
  }
`

export async function deleteService(id: string): Promise<{ id: string }> {
  return await runWithTokens(async () => {
    const variables = {
      id
    }
    return (
      await create_client().mutate({
        mutation: DELETE_SERVICE_MUTATION,
        variables: variables
      })
    ).data
  })
}
export async function generateNewServiceSecret(id: string) {
  const query = gql`
    mutation UpdateService($id: ID!) {
      updateService(id: $id, clientSecret: true) {
        id
        plainClientSecret
      }
    }
  `

  return await runWithTokens(async () => {
    const variables = {
      id
    }
    return (
      await create_client().mutate({
        mutation: query,
        variables: variables
      })
    ).data.updateService.plainClientSecret
  })
}
