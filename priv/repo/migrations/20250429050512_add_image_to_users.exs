defmodule MyApp.Repo.Migrations.AddImageToUsers do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :image, :binary
    end
  end
end
