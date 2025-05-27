defmodule NekoAuth.Model.Services do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "services" do
    field :name, :string
    field :description, :string
    field :url, :string
    field :icon_url, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :client_secret, :string
    field :redirect_uris, {:array, :string}
    field :scopes, {:array, :string}
    field :application_type, :string
    field :status, :boolean
    field :email_restriction_type, :string
    field :restricted_emails, {:array, :string}
    field :owner_email, :string
  end

  def changeset(service, attrs) do
    service
    |> cast(attrs, [
      :name,
      :description,
      :url,
      :icon_url,
      :client_secret,
      :redirect_uris,
      :scopes,
      :application_type,
      :status,
      :email_restriction_type,
      :restricted_emails,
      :owner_email,
      :created_at,
      :updated_at
    ])
    |> validate_required([
      :name,
      :description,
      :url,
      :client_secret,
      :redirect_uris,
      :scopes,
      :application_type,
      :status,
      :email_restriction_type,
      :restricted_emails,
      :owner_email,
      :created_at,
      :updated_at
    ])
  end
end
