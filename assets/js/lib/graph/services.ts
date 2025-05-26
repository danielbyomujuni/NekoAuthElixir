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

const GET_SERVICES_QUERY = gql`
{
            services {
              dateOfBirth
              descriminator
              displayName
              email
              emailVerified
              userName
            }
          }
`


export async function getServices() {
    
        return await create_client()
          .query({
            query: GET_SERVICES_QUERY,
            variables: undefined
          })
}