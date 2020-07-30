defmodule GameController.Seeds do
  alias GameController.{AllowedUserEmailsBuilder, UserBuilder, Repo}
  alias Ecto.Adapters.SQL

  @signed_up_email "user@example.com"
  @password "password"

  @can_signup_email "can_signup@example.com"

  def insert do
    SQL.query!(Repo, "TRUNCATE users CASCADE", [])
    SQL.query!(Repo, "TRUNCATE allowed_user_emails CASCADE", [])

    AllowedUserEmailsBuilder.build()
    |> AllowedUserEmailsBuilder.with_non_unqiued_email(@signed_up_email)
    |> AllowedUserEmailsBuilder.insert()

    UserBuilder.build()
    |> UserBuilder.with_non_unqiued_email(@signed_up_email)
    |> UserBuilder.with_password(@password)
    |> UserBuilder.insert()

    AllowedUserEmailsBuilder.build()
    |> AllowedUserEmailsBuilder.with_non_unqiued_email(@can_signup_email)
    |> AllowedUserEmailsBuilder.insert()
  end

  def logins do
    [
      %{email: @signed_up_email, description: "authed user"},
      %{email: @can_signup_email, description: "user can create account"}
    ]
  end
end
