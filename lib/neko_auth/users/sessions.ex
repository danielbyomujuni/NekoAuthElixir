defmodule NekoAuth.Users.Sessions do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sessions" do
    belongs_to :user, NekoAuth.Users.User

    field :disabled_at, :utc_datetime
    field :code, :string
    field :code_used_at, :utc_datetime
    field :code_challenge, :string
    field :code_method, :string
    field :session_token, :string

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id, :inserted_at, :disabled_at, :code, :code_used_at, :code_challenge, :code_method, :session_token])
    |> validate_required([:user_id, :code])
    |> unique_constraint(:code)
  end
end
