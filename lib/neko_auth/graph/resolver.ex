defmodule NekoAuth.Graph.Resolver do
alias NekoAuth.Users.User

  def list_users(_parent, _args, %{context: %{current_user: current_user}}) do
    {:ok, NekoAuth.Repo.get(User, current_user.email)}
  end

  def list_users(_parent, _args, ctx) do
    #IO.inspect(ctx)
    {:error, "Forbidden"}
  end
end
