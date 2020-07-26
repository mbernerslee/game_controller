defmodule GameControllerWeb.Plugs.LoggedIn do
  use GameControllerWeb, :controller
  alias GameController.Auth

  def init(opts) do
    opts
  end

  def call(conn, _opts \\ []) do
    if Auth.has_session?(conn) do
      conn
    else
      conn
      |> redirect(to: Routes.login_path(conn, :show))
      |> halt()
    end
  end
end
