defmodule NekoAuth.User.UserManager do
  @moduledoc """
  Manager module for registering and managing user accounts.
  """
  @behaviour NekoAuth.UserManagerBehavior

  import Ecto.Query

  alias NekoAuth.Users.User
  alias NekoAuth.Domains.UserDomain
  alias NekoAuth.Repo
  alias Result
  alias RegistrationStruct
  alias Base
  alias NekoAuth.Users.Sessions

  # 15 minutes
  @access_token_ttl 15 * 60
  # 1 day
  @refresh_token_ttl 30 * 60 * 60 * 24
  # 1 minute
  @auth_code_ttl 1 * 60
  @issuer "https://auth.nekosyndicate.com"

  @spec register_new_user(%RegistrationStruct{
          email: false | nil | binary(),
          display_name: binary(),
          user_name: binary(),
          password: binary(),
          date_of_birth: Date.t()
        }) :: {:error, any()} | {:ok, any()}

  def signer do
    Path.join(:code.priv_dir(:neko_auth), "keys/private_key.pem")
    |> JOSE.JWK.from_pem_file()
  end

  @doc """
  Registers a new user from validated registration data.

  Returns `{:ok, %User{}}` or `{:error, reason}`.
  """
  def register_new_user(%RegistrationStruct{} = new_user_data) do
    with {:ok, _} <- UserDomain.is_registration_valid?(new_user_data),
         false <- UserDomain.user_exists?(new_user_data.email),
         {:ok, discriminator} <- UserDomain.request_next_discriminator(new_user_data.user_name),
         # IO.puts("Discriminator: #{discriminator}"),
         password_hash <- UserDomain.hash_password(new_user_data.password),
         # IO.puts("Password: #{password_hash}"),
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
         {:ok, user} <- Repo.insert(changeset) do
      Result.from(user)
    else
      false -> Result.err("Invalid User Domain")
      true -> Result.err("User Already Exists")
      {:error, reason} -> Result.err("Registration Error #{reason}")
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
      "aud" => "1",
      "iat" => current_time(),
      "scope" => "openid profile",
      "exp" => current_time() + @access_token_ttl,
      "iss" => @issuer
    }

    JOSE.JWT.sign(signer(), %{"alg" => "RS256"}, claims) |> JOSE.JWS.compact() |> elem(1)
  end

  def user_from_access_token(token) do
    key = signer()
      |> JOSE.JWK.to_public()
    with {true, jwt, _} <- JOSE.JWT.verify(key, {%{alg: :jose_jws_alg_rsa_pkcs1_v1_5}, token}),
        {%{}, %{"sub" => email, "exp" => exp}} <- JOSE.JWT.to_map(jwt),
         true <- current_time() < exp,
         {:ok, user} <- UserDomain.get_user_by_email(email) do
        {:ok, user}
    else
      _ -> {:error, :invalid_token}
    end
  end

  @spec create_refresh_token(any()) :: none()
  def create_refresh_token(%User{} = user) do
    claims = %{
      "sub" => user.email,
      "aud" => "1",
      "iat" => current_time(),
      "exp" => current_time() + @refresh_token_ttl,
      "iss" => @issuer
    }

    JOSE.JWT.sign(signer(), %{"alg" => "RS256"}, claims) |> JOSE.JWS.compact() |> elem(1)
  end

  def user_from_refresh_token(token) do
    key = signer()
      |> JOSE.JWK.to_public()
    with {true, jwt, _} <- JOSE.JWT.verify(key, {%{alg: :jose_jws_alg_rsa_pkcs1_v1_5}, token}),
        {%{}, %{"sub" => email, "exp" => exp}} <- JOSE.JWT.to_map(jwt),
         true <- current_time() < exp,
         {:ok, user} <- UserDomain.get_user_by_email(email) do
        {:ok, user}
    else
      _ -> {:error, :invalid_token}
    end
  end

  def create_id_token(%User{} = user, nonce \\ nil) do
    claims =
      %{
        "sub" => user.email,
        "aud" => "1",
        "email" => user.email,
        "email_verified" => user.email_verified || false,
        "user_name" => user.user_name,
        "descriminator" => user.descriminator,
        "avatar" => "#{System.get_env("HOST_NAME")}/api/v1/avatars/#{user.user_name}/#{user.descriminator}",
        "display_name" => user.display_name,
        "iss" => @issuer,
        "iat" => current_time(),
        "exp" => current_time() + @access_token_ttl
      }
      |> maybe_put("nonce", nonce)

    JOSE.JWT.sign(signer(), %{"alg" => "RS256"}, claims) |> JOSE.JWS.compact() |> elem(1)
  end

  def generate_auth_code(%User{} = user, %AuthorizeDomain{} = auth_domain) do
    code = :crypto.strong_rand_bytes(16)
      |> Base.url_encode64(padding: false)
    %Sessions{}
    |> Sessions.changeset(%{
        user_id: user.id,
        code: code,
        code_challenge: auth_domain.code_challenge,
        code_method: auth_domain.code_challenge_method
      })
      |> Repo.insert!()

    code
  end

  def user_from_auth_code(code, code_verifier) do
      from(
      s in Sessions,
      where: s.code == ^code,
      join: u in User,
      on: s.user_id == u.id,
      preload: [user: u]
      )
    |> Repo.one()
    |> case do
      %{id: id, code_used_at: nil, code_method: "S256", code_challenge: code_challenge, user: user} ->
        hashed_code = :crypto.hash(:sha256, code_verifier) |> Base.url_encode64(padding: false)
        if hashed_code == code_challenge do
          from(s in Sessions, where: s.id == ^id, update: [set: [code_used_at: ^DateTime.utc_now()]])
          |> Repo.update_all([])

          {:ok, user}
        else
          {:error, :challenge_failed}
        end
      %{id: id, code_used_at: nil, code_method: "plain", code_challenge: code_challenge, user: user} ->
        if code_verifier == code_challenge do
          from(s in Sessions, where: s.id == ^id, update: [set: [code_used_at: ^DateTime.utc_now()]])
          |> Repo.update_all([])

          {:ok, user}
        else
          {:error, :challenge_failed}
        end
      %{id: id, code_used_at: nil, code_method: nil, user: user} ->
        from(s in Sessions, where: s.id == ^id, update: [set: [code_used_at: ^DateTime.utc_now()]])
          |> Repo.update_all([])

        {:ok, user}
      _ -> {:error, :invalid_session}
    end
  end

  defp current_time, do: DateTime.utc_now() |> DateTime.to_unix()

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, val), do: Map.put(map, key, val)
end
