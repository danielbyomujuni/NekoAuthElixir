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
    ownerEmail
  }
}
`;

export async function createService() {

  const variables = {
    input: {
      name: "My App",
      description: "A test app",
      url: "https://myapp.com",
      iconUrl: "https://myapp.com/icon.png",
      redirectUris: ["https://myapp.com/callback"],
      scopes: ["read", "write"],
      applicationType: "web",
      status: true,
      emailRestrictionType: "none",
      restrictedEmails: []
    }
  };
    
        return await create_client()
          .mutate({
            mutation: CREATE_SERVICE_MUTATION,
            variables: variables
          })
}
