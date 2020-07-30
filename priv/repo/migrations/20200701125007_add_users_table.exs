defmodule GameController.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add :email, :string, null: false
      add :password, :string, null: false
      add :verification_key, :string, null: false
      timestamps()
    end

    create unique_index(:users, :email)
  end
end
