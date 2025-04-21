import { gql } from "@apollo/client"
import { ApiClient } from "."

export interface RandomWidgetQuery {
  randomWidget: {
    id: string
  }
}

const RANDOM_WIDGET = gql`
  query RandomWidget {
    randomWidget {
      id
    }
  }
`

export async function getRandomWidget(client: ApiClient) {
  const resp = await client.query<RandomWidgetQuery>({ query: RANDOM_WIDGET })
  return resp.data
}
