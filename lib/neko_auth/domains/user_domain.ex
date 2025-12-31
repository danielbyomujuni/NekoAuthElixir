defmodule NekoAuth.Domains.UserDomain do
  @moduledoc """
  Handles business logic for users: validation, discriminator assignment, password hashing, and user lookups.
  """

  alias NekoAuth.Users.User
  alias NekoAuth.Repo
  alias RegistrationStruct
  alias Result
  alias DomainValidator
  import Ecto.Query, only: [from: 2]

  @min_age 15

  @doc """
  Validates a RegistrationStruct using domain-specific rules.
  """
def is_registration_valid?(%RegistrationStruct{} = data) do
  with {:ok, _} <- validate_email(data.email),
       {:ok, _} <- validate_display_name(data.display_name),
       {:ok, _} <- validate_user_name(data.user_name),
       {:ok, _} <- validate_password(data.password),
       {:ok, _} <- validate_password_confirmation(data.password, data.password_confirmation),
       {:ok, _} <- validate_date_of_birth(data.date_of_birth) do
    {:ok, data}
  else
    error -> error
  end
end

defp validate_email(email) do
  case DomainValidator.new(String.trim(email || ""))
       |> DomainValidator.validate(
         min_length: 5,
         max_length: 65,
         nullable: false,
         regex: "^[\\w\\-.]+@([\\w-]+\\.)+[\\w-]{2,4}$"
       ) do
    true -> {:ok, :email}
    false -> {:error, :email}
  end
end

defp validate_display_name(display_name) do
  case DomainValidator.new(String.trim(display_name || ""))
       |> DomainValidator.validate(min_length: 5, max_length: 50, nullable: false) do
    true -> {:ok, :display_name}
    false -> {:error, :display_name}
  end
end

defp validate_user_name(user_name) do
  case DomainValidator.new(String.trim(user_name || ""))
       |> DomainValidator.validate(min_length: 5, max_length: 50, nullable: false) do
    true -> {:ok, :user_name}
    false -> {:error, :user_name}
  end
end

defp validate_password(password) do
  case DomainValidator.new(String.trim(password || ""))
       |> DomainValidator.validate(
         min_length: 8,
         max_length: 50,
         nullable: false,
         regex: ~s/^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[#?!@$%^&*-]).+$/
       ) do
    true -> {:ok, :password}
    false -> {:error, :password}
  end
end

defp validate_password_confirmation(password, password_confirmation) do
  case password == String.trim(password_confirmation || "") do
    true -> {:ok, :password_confirmation}
    false -> {:error, :password_confirmation}
  end
end

defp validate_date_of_birth(date_of_birth) do
  case DomainValidator.new(date_of_birth)
       |> DomainValidator.validate(max_value: latest_birth_date(), nullable: false) do
    true -> {:ok, :date_of_birth}
    false -> {:error, :date_of_birth}
  end
end

  defp latest_birth_date do
    today = Date.utc_today()
    Date.add(today, -@min_age * 365)
  end

  @spec user_exists?(any()) :: boolean()
  @doc """
  Checks if a user with the given email already exists.
  """
  def user_exists?(email) do
    import Ecto.Query, only: [from: 2]
    NekoAuth.Repo.exists?(from(u in User, where: u.email == ^email))
  end

  @spec request_next_discriminator(any()) :: {:error, any()} | {:ok, any()}
  @doc """
  Returns the next available discriminator for a username.
  """
  def request_next_discriminator(user_name) do
    max = Repo.one(
      from u in User,
      where: u.user_name == ^user_name,
      select: max(u.descriminator)
    ) || 0

    max = if max < 10, do: 9, else: max

    if max >= 9999 do
      Result.err("Max Discriminator Reached")
    else
      Result.from(max + 1)
    end
  end

  @doc """
  Returns a bcrypt-hashed password.
  """
  def hash_password(password) do
    rounds =
      System.get_env("SALT_ROUNDS")
      |> case do
        nil -> raise "ENV VAR SALT_ROUNDS NOT SET"
        str -> String.to_integer(str)
      end

    Bcrypt.hash_pwd_salt(password, log_rounds: rounds)
  end

  @doc """
  Compares a raw password to a hashed one.
  """
  def password_matches?(password_hash, password) do
    Bcrypt.verify_pass(password, password_hash || "")
  end

  @doc """
  Loads a user and associated sessions by email.
  """
  def get_user_by_email(email) do
    user =
      Repo.get(User, email)

    case user do
      nil -> Result.err("User not found")
      _ -> Result.from(user)
    end
  end

  @doc """
  Loads a user by authentication code (from sessions).
  """
  def get_user_by_auth_code(code) do
    user =
      from(u in User,
        join: s in assoc(u, :sessions),
        where: s.code == ^code,
        preload: [sessions: s]
      )
      |> Repo.one()

    case user do
      nil -> Result.err("Invalid code")
      _ -> Result.from(user)
    end
  end
end
