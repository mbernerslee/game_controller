defmodule GameControllerWeb.Plugs.LoggedOut do
  use GameControllerWeb, :controller
  alias GameController.Auth

  def init(opts) do
    opts
  end

  def call(conn, _opts \\ []) do
    if Auth.has_session?(conn) do
      conn
      |> redirect(to: "/")
      |> halt()
    else
      conn
    end
  end
end
