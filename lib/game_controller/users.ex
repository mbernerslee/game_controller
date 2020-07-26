defmodule GameController.Users do
  import Ecto.Query

  alias GameController.{Result, Auth, Repo}

  def login(email, clear_text_password) do
    email
    |> fetch_hashed_password_for_email()
    |> Result.and_then(&check_password(&1, clear_text_password))
  end

  defp check_password(user, clear_text_password) do
    %{email: email, password: hashed_password, id: id} = user

    if Auth.check(clear_text_password, hashed_password) do
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
