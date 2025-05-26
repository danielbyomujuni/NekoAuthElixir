defmodule NekoAuth.Graph.Resolver do
alias NekoAuth.Users.User

  def list_users(_parent, _args, %{context: %{current_user: current_user}}) do
    {:ok, NekoAuth.Repo.get(User, current_user.email)}
  end

  def list_users(_parent, _args, ctx) do
    #IO.inspect(ctx)
    {:error, "Forbidden"}
  end


  def update_user(_parent, args, %{context: %{current_user: current_user}}) do
    user = NekoAuth.Repo.get_by!(User, email: current_user.email)

    changeset = User.changeset(user, args)

    IO.inspect(args)

    case NekoAuth.Repo.update(changeset) do
      {:ok, updated_user} -> {:ok, updated_user}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_user(_parent, _args, _resolution) do
    {:error, "Access denied"}
  end
end
