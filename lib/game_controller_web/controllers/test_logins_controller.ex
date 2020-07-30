defmodule GameControllerWeb.TestLoginsController do
  use GameControllerWeb, :controller
  alias GameController.Seeds

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def reseed(conn, _params) do
    Seeds.insert()

    IO.inspect("I reset the seed data")

    conn
    |> put_flash(:info, "Test logins (seed data) has been reset")
    |> redirect(to: Routes.test_logins_path(conn, :show))
  end
end
