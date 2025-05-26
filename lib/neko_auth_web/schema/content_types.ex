defmodule NekoAuthWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation
  import_types(NekoAuth.Schema.Types)

  object :user do
    field :email, :string
    field :display_name, :string
    field :user_name, :string
    field :descriminator, :integer
    field :password_hash, :string
    field :date_of_birth, :string
    field :email_verified, :boolean
    field :image, :binary
  end

  object :service do
    field :id, :id
    field :name, :string
    field :description, :string
    field :url, :string
    field :icon_url, :string
    field :created_at, :datetime
    field :updated_at, :datetime
    field :client_secret, :string
    field :redirect_uris, list_of(:string)
    field :scopes, list_of(:string)
    field :application_type, :string
    field :status, :boolean
    field :email_restriction_type, :string
    field :restricted_emails, list_of(:string)
    field :owner_email, :string
  end
end
