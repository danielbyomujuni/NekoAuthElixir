import { ApolloClient, InMemoryCache, HttpLink, ApolloLink, gql } from "@apollo/client"
import Cookies from 'js-cookie';

const typeDefs = gql`
  scalar DateTime

  type Service {
    id: ID!
    name: String!
    description: String!
    url: String!
    iconUrl: String
    createdAt: DateTime!
    updatedAt: DateTime!
    redirectUris: [String!]!
    scopes: [String!]!
    applicationType: String!
    status: Boolean!
    emailRestrictionType: String!
    restrictedEmails: [String!]!
    ownerEmail: String!
    plainClientSecret: String
  }

  input CreateServiceInput {
    name: String!
    description: String!
    url: String!
    iconUrl: String
    redirectUris: [String!]!
    scopes: [String!]!
    applicationType: String!
    status: Boolean!
    emailRestrictionType: String!
    restrictedEmails: [String!]!
  }

  type Mutation {
    createService(input: CreateServiceInput!): Service!
  }
`;

function getAuthTokenFromCookie() {
  return Cookies.get('portal_access_token')
}

export default function create_client() {
  const authLink = new ApolloLink((operation, forward) => {
    const token = getAuthTokenFromCookie()
    operation.setContext(({ headers = {} }) => ({
      headers: {
        ...headers,
        Authorization: token ? `Bearer ${token}` : ""
      }
    }))

    return forward(operation)
  })

  const httpLink = new HttpLink({
    uri: "http://localhost:4050/api/graphql",
    credentials: "include" // keep this if backend needs cookies for other reasons
  })

  return new ApolloClient({
    typeDefs,
    link: authLink.concat(httpLink),
    cache: new InMemoryCache()
  })
}
