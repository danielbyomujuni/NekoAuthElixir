defmodule NekoAuthWeb.Graph.Resolvers.ServiceResolver do
  alias NekoAuth.Model.Services
  alias NekoAuth.Repo

  # You may want to use Argon2 or Pbkdf2 instead of Bcrypt
  # For Bcrypt:
  # Add {:bcrypt_elixir, "~> 3.0"} to your mix.exs
  import Bcrypt, only: [hash_pwd_salt: 1]

  def create_service(_parent, args, %{context: %{current_user: current_user}}) do
    IO.inspect("created service")
    # 1. Generate a random secret
    secret = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

    # 2. Hash the secret
    hashed_secret = hash_pwd_salt(secret)

    # 3. Prepare the service params
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    params =
      args.input
      |> Map.put(:client_secret, hashed_secret)
      |> Map.put(:owner_email, current_user.email)
      |> Map.put(:created_at, now)
      |> Map.put(:updated_at, now)

    # 4. Create the service
    changeset = Services.changeset(%Services{}, params)

    case Repo.insert(changeset) do
      {:ok, service} ->
        # Return the service and the plain secret
        {:ok, Map.put(service, :plain_client_secret, secret)}

      {:error, changeset} ->
        {:error, "Could not create service: #{inspect(changeset.errors)}"}
    end
  end
end
