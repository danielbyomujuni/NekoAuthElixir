defmodule NekoAuthWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  object :user do
    field :email, :string
    field :display_name, :string
    field :user_name, :string
    field :descriminator, :integer
    field :password_hash, :string
    field :date_of_birth, :string
    field :email_verified, :boolean
  end
end
