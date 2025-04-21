defmodule NekoAuthWeb.OAuthController do
  use Phoenix.Controller, formats: [:json]

  def authorize(conn, _params) do
    quote = %{quote: "Test"}
    json(conn, quote)
  end
end
