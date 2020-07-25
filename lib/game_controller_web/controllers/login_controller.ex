defmodule GameControllerWeb.LoginController do
  use GameControllerWeb, :controller
  alias GameController.{Users, Password}

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case Users.login(email, password) do
      {:ok, %{id: id, email: email}} ->
        conn
        |> Password.add_user_session(id, email)
        |> redirect(to: Routes.main_page_path(conn, :show))

      :error ->
        conn
        |> put_flash(:error, "bad credentials. try again m8")
        |> redirect(to: Routes.login_path(conn, :show))
    end
  end
end
