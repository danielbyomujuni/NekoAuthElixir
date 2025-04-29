import { ApolloClient, InMemoryCache, HttpLink, ApolloLink } from "@apollo/client"
import Cookies from 'js-cookie';

function getAuthTokenFromCookie() {
  return Cookies.get('portal_access_token')
}

export default function create_client() {
  const authLink = new ApolloLink((operation, forward) => {
    const token = getAuthTokenFromCookie()

    console.log("Token: ", token)

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
    useGETForQueries: true,
    credentials: "include" // keep this if backend needs cookies for other reasons
  })

  return new ApolloClient({
    link: authLink.concat(httpLink),
    cache: new InMemoryCache()
  })
}
