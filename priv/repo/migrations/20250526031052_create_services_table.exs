defmodule NekoAuth.Repo.Migrations.CreateServicesTable do
  use Ecto.Migration

  def change do
    create table(:services, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :name, :string, size: 50, null: false
      add :description, :text, null: false
      add :url, :string, size: 255, null: false
      add :icon_url, :string, size: 255
      add :created_at, :utc_datetime_usec, null: false
      add :updated_at, :utc_datetime_usec, null: false
      add :client_secret, :string, size: 64, null: false
      add :redirect_uris, {:array, :string}, null: false
      add :scopes, {:array, :string}, null: false
      add :application_type, :string, null: false
      add :status, :boolean, null: false, default: true
      add :email_restriction_type, :string, null: false, default: "none"
      add :restricted_emails, {:array, :string}, null: false, default: []
      add :owner_email, references(:user, column: :email, type: :string, on_delete: :delete_all), null: false
    end
  end
end
