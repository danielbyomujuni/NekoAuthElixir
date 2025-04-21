defmodule NekoAuth.User.UserManager do
  @moduledoc """
  Manager module for registering and managing user accounts.
  """

  alias NekoAuth.Users.User
  alias NekoAuth.Domains.UserDomain
  alias NekoAuth.Repo
  alias Result
  alias RegistrationStruct

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
end
