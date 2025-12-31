defmodule NekoAuth.Repo.Migrations.AddSessionTable do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :user_id, references(:user, column: :id, type: :uuid, on_delete: :delete_all), null: false
      add :created_at, :utc_datetime_usec, null: false
      add :updated_at, :utc_datetime_usec, null: false
      add :disabled_at, :utc_datetime_usec, null: true
      add :code, :string
      add :code_used_at, :utc_datetime_usec, null: true
      add :code_challenge, :string
      add :code_method, :string
      add :session_token, :string
    end
  end
end
