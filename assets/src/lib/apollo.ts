import { ApolloClient, InMemoryCache, HttpLink, ApolloLink } from "@apollo/client"
import Cookies from 'js-cookie';

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
    uri: new URL('/api/graphql', import.meta.env.BASE_URL).href,
    credentials: "include" // keep this if backend needs cookies for other reasons
  })

  return new ApolloClient({
    //typeDefs,
    link: authLink.concat(httpLink),
    cache: new InMemoryCache()
  })
}

export async function runWithTokens<T>(fun: () => Promise<T>): Promise<T> {
    try {
      return await fun();
    } catch (error) {
      console.error("Error occurred:", error);
      const res = await fetch(`${import.meta.env.BASE_URL}api/v1/oauth/token?` + new URLSearchParams({
        grant_type: "refresh_token",
        refresh_token: Cookies.get('portal_refresh_token') || ""
    }), { method: "POST", credentials: "include" });

      if (res.status === 200) {
        const data = await res.json();
        Cookies.set('portal_access_token', data.access_token);
        Cookies.set('portal_refresh_token', data.refresh_token);
        return await fun();
      }
      throw new Error("Failed to refresh token");
    }
}