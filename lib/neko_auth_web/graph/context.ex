defmodule NekoAuth.Context do
  @behaviour Plug

  import Plug.Conn

  alias NekoAuth.User.UserManager

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the current user context based on the authorization header
  """
  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
    {:ok, current_user} <- authorize(token) do
      %{current_user: current_user}
    else
      _ -> %{}
    end
  end

  defp authorize(token) do
    with {:ok, user} <- UserManager.user_from_access_token(token) do
      {:ok, user}
    else
      _ -> {:error, "Unauthorized"}
    end
  end

end
