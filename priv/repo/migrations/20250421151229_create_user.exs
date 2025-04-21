defmodule NekoAuth.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user, primary_key: false) do
      add :email, :string, size: 65, null: false, primary_key: true
      add :display_name, :string, size: 50, null: false
      add :user_name, :string, size: 50, null: false
      add :descriminator, :integer, null: false
      add :password_hash, :text, null: false
      add :date_of_birth, :date, null: false
      add :email_verified, :boolean, default: false

      # We intentionally omit timestamps because they're not part of the SQL schema
    end

    create unique_index(:user, [:user_name, :descriminator])
  end
end
