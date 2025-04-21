defmodule NekoAuth.User.UserManager do
  @moduledoc """
  Manager module for registering and managing user accounts.
  """

  alias NekoAuth.Users.User
  alias NekoAuth.Domains.UserDomain
  alias NekoAuth.Repo
  alias Result
  alias RegistrationStruct
  alias Joken.Signer

  @access_token_ttl 15 * 60        # 15 minutes
  @refresh_token_ttl 60 * 60 * 24  # 1 day
  @issuer "neko_auth"

  defp signer, do: TokenSigner.load_private_key()


  @doc """
  Registers a new user from validated registration data.

  Returns `{:ok, %User{}}` or `{:error, reason}`.
  """
  def register_new_user(%RegistrationStruct{} = new_user_data) do
    with true <- UserDomain.is_registration_valid?(new_user_data),
         false <- UserDomain.user_exists?(new_user_data.email),
         {:ok, discriminator} <- UserDomain.request_next_discriminator(new_user_data.user_name),
         IO.puts("Discriminator: #{discriminator}"),
         password_hash <- UserDomain.hash_password(new_user_data.password),
         IO.puts("Password: #{password_hash}"),
         user_attrs = %{
           email: new_user_data.email,
           display_name: new_user_data.display_name,
           user_name: new_user_data.user_name,
           descriminator: discriminator,
           password_hash: password_hash,
           date_of_birth: new_user_data.date_of_birth,
           email_verified: false
         },
         changeset = User.changeset(%User{}, user_attrs),
         {:ok, user} <- Repo.insert(changeset)
    do
      Result.from(user)
    else
      false -> Result.err("Invalid User Domain")
      true -> Result.err("User Already Exists")
      {:error, reason} -> Result.err("Database Error #{reason}")
      _ -> Result.err("Unexpected Error")
    end
  end

  @doc """
  Authenticates a user using email and password.

  Returns `{:ok, %User{}}` or `{:error, reason}`.
  """
  def user_from_login(email, password) do
    with {:ok, user} <- UserDomain.get_user_by_email(email),
         true <- UserDomain.password_matches?(user.password_hash, password) do
      Result.from(user)
    else
      {:error, _} -> Result.err("User not found")
      false -> Result.err("Invalid password")
    end
  end

  def create_access_token(%User{} = user) do
    claims = %{
      "sub" => user.email,
      "scope" => "openid profile",
      "exp" => current_time() + @access_token_ttl,
      "iss" => @issuer
    }

    Joken.generate_and_sign(claims, signer())
  end

  def create_refresh_token(%User{} = user) do
    claims = %{
      "sub" => user.email,
      "exp" => current_time() + @refresh_token_ttl,
      "iss" => @issuer
    }

    Joken.generate_and_sign(claims, signer())
  end

  def create_id_token(%User{} = user, nonce \\ nil) do
    claims = %{
      "sub" => user.email,
      "name" => user.display_name,
      "preferred_username" => user.user_name,
      "discriminator" => user.descriminator,
      "iss" => @issuer,
      "exp" => current_time() + @access_token_ttl
    }
    |> maybe_put("nonce", nonce)

    Joken.generate_and_sign(claims, signer())
  end

  defp current_time, do: DateTime.utc_now() |> DateTime.to_unix()

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, val), do: Map.put(map, key, val)

end
