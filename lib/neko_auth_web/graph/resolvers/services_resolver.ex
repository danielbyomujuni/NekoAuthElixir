defmodule NekoAuthWeb.Graph.Resolvers.ServiceResolver do
  alias NekoAuth.Model.Services
  alias NekoAuth.Repo

  import Ecto.Query
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
        {:ok, Map.put(service, :plain_client_secret, secret)}

      {:error, changeset} ->
        {:error, "Could not create service: #{inspect(changeset.errors)}"}
    end
  end

  def create_service(_parent, _args, _ctx) do
    {:error, "Forbidden"}
  end

  def get_services(_parent, _args, %{context: %{current_user: current_user}}) do
    case Repo.all(from s in Services, where: s.owner_email == ^current_user.email) do
      [] ->
        {:error, "No services found for user #{current_user.email}"}

      services ->
        formatted_services =
          Enum.map(services, fn service ->
            %{
              service
              | id: service.id
                # Add other binary fields that need conversion here
            }
          end)

        {:ok, formatted_services}
    end
  end

  def get_services(_parent, _args, _ctx) do
    {:error, "Forbidden"}
  end

  def delete_service(_parent, %{id: id},  %{context: %{current_user: current_user}}) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         %Services{} = record <- Repo.get(Services, uuid) do
          if record.owner_email == current_user.email do
            Repo.delete(record)
          else
            {:error, "Could not delete"}
         end
      {:ok, record}
    else
      nil -> {:error, "Record not found"}
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Could not delete"}
    end
  end

  def delete_service(_parent, _args, _ctx) do
    {:error, "Forbidden"}
  end

  def update_service(_parent, args, %{context: %{current_user: current_user}}) do
    IO.inspect("updating service")

    case Repo.get(Services, args.id) do
      nil ->
        {:error, "Service not found"}

      %Services{owner_email: owner_email} = service ->
        if owner_email == current_user.email do
          now = DateTime.utc_now() |> DateTime.truncate(:second)

          # Check if client_secret is true in the input
          {params, plain_secret} =
            if Map.get(args, :client_secret) == true do
              # Generate and hash a new secret
              secret = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
              hashed_secret = hash_pwd_salt(secret)

              {
                args
                |> Map.put(:client_secret, hashed_secret)
                |> Map.put(:updated_at, now),
                secret
              }
            else
              {
                args
                |> Map.put(:updated_at, now),
                nil
              }
            end

          changeset = Services.changeset(service, params)

          case Repo.update(changeset) do
            {:ok, updated_service} ->
              # If a new secret was generated, return it in the response
              result =
                if plain_secret do
                  Map.put(updated_service, :plain_client_secret, plain_secret)
                else
                  updated_service
                end

              {:ok, result}

            {:error, changeset} ->
              {:error, "Could not update service: #{inspect(changeset.errors)}"}
          end
        else
          {:error, "You are not authorized to update this service."}
        end
    end
  end

  def update_service(_parent, _args, _ctx) do
    {:error, "Forbidden"}
  end



end
