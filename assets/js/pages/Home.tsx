import React, { useEffect, useState } from "react"
import { getRandomWidget, RandomWidgetQuery } from "../api/widget"
import { getGqlClient } from "../api"

export function Home() {
  const [num, setNum] = useState(0)
  const [widget, setWidget] = useState<RandomWidgetQuery>()

  useEffect(() => {
    const interval = setInterval(() => {
      setNum((c) => c + 1)
      getRandomWidget(getGqlClient()).then(setWidget)
    }, 1000)

    return () => {
      clearInterval(interval)
    }
  })

  return (
    <div>
      <div>Home Page {num}</div>
      {widget && (
        <div>
          <span className="font-semibold">Data fetched via GraphQL:</span> <span>{widget.randomWidget.id}</span>
        </div>
      )}
    </div>
  )
}
