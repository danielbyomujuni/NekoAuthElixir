defmodule NekoAuth.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:email, :string, []}
  schema "user" do
    field :display_name, :string
    field :user_name, :string
    field :descriminator, :integer
    field :password_hash, :string
    field :date_of_birth, :date
    field :email_verified, :boolean, default: false
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:display_name, :user_name, :descriminator, :password_hash, :date_of_birth, :email_verified])
    |> validate_required([:display_name, :user_name, :descriminator, :password_hash, :date_of_birth, :email_verified])
  end
end
