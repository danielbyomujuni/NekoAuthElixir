defmodule NekoAuth.Repo.Migrations.AddIdToUserTable do
  use Ecto.Migration

  def up do
    alter table(:user) do
      add :id, :uuid, default: fragment("gen_random_uuid()")
    end

    execute "UPDATE \"user\" SET id = gen_random_uuid() WHERE id IS NULL"

    alter table(:user) do
      modify :id, :uuid, null: false
    end

    alter table(:services) do
      add :user_id, :uuid
    end

    execute """
    UPDATE services
    SET user_id = "user".id
    FROM "user"
    WHERE services.owner_email = "user".email
    """

    execute "ALTER TABLE services DROP CONSTRAINT services_owner_email_fkey"
    execute "ALTER TABLE  \"user\" DROP CONSTRAINT user_pkey"
    execute "ALTER TABLE  \"user\" ADD PRIMARY KEY (id)"

    create unique_index(:user, [:email])

    create index(:services, [:user_id])

    alter table(:services) do
      modify :user_id, references(:user, column: :id, type: :uuid, on_delete: :delete_all), null: false
    end

  end

  def down do
  # Step 1: Drop the foreign key constraint on services.user_id
  alter table(:services) do
    modify :user_id, :uuid, null: true
  end

  execute """
  ALTER TABLE services
  DROP CONSTRAINT IF EXISTS services_user_id_fkey
  """

  # Step 2: Drop the index on user_id
  drop index(:services, [:user_id])

  # Step 3: Drop the unique index on email
  drop unique_index(:user, [:email])

  # Step 4: Drop the primary key on id
  execute "ALTER TABLE \"user\" DROP CONSTRAINT user_pkey"

  # Step 5: Restore the primary key on email
  execute "ALTER TABLE \"user\" ADD PRIMARY KEY (email)"

  # Step 6: Restore the foreign key constraint on services.owner_email
  execute """
  ALTER TABLE services
  ADD CONSTRAINT services_owner_email_fkey
  FOREIGN KEY (owner_email) REFERENCES "user"(email)
  """

  # Step 7: Remove user_id column from services
  alter table(:services) do
    remove :user_id
  end

  # Step 8: Remove id column from user
  alter table(:user) do
    remove :id
  end
end
end
