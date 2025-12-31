defmodule NekoAuth.Repo.Migrations.ChangeSessionTimeStamps do
  use Ecto.Migration

  def change do
    rename table(:sessions), :created_at, to: :inserted_at
  end
end
