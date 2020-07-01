defmodule GameControllerWeb.LoginController do
  use GameControllerWeb, :controller
  alias GameController.Users

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case Users.login(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "that worked, but there's no pages after this :-|")
        |> render("show.html")

      {:error, _} ->
        conn |> put_flash(:error, "bad credentials. try again m8") |> render("show.html")
    end
  end
end
