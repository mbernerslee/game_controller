alias GameController.UserBuilder
alias GameController.Repo
alias Ecto.Adapters.SQL

SQL.query!(Repo, "TRUNCATE users CASCADE", [])

UserBuilder.build()
|> UserBuilder.with_non_unqiued_email("user@example.com")
|> UserBuilder.with_password("password")
|> UserBuilder.insert()
