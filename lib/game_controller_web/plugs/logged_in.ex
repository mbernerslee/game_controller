defmodule GameControllerWeb.Plugs.LoggedIn do
  use GameControllerWeb, :controller

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    IO.inspect(conn.assigns)

    if conn.assigns == %{} do
      redirect(conn, to: Routes.login_path(conn, :show))
    else
      conn
    end
  end
end
