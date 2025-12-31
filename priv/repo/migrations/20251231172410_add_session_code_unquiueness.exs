defmodule NekoAuth.Repo.Migrations.AddSessionCodeUnquiueness do
  use Ecto.Migration

  def change do
    create(unique_index(:sessions, :code))
  end
end
