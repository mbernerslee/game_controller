defmodule GameController.User do
  use Ecto.Schema
  alias Ecto.Changeset
  alias GameController.Auth

  schema "users" do
    field :email, :string
    field :password, :string
    field :verification_key, :string
    timestamps()
  end

  @email_regex ~r|.+\@.+\..+|
  @password_regex ~r|(?=.*[0-9]+.*)(?=.*[a-z]+.*)(?=.*[A-Z]+.*).{8,}|
  @invalid_email_message "That's not a real email mate"
  @invalid_password_message "Password must be at least 8 characters long and contain at least one number and lower and upper case character"

  def insert_changeset(email \\ "", password \\ "") do
    %__MODULE__{}
    |> Changeset.cast(%{email: email, password: password}, [:email, :password])
    |> Changeset.validate_format(:email, @email_regex, message: @invalid_email_message)
    |> Changeset.validate_format(:password, @password_regex, message: @invalid_password_message)
    |> Changeset.update_change(:password, &Auth.hash_password/1)
    |> Changeset.put_change(:verification_key, Auth.generate_verification_key())
  end
end
