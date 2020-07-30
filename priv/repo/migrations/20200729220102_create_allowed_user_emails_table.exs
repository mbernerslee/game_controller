defmodule GameController.Repo.Migrations.CreateAllowedUserEmailsTable do
  use Ecto.Migration

  def change do
    create table("allowed_user_emails") do
      add :email, :string, null: false
      timestamps()
    end

    create unique_index(:allowed_user_emails, :email)
  end
end
