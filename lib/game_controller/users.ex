defmodule GameController.Users do
  import Ecto.Query

  alias GameController.{Result, Auth, Repo, User}

  def login(email, clear_text_password) do
    email
    |> fetch_hashed_password_for_email()
    |> Result.and_then(&check_password(&1, clear_text_password))
  end

  def signup(email, password) do
    with true <- in_allowed_user_emails_table?(email),
         false <- in_users_table?(email) do
      email
      |> User.insert_changeset(password)
      |> Repo.insert()
    else
      _ -> :error
    end
  end

  defp in_allowed_user_emails_table?(email) do
    Repo.exists?(from a in "allowed_user_emails", where: a.email == ^email, select: a.id)
  end

  defp in_users_table?(email) do
    Repo.exists?(from u in "users", where: u.email == ^email, select: u.id)
  end

  defp check_password(user, clear_text_password) do
    %{email: email, password: hashed_password, id: id} = user

    if Auth.check_password(clear_text_password, hashed_password) do
      {:ok, %{id: id, email: email}}
    else
      :error
    end
  end

  defp fetch_hashed_password_for_email(email) do
    case Repo.one(from u in "users", where: u.email == ^email, select: [:id, :password, :email]) do
      nil -> :error
      user -> {:ok, user}
    end
  end
end
