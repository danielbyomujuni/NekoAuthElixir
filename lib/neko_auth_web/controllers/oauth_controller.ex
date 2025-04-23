defmodule NekoAuthWeb.OAuthController do
  use Phoenix.Controller, formats: [:json]

  alias NekoAuth.User.UserManager
  alias AuthorizeDomain
  alias Result

  @token_type "Bearer"
  @expires_in 3600

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

      # TODO VALIDATE THE SERVICE ID
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

  def token(conn, params) do
    with {:ok, params} <- params |> validate_grant_type() do
      route_grant_type(conn, params)
    else
      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{error: "invalid_request", error_description: reason})
    end
  end

  defp validate_grant_type(%{"grant_type" => gt} = params)
       when gt in ["authorization_code", "refresh_token"] do
    {:ok, params}
  end

  defp validate_grant_type(_), do: {:error, "Invalid Grant Type"}

  defp route_grant_type(conn, %{"grant_type" => "authorization_code"} = params),
    do: handle_authorization_code_grant(conn, params)

  defp route_grant_type(conn, %{"grant_type" => "refresh_token"} = params),
    do: handle_refresh_token_grant(conn, params)

  defp handle_authorization_code_grant(conn, %{"code" => code} = _params) do
    with {:ok, user} <- UserManager.user_from_auth_code(code),
         access_token <- UserManager.create_access_token(user),
         id_token <- UserManager.create_id_token(user, nil),
         refresh_token <- UserManager.create_refresh_token(user) do
      json(conn, %{
        access_token: access_token,
        token_type: @token_type,
        expires_in: @expires_in,
        refresh_token: refresh_token,
        id_token: id_token
      })
    else
      {:error, response } -> error_response(conn, "[T104] #{response}")
    end
  end

  defp handle_authorization_code_grant(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "invalid_request", error_description: "[T101] Empty Token"})
  end

  defp handle_refresh_token_grant(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, user} <- UserManager.user_from_refresh_token(refresh_token),
         access_token <- UserManager.create_access_token(user) do
      conn = fetch_cookies(conn)
      if Map.get(conn.cookies, "local_refresh_token") == refresh_token do
        put_resp_cookie(conn, "local_access_token", access_token, http_only: true)
      else
        conn
      end

      json(conn, %{
        access_token: access_token,
        token_type: @token_type,
        expires_in: @expires_in,
        refresh_token: refresh_token
      })
    else
      {:error, :invalid_user} -> error_response(conn, "[T102] Invalid USER")
      {:error, :invalid_session} -> error_response(conn, "[T103] Invalid User Session")
      {:error, :invalid_token} -> error_response(conn, "[T104] Invalid Token")
    end
  end

  defp handle_refresh_token_grant(conn, _), do: error_response(conn, "[T101] Empty Token")

  defp error_response(conn, message) do
    conn
    |> put_status(400)
    |> json(%{error: "invalid_request", error_description: message})
  end
end
