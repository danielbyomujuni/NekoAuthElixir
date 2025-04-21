import { ApolloClient, InMemoryCache } from "@apollo/client"

const client = new ApolloClient({
  uri: "/api",
  cache: new InMemoryCache(),
  defaultOptions: {
    // Disable caching for test app
    watchQuery: {
      fetchPolicy: "no-cache",
      errorPolicy: "ignore"
    },
    query: {
      fetchPolicy: "no-cache",
      errorPolicy: "none"
    }
  }
})

export type ApiClient = typeof client

export function getGqlClient() {
  return client
}
