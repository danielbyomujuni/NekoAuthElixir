defmodule YourApp.Repo.Migrations.MakeEmailPrimaryKeyOnUsers do
  use Ecto.Migration

  def up do
    # Ensure email is not nullable
    alter table(:user, primary_key: true) do
      modify :email, :string, null: false
    end
  end
end
