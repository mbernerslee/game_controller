defmodule GameControllerWeb.SignupController do
  use GameControllerWeb, :controller
  alias GameController.{Users, Auth, User}

  def show(conn, _params) do
    render(conn, "show.html", changeset: User.insert_changeset())
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Users.signup(email, password) do
      {:ok, %{id: id}} ->
        conn
        |> Auth.set_session(id, email)
        |> redirect(to: Routes.main_page_path(conn, :show))

      {:error, changeset} ->
        render(conn, "show.html", changeset: changeset)

      :error ->
        conn
        |> put_flash(:error, "bad credentials. try again m8")
        |> redirect(to: Routes.signup_path(conn, :show))
    end
  end
end
