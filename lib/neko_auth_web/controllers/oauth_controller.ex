defmodule NekoAuthWeb.OAuthController do
  use Phoenix.Controller, formats: [:json]

  alias AuthorizeDomain
  alias Result

  @doc """
  Handles GET /api/v2/authorize requests.

  If parameters are valid, redirects user to login page with original params attached.
  If parameters are invalid, returns 400 with an error message.
  """
  def authorize(conn, %{"response_type" => _} = query_params) do
    case AuthorizeDomain.from_object(query_params) do
      {:ok, domain} ->
        login_url =
          domain
          |> AuthorizeDomain.create_url("#{System.get_env("HOST_NAME")}/login")

        conn
        |> put_resp_header("location", login_url)
        |> send_resp(302, "Redirecting to authorization page...")

      #TODO VALIDATE THE SERVICE ID
      {:error, _reason} ->
        conn
        |> put_status(400)
        |> json(%{error: "Invalid request"})
    end
  end

  def authorize(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "Missing required parameters"})
  end
end
