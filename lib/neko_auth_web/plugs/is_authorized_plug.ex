defmodule NekoAuthWeb.Plugs.IsAuthorizedPlug do
  import Plug.Conn
  import Phoenix.Controller

  alias NekoAuth.User.UserManager

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_cookies(conn)
    with {:ok, _user} <- verify_access_token(conn.cookies["portal_access_token"]) do
      IO.puts("Access token is valid")
      conn
    else
      _ ->
        with {:ok, user} <- verify_refresh_token(conn.cookies["portal_refresh_token"]),
             new_token <- UserManager.create_access_token(user) do
              #IO.puts("Refresh token is valid")
          conn
          |> put_resp_cookie("portal_access_token", new_token, http_only: true)
        else
          _ ->
            IO.puts("FAILED")
            conn
            |> redirect(to: "/")
            |> halt()
        end
    end
  end

  defp verify_access_token(nil), do: {:error, :unauthorized}
  defp verify_access_token(token), do: UserManager.user_from_refresh_token(token)

  defp verify_refresh_token(nil), do: {:error, :unauthorized}
  defp verify_refresh_token(token), do: UserManager.user_from_refresh_token(token)
end
